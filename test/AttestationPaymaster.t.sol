// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IEntryPoint } from "account-abstraction/interfaces/IEntryPoint.sol";
import "forge-std/Test.sol";
import "../src/AttestationPaymaster.sol";

contract AttestationPaymasterTest is Test {
    AttestationPaymaster public attestationPaymaster;

    function setUp() public {
        IEntryPoint entryPoint = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
        attestationPaymaster = new AttestationPaymaster(entryPoint);
    }
}
