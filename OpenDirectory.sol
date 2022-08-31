// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NFTLizerOpenDirectory is AccessControl,Pausable{

    mapping(address => bytes32) Wallets;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registerWallet(bytes32 name) public whenNotPaused {
        Wallets[msg.sender] = name;
    }

    function getWallet(address wallet) public view returns(bytes32){
        return Wallets[wallet];
    }

    function pauseContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function resumeContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
