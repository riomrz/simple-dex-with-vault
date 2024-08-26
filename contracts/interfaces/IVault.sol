// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IVault {
    function deposit(uint _amount) external;

    function withdraw(uint _shares) external;
}
