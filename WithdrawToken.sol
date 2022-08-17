// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract WithdrawToken is AccessControl {

    function withdrawToken(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address wallet = payable(addr);
        bool success = _TransferToken(_GetAvailableToken(),wallet);
        require(success,"withdrawal process failed");
    }

    function _TransferToken(uint256 amt, address destination) internal returns (bool) {
        address wallet = payable(destination);
        (bool success,) = wallet.call{value: amt}("");
        return success;
    }

    function _GetAvailableToken() internal view returns(uint256) {
        uint256 amt = address(this).balance;
        return amt;
    }

}
