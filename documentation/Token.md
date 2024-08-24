# Solidity API

## Token


### minterAddress

```solidity
address minterAddress
```


### constructor

```solidity
constructor(string _tokenName, string _tokenSymbol, uint256 _supply) public
```


### onlyMinter

```solidity
modifier onlyMinter()
```


### setMinter

```solidity
function setMinter(address minter) external
```


### mint

```solidity
function mint(address _to, uint256 _amount) external
```


### burn

```solidity
function burn(address _from, uint256 _amount) external
```



