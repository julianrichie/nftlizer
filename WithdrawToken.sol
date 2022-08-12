// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract WithdrawToken is AccessControl {

    address internal _WithdrawalWalletAddress = 0x0000000000000000000000000000000000000000;

    function setWithdrawalWalletAddress(address addr) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _WithdrawalWalletAddress = addr;
    }

    function getWithdrawalWalletAddress() public view returns (address) {
        return _WithdrawalWalletAddress;
    }

    function withdrawToken() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amt = address(this).balance;
        address wallet = payable(_WithdrawalWalletAddress);
        bool success = _TransferToken(amt,wallet);
        require(success,"withdrawal process failed");
    }

    function _TransferToken(uint256 amt, address destination) internal returns (bool){
       address wallet = payable(destination);
       (bool success,) = wallet.call{value: amt}("");
       return(success);
    }

}
