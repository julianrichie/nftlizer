// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MegaContract is ERC1155,AccessControl,Pausable,ReentrancyGuard {
    using Counters for Counters.Counter;

    struct WalletOwner {
        bytes32[3] name;
        uint256 block_number;
        bytes32 block_hash;
    }
    
    bytes32 private constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    uint256 private MINTING_FEE = 0;
    mapping(address => WalletOwner) private WALLET_INFORMATION;
    mapping(uint256 => address) private TOKEN_PUBLISHERS;
    address private WITHDRAWAL_WALLET;
    Counters.Counter private COUNTER;

    event PublisherAdded(address wallet,bytes32[3] name);
    event TokenMinted(address SOURCE, address DESTINATION, uint256 TOKEN_ID, bytes32 UUID, bytes8 RS, bytes4 PT);

    constructor() ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        WITHDRAWAL_WALLET = msg.sender;
    }

    //ADMINISTRATIVE PARTS

    function setURL(string memory URI) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(URI);
    }

    function PauseContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function ResumeContract() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function SetMintingFee(uint256 fee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        MINTING_FEE = fee;
    }

    function GetMintingFee() public view returns(uint256){
        return MINTING_FEE;
    }

    function GetContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function WithdrawBalance() public nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 amount = address(this).balance;
        (bool success,) = WITHDRAWAL_WALLET.call{value: amount}("");
        require(success,"failed to withdraw balance");
    }

    function AddPublisher(address wallet,bytes32[3] memory name) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(PUBLISHER_ROLE,wallet);
        WalletOwner memory wo = WalletOwner(name, block.number, blockhash(block.number));
        WALLET_INFORMATION[wallet] = wo;
        emit PublisherAdded(wallet, name);
    }

    // PUBLIC ACCESSIBLE
    function MintToken(address destination,bytes32 uuid, bytes8 rs, bytes4 pt) public payable whenNotPaused onlyRole(PUBLISHER_ROLE){
        require(msg.value >= MINTING_FEE, "insufficient amount");
        COUNTER.increment();
        uint256 current = COUNTER.current();
        _mint(destination,current,1,"");
        TOKEN_PUBLISHERS[current] = msg.sender;
        emit TokenMinted(msg.sender,destination,current,uuid,rs,pt);
    }

    function GetPublisher(address wallet) public view returns(bytes32[3] memory) {
        WalletOwner memory data = WALLET_INFORMATION[wallet];
        return data.name;
    }

    function GetTokenPublisher(uint256 id) public view returns(address) {
        return TOKEN_PUBLISHERS[id];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    

}
