// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ETHcoin is ERC20{

    constructor()ERC20("Ethereum", "ETH"){
        _mint(_msgSender(), 20_000_000 *10 **18);
    }
}