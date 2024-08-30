// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IVault {
    function calculateShares(uint256 _amount) external view returns (uint);
    function deposit(uint256 _amount) external;
    function withdraw(address to, uint _shares) external;
}
