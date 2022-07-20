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

    function grantPublisherRole(address publisher) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(PUBLISHER_ROLE,publisher);
    }

    function revokePublisherRole(address publisher) public selfRevokeProtect(publisher) onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(PUBLISHER_ROLE,publisher);
    }

    function grantApprovalRole(address approval) public  onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(APPROVAL_ROLE,approval);
    }

    function revokeApprovalRole(address approval) public selfRevokeProtect(approval) onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(APPROVAL_ROLE,approval);
    }

    function grantAdminRole(address admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function revokeAdminRole(address admin) public selfRevokeProtect(admin) onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(DEFAULT_ADMIN_ROLE,admin);
    }
}
