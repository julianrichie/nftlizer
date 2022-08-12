// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

library Utilities {
    function TransferToken(uint256 amt, address destination) public returns (bool) {
        address wallet = payable(destination);
        (bool success,) = wallet.call{value: amt}("");
        return success;
    }

    function GetAvailableToken() public view returns(uint256) {
        uint256 amt = address(this).balance;
        return amt;
    }
    

}
