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

    event Bought(uint256 tokenAmountToBuy);
    event Sold(uint256 tokenAmountToBuy);

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
     * @param _amount eth tokenAmountToBuy
     */
    function vaultMovs(address _to, uint256 _amount) internal {
        (bool sent, ) = payable(_to).call{value: _amount}("");
        if (!sent) {
            revert ethNotSent();
        }
    }

    /**
     * @dev ETH to token exchange: ETH are sent to the Vault and tokens are minted on the receiver address
     */
    function buyToken() public payable {
        if (externalVault == address(0)) {
            revert invalidVaultAddress();
        }
        uint256 ethAmountToBuy = msg.value;
        if (ethAmountToBuy == 0) {
            revert invalidAmount();
        }

        ethPrice = uint256(ethUsdContract.getLatestPrice());
        uint tokenAmountToSend = (ethAmountToBuy * ethPrice) / (10 ** ethPriceDecimals);

        // ETH received are sent to Vault which calls the deposit() method
        vaultMovs(externalVault, ethAmountToBuy);

        // Mint Token on the sender address
        IToken(token).mint(msg.sender, tokenAmountToSend);

        emit Bought(tokenAmountToSend);
    }

    /**
     * @dev token to ETH exchange: token are burned on the sender address and ETH are withdrawn from the Vault based on shares
     * @param tokenAmountToBuy token tokenAmountToBuy
     */
    function sellToken(uint256 tokenAmountToBuy) public {
        if (tokenAmountToBuy == 0) {
            revert invalidAmount();
        }
        if (IERC20(token).balanceOf(msg.sender) < tokenAmountToBuy) {
            revert invalidUserBalance();
        }

        ethPrice = uint256(ethUsdContract.getLatestPrice());
        uint256 ethAmountToSend = (tokenAmountToBuy * (10 ** ethPriceDecimals)) / ethPrice;

        if (address(externalVault).balance < ethAmountToSend) {
            revert notEnoughBalance();
        }

        // Burn Token on the sender address
        IToken(token).burn(msg.sender, tokenAmountToBuy);

        // Calculate share and withdraw from Vault
        uint shares = IVault(externalVault).calculateShares(ethAmountToSend);
        IVault(externalVault).withdraw(msg.sender, shares);

        emit Sold(tokenAmountToBuy);
    }
}
