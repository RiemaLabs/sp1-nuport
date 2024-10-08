// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {SP1Nuport} from "../src/SP1Nuport.sol";
import {ERC1967Proxy} from "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import {SP1MockVerifier} from "@sp1-contracts/SP1MockVerifier.sol";
import {ISP1Verifier} from "@sp1-contracts/ISP1Verifier.sol";

import {BaseScript} from "./Base.s.sol";

// Required environment variables:
// - GENESIS_HEIGHT
// - GENESIS_HEADER
// - CONTRACT_ADDRESS

contract UpdateGenesisStateScript is BaseScript {
    string internal constant KEY = "SP1_NUPORT";

    function run() external multichain(KEY) returns (address) {
        vm.startBroadcast();

        SP1Nuport lightClient = SP1Nuport(vm.envAddress("CONTRACT_ADDRESS"));

        lightClient.updateGenesisState(
            uint32(vm.envUint("GENESIS_HEIGHT")), vm.envBytes32("GENESIS_HEADER")
        );

        return address(lightClient);
    }
}
