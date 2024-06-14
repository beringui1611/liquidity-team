// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "hardhat/console.sol";

contract Manager {

    error InvalidAddress(address manager);
    error InvalidOnlyManager(address manager);
    error InvalidAddHolder(address holder, uint32 max);
    error InvalidHolder(address holder);

    event NewManager(address indexed manager, uint256 time);

    mapping(address => bool) public holder;

    address public manager;
    uint32 maxHolders;
    uint32 totalHolders;

    constructor(uint32 _mxholders){
      manager = msg.sender;
      maxHolders = _mxholders;
    }

    
    function _setManager(address newManager) internal virtual verifyManager(newManager) {
        manager = newManager;

        emit NewManager(manager, block.timestamp);
    }

    function renunciedManagership(address newManager) external onlyManager {
        _setManager(newManager);
    }

    function addHolder(address newHolder) external onlyManager{
        if(totalHolders >= maxHolders){
            revert InvalidAddHolder(newHolder, maxHolders);
        }

        holder[newHolder] = true;
        totalHolders++;
        
    }

    modifier verifyManager(address _manager){
        if(_manager == address(0)){
           revert InvalidAddress(_manager);
        }
        _;
    }

    modifier onlyManager(){
        if(msg.sender != manager){
            revert InvalidOnlyManager(msg.sender);
        }

        _;
    }

    modifier onlyHolder(){
        if(holder[msg.sender] != true){
            revert InvalidHolder(msg.sender);
        }

        _;
    }
}