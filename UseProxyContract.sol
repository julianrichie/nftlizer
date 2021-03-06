// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract UseProxyContract is AccessControl { 

    address internal _WithdrawalWalletAddress = 0x0000000000000000000000000000000000000000;
    address internal _NFTLizerProxyContract = 0x0000000000000000000000000000000000000000;

    function setWithdrawalWalletAddress(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _WithdrawalWalletAddress = addr;
    }

    function setNFTLizerProxyContractAddress(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _NFTLizerProxyContract = addr;
    }

    function getWithdrawalWalletAddress() public view returns (address) {
        return _WithdrawalWalletAddress;
    }

    function getNFTLizerProxyContractAddress() public view returns (address) {
        return _NFTLizerProxyContract;
    }

}
