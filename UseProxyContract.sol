// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract UseProxyContract is AccessControl {

    //DONT FORGET TO OVERRIDE THIS ON INITIALIZATION
    address internal _NFTLizerProxyContract = 0x0000000000000000000000000000000000000000;

    modifier callerIsProxyContract() {
        require(_NFTLizerProxyContract == msg.sender,"unauthorized");
        _;
    }

    function setNFTLizerProxyContractAddress(address addr) public callerIsProxyContract {
        _NFTLizerProxyContract = addr;
    }

    function getNFTLizerProxyContractAddress() public view returns (address) {
        return _NFTLizerProxyContract;
    }

}
