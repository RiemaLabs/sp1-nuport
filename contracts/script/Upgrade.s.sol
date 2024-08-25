// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import {SP1Nuport} from "../src/SP1Nuport.sol";
import {ERC1967Proxy} from "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import {SP1MockVerifier} from "@sp1-contracts/SP1MockVerifier.sol";
import {ISP1Verifier} from "@sp1-contracts/ISP1Verifier.sol";
import {BaseScript} from "./Base.s.sol";

// Required environment variables:
// - CONTRACT_ADDRESS
// - SP1_NUPORT_PROGRAM_VKEY
// - SP1_PROVER

contract UpgradeScript is BaseScript {
    using stdJson for string;

    function setUp() public {}

    string internal constant KEY = "UpgradeScript";

    /// Reads CONTRACT_ADDRESS_<CHAIN_ID> from the environment variables and updates the SP1 Verifier and program vkey.
    function run() external multichain(KEY) broadcaster {
        string memory contractAddressKey =
            string.concat("CONTRACT_ADDRESS_", vm.toString(block.chainid));

        // Deploy new SP1Nuport.
        SP1Nuport newSP1Nuport = new SP1Nuport();

        // Upgrade the existing SP1Nuport.
        SP1Nuport existingNuport = SP1Nuport(vm.envAddress(contractAddressKey));

        existingNuport.upgradeTo(address(newSP1Nuport));

        existingNuport.updateVerifier(0x3B6041173B80E77f038f3F2C0f9744f04837185e);

        existingNuport.updateProgramVkey(vm.envBytes32("SP1_NUPORT_PROGRAM_VKEY"));

        // Enable relayer check.
        existingNuport.setCheckRelayer(true);

        //TODO: Update address
        existingNuport.setRelayerApproval(0x44eB418A966ff47f5AF6f48AEa6Afde0bf193a8d, true);
        // P-OPS relayer on Alphatestnet chains.
        existingNuport.setRelayerApproval(0xEdaCeBA3c0F0beb91771A4193784051a72f44983, true);
    }
}
