# Simple DEX with Vault

Multiple scenarios:

1) SimpleDEX mints and burns "token" when someone want to buy/sell: in this case the Vault is a store of value of only ETH;

2) SimpleDEX is a pool of liquidity of 2 tokens, ETH and "token": in this case, the Vault has to contain multiple asset at a time, ETH and "token", as it is a store of value for the SimpleDEX and the DEX manages 2 assets at a time.

In order to maintain the original concept of mint/burn of "token" we opt for the first scenario. So we replace the Treasury with a Vault contract.