// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract PublisherContract is ERC1155, AccessControl {

    using Counters for Counters.Counter;
    
    bytes32 private constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    bytes32 private constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    bytes32 private _ContractOwnerName;
    bytes32[5] private _ContractDescription;
    address private _ContractDeployer;
    address private _ContractOwner;
    uint256 private _MintingFee;
    Counters.Counter private COUNTER;
    bool private _ContractInitialized = false;

    event TokenMinted(address DESTINATION, uint256 TOKEN_ID, bytes32 UUID, bytes8 RS, bytes4 PT);

    function _initializeContract(bytes32 name, bytes32[5] memory description) internal {
        require(_ContractInitialized == false, "contract already initialized");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEPLOYER_ROLE,msg.sender);
        _ContractDeployer = msg.sender;
        _ContractOwner = msg.sender;
        _ContractOwnerName = name;
        _ContractDescription = description;
        _ContractInitialized = true;
    }

    function transferOwnership(address newOwner) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(DEFAULT_ADMIN_ROLE,newOwner);
        _setupRole(PUBLISHER_ROLE,newOwner);
        _ContractOwner = newOwner;
        _revokeRole(DEFAULT_ADMIN_ROLE,_ContractDeployer);
    }

    function grantPublisherRole(address publisher) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(PUBLISHER_ROLE,publisher);
    }

    function revokePublisherRole(address publisher) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(PUBLISHER_ROLE,publisher);
    }

    function setMintingFee(uint256 fee) public onlyRole(DEPLOYER_ROLE) {
        _MintingFee = fee;
    }

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256){
        return _MintingFee;
    }

    function MintToken(address destination, bytes32 uuid, bytes8 rs, bytes4 pt) public payable onlyRole(PUBLISHER_ROLE) {
        require(msg.value >= _MintingFee,"insufficient minting fee");
        COUNTER.increment();
        uint256 current = COUNTER.current();
        _mint(destination,current,1,"");
        address Deployer = payable(_ContractDeployer);
        (bool success,) = Deployer.call{value: msg.value}("");
        require(success,"failed to forward fund to deployer");
        emit TokenMinted(destination,current,uuid,rs,pt);
    }

    function GetContractInformation() public view returns(bytes32,bytes32[5] memory,address) {
        require(_ContractInitialized == true,"contract is uninitialized");
        return (_ContractOwnerName,_ContractDescription,_ContractOwner);
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
