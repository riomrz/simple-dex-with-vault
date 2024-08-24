# Solidity API

## PriceConsumerV3


### priceFeed

```solidity
contract AggregatorV3Interface priceFeed
```


### constructor

```solidity
constructor(address clOracleAddress) public
```

Network: Goerli
Aggregator: ETH/USD
Address: 0xD4a33860578De61DBAbDc98FD742fA7028e
0x0d79df66BE487753B02D015Fb622DED7f0E9798d   DAI/USD
0x9F6d70CDf08d893f0063742b51d3E9D1e18b7f74   Azuki/eth


### getLatestPrice

```solidity
function getLatestPrice() public view returns (int256)
```

Returns the latest price.


### getPriceDecimals

```solidity
function getPriceDecimals() public view returns (uint256)
```



