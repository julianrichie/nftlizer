// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
// Test contract to implement PublisherContract
pragma solidity ^0.8.0;

import "./PublisherContract.sol";

contract TestContract is PublisherContract {

    // TO SAVE GAS FEE STRING MUST BE CONVERTED TO BYTES32/[] TYPE
    bytes32 private constant ContractOwnerName = bytes32(0x4a756c69616e205269636869652057616a6f6e67000000000000000000000000);
    bytes32[5] private ContractDescription = [
        bytes32(0x636f6e7472616374206465736372697074696f6e20676f657320686572652020),
        bytes32(0x636f6e7472616374206465736372697074696f6e20676f657320686572652020),
        bytes32(0x636f6e7472616374206465736372697074696f6e20676f657320686572652020),
        bytes32(0x636f6e7472616374206465736372697074696f6e20676f657320686572652020),
        bytes32(0x636f6e7472616374206465736372697074696f6e20676f657320686572652020)];

    constructor() ERC1155("") {
        _initializeContract(ContractOwnerName,ContractDescription);
    }
}
