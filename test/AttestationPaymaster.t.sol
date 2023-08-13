// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IEntryPoint } from "account-abstraction/interfaces/IEntryPoint.sol";
import { IEAS } from "../src/interfaces/IEAS.sol";
import "forge-std/Test.sol";
import "../src/AttestationPaymaster.sol";

contract AttestationPaymasterTest is Test {
    AttestationPaymaster public attestationPaymaster;

    function setUp() public {
        IEntryPoint entryPoint = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
        IEAS eas = IEAS(0xA1207F3BBa224E2c9c3c6D5aF63D0eb1582Ce587);
        attestationPaymaster = new AttestationPaymaster(eas, entryPoint);
    }
}
