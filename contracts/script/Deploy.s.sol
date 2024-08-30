// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {SP1Nuport} from "../src/SP1Nuport.sol";
import {ERC1967Proxy} from "@openzeppelin/proxy/ERC1967/ERC1967Proxy.sol";
import {SP1MockVerifier} from "@sp1-contracts/SP1MockVerifier.sol";
import {ISP1Verifier} from "@sp1-contracts/ISP1Verifier.sol";

import {BaseScript} from "./Base.s.sol";

// Required environment variables:
// - SP1_PROVER
// - GENESIS_HEIGHT
// - GENESIS_HEADER
// - SP1_NUPORT_PROGRAM_VKEY
// - CREATE2_SALT
// - SP1_VERIFIER_ADDRESS

contract DeployScript is BaseScript {
    function setUp() public {}

    string internal constant KEY = "SP1_NUPORT";

    function run() external multichain(KEY) returns (address) {
        vm.startBroadcast();

        SP1Nuport lightClient;
        ISP1Verifier verifier = ISP1Verifier(
            vm.envOr("SP1_VERIFIER_ADDRESS", 0x036E25171eAf8E1c8248C079DC9498952e960032)
        );

        // Deploy the SP1Nuport contract.
        SP1Nuport lightClientImpl =
            new SP1Nuport();
        lightClient = SP1Nuport(
            address(
                new ERC1967Proxy(
                    address(lightClientImpl), ""
                )
            )
        );

	console.log("Deployed SP1Nuport at address: %s", address(lightClient));

        // Initialize the SP1 Nuport light client.
        lightClient.initialize(
            SP1Nuport.InitParameters({
                guardian: msg.sender,
                height: uint32(vm.envUint("GENESIS_HEIGHT")),
                header: vm.envBytes32("GENESIS_HEADER"),
                nuportProgramVkey: vm.envBytes32("SP1_NUPORT_PROGRAM_VKEY"),
                verifier: address(verifier)
            })
        );
       console.log("Initialized SP1Nuport at address: %s", address(lightClient));

        return address(lightClient);
    }
}
