import "./interfaces/IErrors.sol";
import "./interfaces/ITreasury.sol";

contract Treasury is IErrors, ITreasury {
    address public owner;
    address public simpleDexAddress;

    constructor(address simpleDEX) {
        if (simpleDEX == address(0)) {
            revert invalidAddress();
        }
        owner = msg.sender;
        simpleDexAddress = simpleDEX;
    }

    /**
     * @dev token sent to the treasury stay in the treasury
     */
    receive() external payable {}

    modifier onlySimpleDEX() {
        // require(msg.sender == sempleDexAddress, "not a simple DEX");
        if (msg.sender != simpleDexAddress) {
            revert notSimpleDEX();
        }
        _;
    }

    function withdraw(address to, uint256 amount) external onlySimpleDEX {
        (bool sent, ) = payable(to).call{value: amount}("");
        if (!sent) {
            revert ethNotSent();
        }
    }
}
