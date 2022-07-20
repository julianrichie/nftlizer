// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract NFTLizerAccessControl is AccessControl {

    bytes32 internal constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 internal constant APPROVAL_ROLE = keccak256("APPROVAL_ROLE");
    bytes32 internal constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");

    modifier selfRevokeProtect(address destination) {
        require(destination != msg.sender,"self revoke not permitted");
        _;
    }
}
