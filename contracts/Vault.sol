// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IErrors.sol";
import {console} from "hardhat/console.sol";

contract Vault is IVault, IErrors {
    IERC20 public token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    // uint public shares

    constructor(address _token) {
        token = IERC20(_token);
    }

    /* function initialize(address _token) public initializer {
        token = IERC20(_token);
    } */

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
        console.log("----- mint balanceOf sender: ", balanceOf[_to]);
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
        console.log("----- burn balanceOf sender: ", balanceOf[_from]);
    }

    receive() external payable {
        console.log("----- receive:", msg.value);
        deposit(msg.value);
    }

    function deposit(uint256 _amount) public {
        /*
        a = amount
        B = balance of token before deposit
        T = total suplly
        s = shares to mint
        
        (T + s) / T = (a + B) / B

        s = aT / B
        */
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / address(this).balance;
        }

        _mint(msg.sender, shares);
    }

    function withdraw(uint _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B

        a = sB / T
        */
        uint amount = (_shares * address(this).balance) / totalSupply;
        console.log("----- withdraw amount: ", amount);

        _burn(msg.sender, _shares);

        console.log("----- address(this).balance: ", address(this).balance);
        if (address(this).balance < amount) {
            revert notEnoughBalance();
        }

        // FIXME: send back ETH to msg.sender
        // for some reason next instruction send the ETH to this (Vault) conctract and calls the receive() method:
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        if (!sent) {
            revert ethNotSent();
        }
        console.log("ETH sent back to msg.sender");
    }
}
