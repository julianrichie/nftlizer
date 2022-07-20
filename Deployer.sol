// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "github.com/julianrichie/nftlizer/blob/main/AccessControl.sol";
import "github.com/julianrichie/nftlizer/blob/main/EscrowContract.sol";

abstract contract NFTLizerDeployer is NFTLizerAccessControl {

    uint256 private _MintingFee;
    address private _ContractDeployer;
    address private constant _EscrowContractAddress = 0x44DD2553357660a95de348f635C16d3d0391b4DB;

    modifier requireFee() {
        uint256 fee = NFTLizerEscrowContract(_EscrowContractAddress).getMintingFee();
        require(msg.value >= fee);
        _;
    }

    function getContractDeployer() public view returns(address) {
        return _ContractDeployer;
    }

    function _forwardFee() internal {
        address proxy = payable(_EscrowContractAddress);
        (bool success,) = proxy.call{value: msg.value}("");
        require(success,"failed to forward fund to proxy");
    }

    function setMintingFee(uint256 _fee) public onlyRole(DEPLOYER_ROLE) {
        _MintingFee = _fee;
    }

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        return _MintingFee;
    }
    
}
