// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PriceConsumer.sol";
import "./interfaces/IErrors.sol";
import "./interfaces/IToken.sol";
import "./interfaces/IVault.sol";

contract SimpleDEX is Ownable, IErrors {
    address public token;
    address public externalVault;

    PriceConsumerV3 public ethUsdContract;
    uint256 public ethPriceDecimals;
    uint256 public ethPrice;

    event Bought(uint256 amount);
    event Sold(uint256 amount);

    constructor(address _token, address oracleEthUsdPrice) {
        token = _token;
        ethUsdContract = new PriceConsumerV3(oracleEthUsdPrice);
        ethPriceDecimals = ethUsdContract.getPriceDecimals();
    }

    /**
     * @dev ETH sent to this contract are managed by the buyToken() method
     */
    receive() external payable {
        buyToken();
    }
    
    /**
     * @dev set a vault for simple DEX
     * @param _vault address
     */
    function setVault(address _vault) external onlyOwner {
        if (_vault == address(0)) {
            revert invalidAddress();
        }

        externalVault = _vault;
    }

    /**
     * @notice transfer ETH to vault
     * @param _to receiver address
     * @param _amount eth amount
     */
    /* function treasuryMovs(address _to, uint256 _amount) internal {
        (bool sent, ) = payable(_to).call{value: _amount}("");
        if (!sent) {
            revert ethNotSent();
        }
    } */

    /**
     * @dev ETH to token exchange
     */
    function buyToken() public payable {
        if (externalVault == address(0)) {
            revert invalidVaultAddress();
        }
        uint256 amountToBuy = msg.value;
        if (amountToBuy == 0) {
            revert invalidAmount();
        }

        ethPrice = uint256(ethUsdContract.getLatestPrice());
        uint amountToSend = (amountToBuy * ethPrice) / (10 ** ethPriceDecimals);

        // FIXME: Send ETH to Vault or only the token minted? Maybe send ETH to Treasury and token to Vault
        // vaultMovs(externalVault, amountToBuy);
        tx = await assetContract.approve(externalVault.address, toWei(100000), {from:msg.sender})
        IVault(externalVault).deposit(amountToBuy);

        // Mint Token on the sender address
        IToken(token).mint(msg.sender, amountToSend);

        emit Bought(amountToSend);
    }

    /**
     * @dev shares to ETH exchange
     * @param amount shares amount
     */
    function sellToken(uint256 amount) public {
        if (amount == 0) {
            revert invalidAmount();
        }
        if (IERC20(token).balanceOf(msg.sender) < amount) {
            revert invalidUserBalance();
        }

        ethPrice = uint256(ethUsdContract.getLatestPrice());
        // uint256 amountToSend = (amount * (10 ** ethPriceDecimals)) / ethPrice;

        IToken(token).burn(msg.sender, amount);

        // FIXME: externalVault.totalSupply?
        if (address(externalVault).balance < amount) {
            revert notEnoughBalance();
        }

        // vaultMovs(msg.sender, amountToSend);
        IVault(externalVault).withdraw(amount);

        emit Sold(amount);
    }
}
