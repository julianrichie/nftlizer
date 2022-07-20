// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract TransferableOwnership is AccessControl {

    address internal _ContractOwner;

    function transferOwnership(address from, address to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(DEFAULT_ADMIN_ROLE,to);
        _ContractOwner = to;
        _revokeRole(DEFAULT_ADMIN_ROLE,from);
    }

    function getContractOwner() public view returns(address) {
        return _ContractOwner;
    }
}
