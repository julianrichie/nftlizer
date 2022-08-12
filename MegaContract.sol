// SPDX-License-Identifier: MIT
// Copyright (c) 2022 JULIAN WAJONG julian@nftlizer.com NFTLIZER.COM
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "github.com/julianrichie/nftlizer/blob/main/TransferableOwnership.sol";
import "github.com/julianrichie/nftlizer/blob/main/UseProxyContract.sol";
import "github.com/julianrichie/nftlizer/blob/main/ProxyContract.sol";
import "github.com/julianrichie/nftlizer/blob/main/WithdrawToken.sol";

contract MegaContract is ERC1155,AccessControl,Pausable,ReentrancyGuard,TransferableOwnership, UseProxyContract, WithdrawToken {
    using Counters for Counters.Counter;

    struct WalletOwner {
        bytes32[3] name;
        uint256 block_number;
        bytes32 block_hash;
    }

    modifier feeProtection() {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        require(msg.value >= fee);
        _;
    }
    
    bytes32 private constant PUBLISHER_ROLE = keccak256("PUBLISHER_ROLE");
    mapping(address => WalletOwner) private WALLET_INFORMATION;
    mapping(uint256 => address) private TOKEN_PUBLISHERS;
    Counters.Counter private COUNTER;

    event PublisherAdded(address indexed WALLET,bytes32[3] NAME);
    event TokenMinted(address indexed SOURCE, address indexed DESTINATION, uint256 TOKEN_ID, bytes32 UUID, bytes8 RS, bytes4 PT);

    constructor() ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
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

    function GetContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function AddPublisher(address wallet,bytes32[3] memory name) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(PUBLISHER_ROLE,wallet);
        WalletOwner memory wo = WalletOwner(name, block.number, blockhash(block.number));
        WALLET_INFORMATION[wallet] = wo;
        emit PublisherAdded(wallet, name);
    }

    // PUBLIC ACCESSIBLE
    function MintToken(address destination,bytes32 uuid, bytes8 rs, bytes4 pt) public payable whenNotPaused feeProtection onlyRole(PUBLISHER_ROLE){
        COUNTER.increment();
        uint256 current = COUNTER.current();
        _mint(destination,current,1,"");
        if (msg.value > 0) {
            bool success = _TransferToken(msg.value,getNFTLizerWalletAddress());
            require(success,"failed to forward fund");
        }
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

    function getMintingFee() public view onlyRole(DEFAULT_ADMIN_ROLE) returns(uint256) {
        uint256 fee = NFTLizerProxyContract(_NFTLizerProxyContract).getMintingFee();
        return fee;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getNFTLizerWalletAddress() private returns (address) {
        address nftlizer = ProxyContract(_NFTLizerProxyContract).getNFTLizerWalletAddress();
        return nftlizer;
    }

}
