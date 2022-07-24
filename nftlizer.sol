// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "github.com/julianrichie/nftlizer/blob/main/TransferableOwnership.sol";
import "github.com/julianrichie/nftlizer/blob/main/UseProxyContract.sol";
import "github.com/julianrichie/nftlizer/blob/main/ProxyContract.sol";

contract NFTlizer is AccessControl,Pausable,ReentrancyGuard, UseProxyContract, TransferableOwnership {

    using Counters for Counters.Counter;

    bytes32 private constant INTERNAL_WRITER_ROLE = keccak256("INTERNAL_WRITER_ROLE");
    bytes32 private constant EXTERN_WRITER_ROLE = keccak256("EXTERN_WRITER_ROLE");
    bytes32 private constant ORDER_ADMIN_ROLE = keccak256("ORDER_ADMIN_ROLE");
    address payable private WithdrawalWallet;
    Counters.Counter private COUNTER;
    mapping(uint256 => NFCTag) private Tags;
    mapping(bytes32 => uint256) private Orders;

    struct NFCTag {
        bytes8  VERSION;
        bytes7  UID;
        uint256 INTERNAL_ID;
        address OWNER;
        address NFT_ADDRESS;
        uint256 NFT_ID;
        uint256 NETWORK;
        uint8   ERC;
    }

    modifier feeProtection() {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        require(msg.value >= fee);
        _;
    }

    //EVENTS
    event TagRegistered(bytes8 VERSION, bytes7 UID,uint256 INTERNAL_ID,address OWNER,address NFT_ADDRESS,uint256 NFT_ID,uint256 NETWORK,uint8 ERC,address SENDER);
    event ExternTagRegistered(bytes7 UID,uint256 INTERNAL_ID,address SENDER);
    event PaymentReceived(bytes32 ID, address SENDER, uint256 VALUE);
    event WithdrawalSuccess(uint256 VALUE);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE,msg.sender);
        WithdrawalWallet = payable(msg.sender);
    }

    function _AddTag(bytes8 _VERSION,bytes7 _UID, address _OWNER,address _ADDRESS, uint256 _ID, uint256 _NETWORK,uint8 _ERC) private {
        COUNTER.increment();
        uint256 CURRENT_COUNTER = COUNTER.current();
        Tags[CURRENT_COUNTER] = NFCTag(_VERSION,_UID,CURRENT_COUNTER,_OWNER,_ADDRESS,_ID,_NETWORK,_ERC);
    }

    function AddTag(bytes8 _VERSION,bytes7 _UID, address _OWNER,address _ADDRESS, uint256 _ID, uint256 _NETWORK,uint8 _ERC) onlyRole(INTERNAL_WRITER_ROLE) public{
        _AddTag(_VERSION,_UID,_OWNER,_ADDRESS,_ID,_NETWORK,_ERC);
        emit TagRegistered(_VERSION,_UID,COUNTER.current(),_OWNER,_ADDRESS,_ID,_NETWORK,_ERC,msg.sender);
    }

    function AddTagExtern(bytes8 _VERSION,bytes7 _UID, address _OWNER,address _ADDRESS, uint256 _ID, uint256 _NETWORK,uint8 _ERC) whenNotPaused feeProtection onlyRole(EXTERN_WRITER_ROLE) public payable{
        _AddTag(_VERSION,_UID,_OWNER,_ADDRESS,_ID,_NETWORK,_ERC);
        emit TagRegistered(_VERSION,_UID,COUNTER.current(),_OWNER,_ADDRESS,_ID,_NETWORK,_ERC,msg.sender);
        emit ExternTagRegistered(_UID,COUNTER.current(),msg.sender);
    }

    function GetTag(uint256 _ID,bytes8 _VERSION) public view returns(bytes7,address,address,uint256,uint256,uint8) {
        require(Tags[_ID].VERSION == _VERSION,"no match");
        return(Tags[_ID].UID,Tags[_ID].OWNER,Tags[_ID].NFT_ADDRESS,Tags[_ID].NFT_ID,Tags[_ID].NETWORK,Tags[_ID].ERC);
    }

    function GetTagVersion(uint256 _ID) public view returns(bytes8) {
        return(Tags[_ID].VERSION);
    }

    function GetCounter() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        return COUNTER.current();
    }

    function PauseContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function ResumeContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function Pay(bytes32 _ID) whenNotPaused public payable nonReentrant {
        require(msg.value >= Orders[_ID],"invalid amount");
        address destinationWallet = payable(_WithdrawalWalletAddress);
        (bool success,) = destinationWallet.call{value: msg.value}("");
        require(success,"payment failed");
        emit PaymentReceived(_ID,msg.sender,msg.value);
    }

    function GetMintingFee() public view returns(uint256) {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        return fee;
    }

    function GetContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function CreateOrder(bytes32 _ID,uint256 _AMT) public onlyRole(ORDER_ADMIN_ROLE) {
        Orders[_ID] = _AMT;
    }

}
