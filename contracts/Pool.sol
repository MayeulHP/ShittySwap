// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./LpToken.sol";

struct Pool {
    IERC20 tokenA;
    IERC20 tokenB;

    uint256 tokenALocked;
    uint256 tokenBLocked;

    lpToken lpToken;
}
