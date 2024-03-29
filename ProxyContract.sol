// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "github.com/julianrichie/nftlizer/blob/main/TransferableOwnership.sol";
import "github.com/julianrichie/nftlizer/blob/main/UseProxyContract.sol";

contract NFTLizerProxyContract is AccessControl, TransferableOwnership {

    mapping(address => uint256) private CONTRACT_MINTING_FEE;
    address private NFTLIZER_WALLET_ADDRESS = 0x0000000000000000000000000000000000000000;

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

    function setNFTLizerWalletAddress(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        NFTLIZER_WALLET_ADDRESS = addr;
    }

    function getNFTLizerWalletAddress() public view returns (address) {
        return NFTLIZER_WALLET_ADDRESS;
    }

    /*CRITICAL FUNCTION CALL THIS WITH CAUTION.
    / MAKE SURE TO HAVE THE NEW PROXY CONTRACT IS READY BEFORE CALLING THIS FUNCTION
    */
    function setNFTLizerProxyContractAddressForClient(address addr,address client) public onlyRole(DEFAULT_ADMIN_ROLE) {
        UseProxyContract(client).setNFTLizerProxyContractAddress(addr);
    }

}
