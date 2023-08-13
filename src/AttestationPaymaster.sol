// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { BasePaymaster } from "account-abstraction/core/BasePaymaster.sol";
import { IEntryPoint } from "account-abstraction/interfaces/IEntryPoint.sol";
import { UserOperation } from "account-abstraction/interfaces/UserOperation.sol";
import { IEAS } from "eas-contracts/IEAS.sol";
import { Attestation } from "eas-contracts/Common.sol";

import "forge-std/console.sol";

contract AttestationPaymaster is BasePaymaster {

    uint256 public constant PAYMASTER_FEE = 0.01 ether;

    //calculated cost of the postOp
    uint256 constant public COST_OF_POST = 15000;

    IEAS public eas;
    constructor(IEAS _eas, IEntryPoint _entryPoint) BasePaymaster(_entryPoint) {
        eas = _eas;
    }

    /**
      * validate the request:
      * if this is a constructor call, make sure it is a known account.
      * verify the sender has enough tokens.
      * (since the paymaster is also the token, there is no notion of "approval")
      */
    function _validatePaymasterUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 requiredPreFund)
    internal override returns (bytes memory context, uint256 validationData) {
        (bytes32 uid, bool isOffChain) = parsePaymasterAndData(userOp.paymasterAndData);

        // Check for the validity of this attestation
        require(!isOffChain, "Attestation must be on-chain");

        // Check if the attestation is valid
        require(eas.isAttestationValid(uid), "Attestation is not valid");

        Attestation attestation = eas.getAttestation(uid);
        require(attestation.recipient == userOp.sender, "Sender is not attested");
    }

    /**
     * actual charge of user.
     * this method will be called just after the user's TX with mode==OpSucceeded|OpReverted (account pays in both cases)
     * BUT: if the user changed its balance in a way that will cause  postOp to revert, then it gets called again, after reverting
     * the user's TX , back to the state it was before the transaction started (before the validatePaymasterUserOp),
     * and the transaction should succeed there.
     */
    function _postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) internal override {
        // redeem gas fee
        if (mode != PostOpMode.postOpReverted) {
            (address account, int256 withdrawAmount) = abi.decode(context, (address, int256));
            uint256 amount = uint256(withdrawAmount) - PAYMASTER_FEE;
            (bool success, ) = payable(account).call{ value: amount }("");
            require(success, "error");
        }
    }

    function parsePaymasterAndData(bytes calldata paymasterAndData) public pure returns (bytes32 memory uid, bool isOffChain) {
        (uid, isOffChain) = abi.decode(paymasterAndData[20:], (bytes32, bool));
    }
    
}