# SP1 Nuport

## Overview

SP1 Nuport is a Rust project for the SP1 zkVM, utilizing [Nuport](https://github.com/RiemaLabs/Nuport).

- `/program`: The SP1 Nuport program.
- `/primitives`: Libraries for types and helper functions used in the program.
- `/script`: Scripts for getting the contract's genesis parameters and deploying the operator to
    update the light client.
- `/contracts`: The contract's source code and deployment scripts.

## Deploying SP1 Nuport

### Components

An SP1 Nuport implementation has a few key components:

- An `SP1Nuport` contract. Contains the logic for verifying SP1 Nuport proofs, storing the
latest data from the Nubit chain, including the headers and data commitments.
- An `SP1Verifier` contract. Verifies arbitrary SP1 programs. Most chains will have canonical deployments
upon SP1's mainnet launch. Until then, users can deploy their own `SP1Verifier` contracts to verify
SP1 programs on their chain. The SP1 Nuport implementation will use the `SP1Verifier` contract to verify the proofs of the SP1 Nuport programs.
- The SP1 Nuport program. An SP1 program that verifies the transition between two Tendermint
headers and computes the data commitment of the intermediate blocks.
- The operator. A Rust script that fetches the latest data from a deployed `SP1Nuport` contract and a
Tendermint chain, determines the block to request, requests for/generates a proof, and relays the proof to
the `SP1Nuport` contract.

### Deployment

1. To deploy an SP1 Nuport contract for a Tendermint chain do the following.

    Get the genesis parameters for the `SP1Nuport` contract.

    ```shell
    cd script

    # Example with Nubit Alphatestnet Testnet.
    TENDERMINT_RPC_URL=https://validator.nubit-alphatestnet-1.com:26657/ cargo run --bin genesis --release
    ```

2. Deploy the `SP1Nuport` contract with genesis parameters: `GENESIS_HEIGHT`, `GENESIS_HEADER`, and `SP1_NUPORT_PROGRAM_VKEY`.

    ```shell
    cd ../contracts

    forge install

    GENESIS_HEIGHT=<GENESIS_HEIGHT> GENESIS_HEADER=<GENESIS_HEADER> SP1_Nuport_PROGRAM_VKEY=<SP1_Nuport_PROGRAM_VKEY> forge script script/Deploy.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --etherscan-api-key <ETHERSCAN_API_KEY> --broadcast --verify
    ```

    If you see the following error, add `--legacy` to the command.

    ```shell
    Error: Failed to get EIP-1559 fees    
    ```

3. Your deployed contract address will be printed to the terminal.

    ```shell
    == Return ==
    0: address <SP1_Nuport_ADDRESS>
    ```

    This will be used when you run the operator in step 5.

4. Export your SP1 Prover Network configuration

    ```shell
    # Export the PRIVATE_KEY you will use to relay proofs.
    export PRIVATE_KEY=<PRIVATE_KEY>

    # Optional
    # If you're using the Succinct network, set SP1_PROVER to "network". Otherwise, set it to "local" or "mock".
    export SP1_PROVER={network|local|mock}
    # Only required if SP1_PROVER is set "network".
    export SP1_PRIVATE_KEY=<SP1_PRIVATE_KEY>
    ```

5. Run the SP1 Nuport operator to update the LC continuously.

    ```
    cd ../script
    
    TENDERMINT_RPC_URL=https://validator.nubit-alphatestnet-1.com:26657/ CHAIN_ID=11155111 RPC_URL=https://ethereum-sepolia.publicnode.com/
    CONTRACT_ADDRESS=<SP1_Nuport_ADDRESS> cargo run --bin operator --release
    ```

## Known Limitations

**Warning:** The implementation of SP1 Nuport assumes that the number of validators is less than
256. This limitation is due to the use of a 256-bit bitmap to represent whether a validator has
signed off on a header. If the number of validators exceeds 256, the `validatorBitmap` functionality
may not work as intended, potentially leading to an incomplete validator equivocation.

On Nubit, the number of validators is currently 100, and there are no plans to increase this number
significantly. If it was to be increased, the signature aggregation logic in the consensus protocol
would likely change as well, which would also necessitate a change in the SP1 Nuport implementation.
