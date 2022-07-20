// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTLizerProxyContract is AccessControl {

    mapping(address => uint256) private CONTRACT_MINTING_FEE;

    modifier callerIsContract() {
        require(Address.isContract(msg.sender),"not a valid contract address");
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function getMintingFee() callerIsContract public view returns (uint256){
        return CONTRACT_MINTING_FEE[msg.sender];
    }

    function setMintingFee(address addr,uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE){
        CONTRACT_MINTING_FEE[addr] = fee;
    }

    function withdrawalToken(address destination, uint256 value) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address wallet = payable(destination);
        require(value >= address(this).balance);
        (bool success,) = wallet.call{value: value}("");
        require(success,"failed to withdrawal token");
    }
}
