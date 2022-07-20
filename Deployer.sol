// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "github.com/julianrichie/nftlizer/blob/main/AccessControl.sol";
import "github.com/julianrichie/nftlizer/blob/main/EscrowContract.sol";

abstract contract NFTLizerDeployer is NFTLizerAccessControl {

    address internal constant _EscrowContractAddress = 0x44DD2553357660a95de348f635C16d3d0391b4DB;

    modifier requireFee() {
        uint256 fee = NFTLizerEscrowContract(_EscrowContractAddress).getMintingFee();
        require(msg.value >= fee);
        _;
    }

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        uint256 fee = NFTLizerEscrowContract(_EscrowContractAddress).getMintingFee();
        return fee;
    }

}
