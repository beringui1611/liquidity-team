// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

contract IErrorInterface {

    error TokenNotExist(address tkn);
    error InvalidRemovePosition(uint256 amount);
}