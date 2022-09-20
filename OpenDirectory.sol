// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NFTLizerOpenDirectory is AccessControl,Pausable{

    bytes32 private constant VERIFICATOR_ROLE = keccak256("VERIFICATOR_ROLE");

    mapping(address => bytes32) Wallets;
    mapping(address => bool) Status;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function register(bytes32 name) public whenNotPaused {
        Wallets[msg.sender] = name;
    }

    function getLabel(address wallet) public view returns(bytes32,bool){
        return (Wallets[wallet],Status[wallet]);
    }

    function verifyAddress(address wallet, bool status) public whenNotPaused onlyRole(VERIFICATOR_ROLE) {
        Status[wallet] = status;
    }

    function pauseContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function resumeContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
