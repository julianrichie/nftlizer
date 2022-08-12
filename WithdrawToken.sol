// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Utilities.sol";

abstract contract WithdrawToken is AccessControl {

    function withdrawToken(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address wallet = payable(addr);
        bool success = Utilities.TransferToken(Utilities.GetAvailableToken(),wallet);
        require(success,"withdrawal process failed");
    }

}
