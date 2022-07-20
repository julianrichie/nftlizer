// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "./AccessControl.sol";

abstract contract NFTLizerDeployer is NFTLizerAccessControl {
    uint256 private _MintingFee;

    modifier requireFee() {
        require(msg.value >= _MintingFee);
        _;
    }

    function setMintingFee(uint256 _fee) public onlyRole(DEPLOYER_ROLE) {
        _MintingFee = _fee;
    }

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        return _MintingFee;
    }
    
}
