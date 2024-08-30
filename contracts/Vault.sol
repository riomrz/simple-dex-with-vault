// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IErrors.sol";

contract Vault is IVault, IErrors {
    IERC20 public token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /* function initialize(address _token) public initializer {
        token = IERC20(_token);
    } */

    /**
     * @dev annotates the number of shares of an address (not a real mint)
     * @param _to receiver address
     * @param _shares amount of shares to mint
     */
    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    /**
     * @param _from sender address
     * @param _shares amount of shares to burn
     */
    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    /**
     * @dev ETH sent to Vault invoke receive() which demands to deposit() the shares calculation
     */
    receive() external payable {
        deposit(msg.value);
    }

    /**
     * @dev calculates shares number
     * @param _amount ETH amount
     */
    function calculateShares(uint256 _amount) public view returns (uint) {
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / address(this).balance;
        }
        return shares;
    }

    /**
     * @dev calculates and "mints" new shares
     * @param _amount ETH amount to deposit
     */
    function deposit(uint256 _amount) public {
        /*
        a = amount
        B = balance of token before deposit
        T = total suplly
        s = shares to mint
        
        (T + s) / T = (a + B) / B

        s = aT / B
        */
        uint shares = calculateShares(_amount);

        // Mint shares of SimpleDEX
        _mint(msg.sender, shares);
    }

    /**
     * @dev burns shares received and sends ETH to the user
     * @param to receiver address
     * @param _shares number of shares to withdraw
     */
    function withdraw(address to, uint _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B

        a = sB / T
        */
        uint amount = (_shares * address(this).balance) / totalSupply;
        if (address(this).balance < amount) {
            revert notEnoughBalance();
        }

        // Burn shares of SimpleDEX
        _burn(msg.sender, _shares);

        // Send back ETH to the USER
        (bool sent, ) = payable(to).call{value: amount}("");
        if (!sent) {
            revert ethNotSent();
        }
    }
}
