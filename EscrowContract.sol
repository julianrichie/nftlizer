// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract NFTLizerEscrowContract is AccessControl {

    mapping(address => uint256) private CONTRACT_MINTING_FEE;
    address private WithdrawalWallet;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function getMintingFee() external view returns (uint256){
        return CONTRACT_MINTING_FEE[msg.sender];
    }

    function setMintingFee(address destination,uint256 fee) external onlyRole(DEFAULT_ADMIN_ROLE){
        CONTRACT_MINTING_FEE[destination] = fee;
    }

    function setWithdrawalWallet(address destination) external onlyRole(DEFAULT_ADMIN_ROLE){
        WithdrawalWallet = destination;
    }

    function getWithdrawalWallet() external onlyRole(DEFAULT_ADMIN_ROLE) view returns(address) {
        return WithdrawalWallet;
    }

    function withdrawalToken() external onlyRole(DEFAULT_ADMIN_ROLE) {
        address destination = payable(WithdrawalWallet);
        uint256 amt = address(this).balance;
        (bool success,) = destination.call{value: amt}("");
        require(success,"failed to withdrawa token");
    }
}
