// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Pool.sol";

contract ShittySwap {
    Pool[] public pools;

    event someValue(uint value);

    function addPool(address tokenA, address tokenB) public {
        lpToken newLp = new lpToken("ShittyLP", "SLP");
        pools.push(Pool(IERC20(tokenA), IERC20(tokenB), 0, 0, newLp));
    }

    function addLiquidity(
            uint pool,
            IERC20 tokenA,
            IERC20 tokenB,
            uint qtyA,
            uint qtyB,
            bool freeLiquidity
        ) public {
        require(pool < pools.length, "Pool does not exist");

        Pool storage swapPool = pools[pool];

        bool isPoolValid = (swapPool.tokenA == tokenA && swapPool.tokenB == tokenB)
                        || (swapPool.tokenB == tokenA && swapPool.tokenA == tokenB);
        require(isPoolValid, "Pool is not valid");

        require(tokenA.allowance(msg.sender, address(this)) >= qtyA, "Need approval for token A");
        require(tokenB.allowance(msg.sender, address(this)) >= qtyB, "Need approval for token B");

        if (swapPool.tokenA == tokenA) {
            swapPool.tokenALocked += qtyA;
            swapPool.tokenBLocked += qtyB;
        } else {
            swapPool.tokenALocked += qtyB;
            swapPool.tokenBLocked += qtyA;
        }

        bool sentA = tokenA.transferFrom(msg.sender, address(this), qtyA);
        bool sentB = tokenB.transferFrom(msg.sender, address(this), qtyB);
        require(sentA && sentB, "Token transfer failed");

        if (!freeLiquidity) {
            uint lpTokensToMint = 1 * 10 ** 18;
            if (swapPool.tokenALocked + swapPool.tokenBLocked != 0 && (qtyA + qtyB) != (swapPool.tokenALocked + swapPool.tokenBLocked)) {
               //lpTokensToMint = (((qtyA + qtyB) / (swapPool.tokenALocked + swapPool.tokenBLocked)) * swapPool.lpToken.totalSupply()) / (1 - ((qtyA + qtyB) / (swapPool.tokenALocked + swapPool.tokenBLocked)));
               lpTokensToMint = (qtyA + qtyB) * swapPool.lpToken.totalSupply() / (swapPool.tokenALocked + swapPool.tokenBLocked);
            }
            swapPool.lpToken.mint(msg.sender, lpTokensToMint);
        }
    }

    function swap(uint pool, bool firstToken, uint amount) public {
        require(pool < pools.length, "Pool is not valid");

        Pool memory swapPool = pools[pool];
        IERC20 incomingToken = firstToken ? swapPool.tokenA : swapPool.tokenB;
        require(incomingToken.allowance(msg.sender, address(this)) >= amount, "Need approval for token");

        IERC20 outgoingToken = firstToken ? swapPool.tokenB : swapPool.tokenA;
        uint incomingTokenCurrentQty = firstToken ? swapPool.tokenALocked : swapPool.tokenBLocked;
        uint outGoingTokenCurrentQty = !firstToken ? swapPool.tokenALocked : swapPool.tokenBLocked;

        uint toGive = (outGoingTokenCurrentQty * amount / incomingTokenCurrentQty);

        require(toGive < outGoingTokenCurrentQty, "Not enough liquidity");
        require(toGive > 0, "Nothing to give");

        emit someValue(toGive);

        addLiquidity(pool, incomingToken, outgoingToken, amount, 0, true);

        if (firstToken) {
            pools[pool].tokenBLocked -= toGive;
        } else {
            pools[pool].tokenALocked -= toGive;
        }

        bool sent = outgoingToken.transfer(msg.sender, toGive);
        require(sent, "Failed to send tokens");
    }

    function withdrawLiquidity(uint pool) public {
        require(pool < pools.length, "Pool not valid");

        Pool memory swapPool = pools[pool];

        uint lpBalance = swapPool.lpToken.balanceOf(msg.sender);

        require(lpBalance > 0, "No LPs for this pool");

        require(swapPool.lpToken.allowance(msg.sender, address(this)) >= lpBalance, "Need approval for LP");

        uint tokenAtoSend = (lpBalance * swapPool.tokenALocked) / swapPool.lpToken.totalSupply();
        uint tokenBtoSend = (lpBalance * swapPool.tokenBLocked) / swapPool.lpToken.totalSupply();

        pools[pool].tokenALocked -= tokenAtoSend;
        pools[pool].tokenBLocked -= tokenBtoSend;

        swapPool.lpToken.burn(msg.sender, lpBalance);

        bool sentA = swapPool.tokenA.transfer(msg.sender, tokenAtoSend);
        bool sentB = swapPool.tokenB.transfer(msg.sender, tokenBtoSend);

        require(sentA && sentB, "Failed to send a token");
    }
}
