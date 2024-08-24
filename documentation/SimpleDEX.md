# Solidity API

## SimpleDEX


### token

```solidity
address token
```


### externalTreasury

```solidity
address externalTreasury
```


### ethUsdContract

```solidity
contract PriceConsumerV3 ethUsdContract
```


### ethPriceDecimals

```solidity
uint256 ethPriceDecimals
```


### ethPrice

```solidity
uint256 ethPrice
```


### Bought

```solidity
event Bought(uint256 amount)
```


### Sold

```solidity
event Sold(uint256 amount)
```


### constructor

```solidity
constructor(address _token, address oracleEthUsdPrice) public
```


### receive

```solidity
receive() external payable
```


### setTreasury

```solidity
function setTreasury(address _treasury) external
```

_set a treasury for simple DEX_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _treasury | address | treasury address |


### treasuryMovs

```solidity
function treasuryMovs(address _to, uint256 _amount) internal
```

transfer ETH to treasury (internal)

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _to | address | receiver address |
| _amount | uint256 | eth amount |


### buyToken

```solidity
function buyToken() public payable
```

_eth to token exchange_


### sellToken

```solidity
function sellToken(uint256 amount) public
```

_token to ETH exchange_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | token amount |



