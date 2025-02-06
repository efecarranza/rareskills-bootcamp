# How does ERC721A save gas?

ERC721A saves gas when minting by optimizing in a few areas:

It only updates state once in storage. For example, if a user mints 5 tokens, they add 5 once, instead of adding 1 five times.
The same goes for token owners since their IDs are sequential for NFTs.

Also, they remove some of the extra mappings that are used to more easily read from the contract storage, like some mappings for owners and balances.

# Where does it add cost?

The cost is then passed on to the read functions, which usually happens off-chain. The idea is that users will pay less to mint and then they will read using off-chain solutions. Contracts interacting with the 721A contracts will have to pay more to check balances/ownership on chain however.
