// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "github.com/julianrichie/nftlizer/blob/main/TransferableOwnership.sol";
import "github.com/julianrichie/nftlizer/blob/main/UseProxyContract.sol";
import "github.com/julianrichie/nftlizer/blob/main/ProxyContract.sol";
import "github.com/julianrichie/nftlizer/blob/main/WithdrawToken.sol";

abstract contract PublisherContract is ERC1155, AccessControl,TransferableOwnership, UseProxyContract, Pausable, WithdrawToken{

    bytes32 internal constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 internal constant APPROVAL_ROLE = keccak256("APPROVAL_ROLE");
    bool internal _ContractInitialized = false;
    bytes32 private _ContractOwnerName;
    bytes32[4] private _ContractDescription;
    mapping(uint256 => PendingApproval) private _WaitingForApprovals;

    modifier feeProtection() {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        require(msg.value >= fee);
        _;
    }

    struct PendingApproval {
        address destination;
        bytes32 uuid;
        bytes8 rs;
        bytes4 pt;
    }

    using Counters for Counters.Counter;
    Counters.Counter private COUNTER;
    
    event TokenMinted(address indexed DESTINATION, uint256 TOKEN_ID, bytes32 UUID, bytes8 RS, bytes4 PT);
    event RequestForApproval(uint256 indexed ID, address indexed DESTINATION, bytes32 UUID, bytes8 RS, bytes4 PT);
    event ContractInitialized(address indexed DEPLOYER, address indexed OWNER);

    //Administrative tasks
    function _initializeContract(bytes32 name, bytes32[4] memory description,address newOwner,address proxy) internal {
        require(_ContractInitialized == false, "contract already initialized");
        _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
        _ContractOwner = newOwner;
        _ContractOwnerName = name;
        _ContractDescription = description;
        _ContractInitialized = true;
        emit ContractInitialized(msg.sender,newOwner);
        _NFTLizerProxyContract = proxy;
    }

    function setURI(string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(uri);
    }

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        return fee;
    }

    function GetContractInformation() public view returns(bytes32,bytes32[4] memory,address) {
        require(_ContractInitialized == true,"contract is uninitialized");
        return (_ContractOwnerName,_ContractDescription,_ContractOwner);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /* MINTING tasks
    // Two steps minting process
    // 1. publisher request for minting approval;
    // 2. approver approve minting process & immediately mint the token;
    */

    function requestForMintingApproval(address destination, bytes32 uuid, bytes8 rs, bytes4 pt) public payable feeProtection whenNotPaused onlyRole(PUBLISHER_ROLE) {
        COUNTER.increment();
        uint256 current = COUNTER.current();
        _WaitingForApprovals[current] = PendingApproval(destination,uuid,rs,pt);
        if (msg.value > 0) {
            bool success = _TransferToken(msg.value,getNFTLizerWalletAddress());
            require(success,"failed to forward fund");
        }
        emit RequestForApproval(current,destination,uuid,rs,pt);
    }

    function approveForMinting(uint256 id) public whenNotPaused onlyRole(APPROVAL_ROLE) {
        PendingApproval memory pending = _WaitingForApprovals[id];
        _mint(pending.destination,id,1,"");
        delete _WaitingForApprovals[id];
        emit TokenMinted(pending.destination,id,pending.uuid,pending.rs,pending.pt);
    }

    function pauseContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function resumeContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function getNFTLizerWalletAddress() private view returns (address) {
        address nftlizer = NFTLizerProxyContract(_NFTLizerProxyContract).getNFTLizerWalletAddress();
        return nftlizer;
    }


}
