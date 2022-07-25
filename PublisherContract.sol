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

abstract contract PublisherContract is ERC1155, AccessControl,TransferableOwnership, UseProxyContract, Pausable{

    address private _ContractOwner;
    bytes32 internal constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 internal constant APPROVAL_ROLE = keccak256("APPROVAL_ROLE");
    bytes32 internal constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    bytes32 private _ContractOwnerName;
    bytes32[5] private _ContractDescription;
    bool private _ContractInitialized = false;
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
    
    event TokenMinted(address DESTINATION, uint256 TOKEN_ID, bytes32 UUID, bytes8 RS, bytes4 PT);
    event RequestForApproval(uint256 ID, address DESTINATION, bytes32 UUID, bytes8 RS, bytes4 PT);

    //Administrative tasks
    function _initializeContract(bytes32 name, bytes32[5] memory description,address newOwner) internal {
        require(_ContractInitialized == false, "contract already initialized");
        _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
        _setupRole(DEPLOYER_ROLE,msg.sender);
        _ContractOwner = newOwner;
        _ContractOwnerName = name;
        _ContractDescription = description;
        _ContractInitialized = true;
    }

    function setURI(string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(uri);
    }

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        return fee;
    }

    function GetContractInformation() public view returns(bytes32,bytes32[5] memory,address) {
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

    function requestForApproval(address destination, bytes32 uuid, bytes8 rs, bytes4 pt) public payable feeProtection whenNotPaused onlyRole(PUBLISHER_ROLE) {
        COUNTER.increment();
        uint256 current = COUNTER.current();
        _WaitingForApprovals[current] = PendingApproval(destination,uuid,rs,pt);
        address wallet = payable(_WithdrawalWalletAddress);
        (bool success,) = wallet.call{value: msg.value}("");
        require(success,"failed to forward fund to proxy");
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


}
