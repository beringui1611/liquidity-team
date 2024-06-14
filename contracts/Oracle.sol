// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Oracle {

    address public btc;
    address public eth;
    address public usdc;
    address public bnb;

    uint256 public btcFeed = 67260;
    uint256 public ethFeed = 3500;
    uint256 public usdcFeed = 1;
    uint256 public bnbFeed = 600;

    mapping(address => uint256) dataFeed;

    constructor(
        address btcAddress, 
        address ethAddress, 
        address usdcAddress, 
        address bnbAddress){
        
        btc = btcAddress;
        eth = ethAddress;
        usdc = usdcAddress;
        bnb = bnbAddress;

        getFeedBtc();
        getFeedEth();

    }

    function getFeedBtc() public {

        assembly {
            sstore(btcFeed.slot, 67260)
        }

        dataFeed[btc] = btcFeed;
    }

    function getFeedEth() public {

        assembly {
            sstore(ethFeed.slot, 3500)
        }

        dataFeed[eth] = ethFeed;
    }

    function getTknDataFeed(address token) public view returns(uint256){
        return dataFeed[token];
    }
}

