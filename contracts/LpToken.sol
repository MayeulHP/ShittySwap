// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract lpToken is ERC20, Ownable {
    constructor(string memory name, string memory ticker) ERC20(name, ticker) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function getBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}
