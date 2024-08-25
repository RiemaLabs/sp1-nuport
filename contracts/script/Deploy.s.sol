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
            vm.envOr("SP1_VERIFIER_ADDRESS", 0x3B6041173B80E77f038f3F2C0f9744f04837185e)
        );

        // Deploy the SP1Nuport contract.
        SP1Nuport lightClientImpl =
            new SP1Nuport{salt: bytes32(vm.envBytes("CREATE2_SALT"))}();
        lightClient = SP1Nuport(
            address(
                new ERC1967Proxy{salt: bytes32(vm.envBytes("CREATE2_SALT"))}(
                    address(lightClientImpl), ""
                )
            )
        );

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

        return address(lightClient);
    }
}
