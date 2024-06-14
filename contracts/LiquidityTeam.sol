// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./Manager.sol";
import "./Oracle.sol";
import "./IErrorInterface.sol";
import "hardhat/console.sol";

contract LiquidityTeam is ERC20, Manager, Oracle, IErrorInterface {

    event RequestPosition(address indexed holder, uint256 quantity, address indexed token);

    struct Positions {
        mapping(address => uint256) tokens;
    }

    struct RemovePosition {
        uint256 time;
        uint256 quantity;
    }

    mapping(address => Positions) positionHolder;
    mapping(address => RemovePosition) public requestPositionTime;

    uint256 priceQuota;        
    
    constructor(
    string memory name, 
    string memory symbol,
    address btc,
    address eth,
    address usdc,
    address bnb,
    uint256 price,
    uint32 mxHolders
    )
    ERC20(name, symbol)
    Oracle(btc, eth, usdc, bnb)
    Manager(mxHolders)
    {
        _mint(_msgSender(), 0 * 10 **decimals());
        priceQuota = price;

    }
    
    function createPosition(address token, uint256 quantity) external onlyHolder { //@info quando criar a posição colocar os dois tokens do lp ou um só

        uint256 feed = getTknDataFeed(token);
        IERC20 tkn = IERC20(token);
        

        if(feed != 0){
          tkn.transferFrom(_msgSender(), address(this), quantity);

          uint256 tokenInUsd = quantity * feed / 10 ** decimals();
          uint256 quota = tokenInUsd / priceQuota;

          console.log(tx.gasprice * gasleft());
         
          _mint(msg.sender, quota *10 **decimals());
          positionHolder[_msgSender()].tokens[token] += quantity;

        }
        else {
            revert TokenNotExist(token);
        }
    }

    function removePosition(address token, uint256 quantity) external onlyHolder {
        uint256 feed = getTknDataFeed(token);
        IERC20 tkn = IERC20(token);

        if(feed != 0){
            if(positionHolder[_msgSender()].tokens[token] != 0){
                uint256 tokenOutUsd = quantity * feed / 10 **decimals();
                uint256 quota = tokenOutUsd / priceQuota;
                

                if(tkn.balanceOf(address(this)) >= quantity){
                    tkn.transfer(_msgSender(), quantity);
                    _burn(_msgSender(), quota *10 **decimals());
                    positionHolder[_msgSender()].tokens[token] -= quantity;
                }
                else {
                    requestPositionTime[msg.sender].time = block.timestamp;
                    requestPositionTime[msg.sender].quantity = quantity;
                    emit RequestPosition(_msgSender(), quantity, token);
                }

            }
            else{
                revert InvalidRemovePosition(quantity);
            }
        }
    }

    function createPool(address factory, address tokenA, address tokenB, uint24 fee) external onlyManager returns(address){
       address newPool = IUniswapV3Factory(factory).createPool(tokenA, tokenB, fee);

       return newPool;
    }

    function addLiquidty(
        address positionManager,
        address tokneA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper
    )
    onlyManager
    external {
        IERC20(tokneA).approve(positionManager, amountA);
        IERC20(tokenB).approve(positionManager, amountB);

        INonfungiblePositionManager(positionManager).mint(
            INonfungiblePositionManager.MintParams({
                token0: tokneA,
                token1: tokenB,
                fee: fee,
                tickLower: tickLower, 
                tickUpper: tickUpper,
                amount0Desired: amountA,
                amount1Desired: amountB,
                amount0Min: 0, 
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 15
            })
        );
    }

    function addMoreLiquidityAnyTokens(
        address positionManager,
        address tokenA,
        address tokenB,
        uint256 tokenId,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) 
    external onlyManager {
        IERC20(tokenA).approve(positionManager, amount0Desired);
        IERC20(tokenB).approve(positionManager, amount1Desired);

        INonfungiblePositionManager(positionManager).increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0, 
                amount1Min: 0,
                deadline: block.timestamp + 15
            })
        );
    }

}

