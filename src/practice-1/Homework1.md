# ERC1363 and ERC777

The two standards above were introduced in order to "extend" the capabilities of the original fungible-token standard, ERC20.
ERC20 is limited because the `transfer` and `transferFrom` methods do not interact with receiving contracts at all, therefore, a receiving contract cannot know/do anything with the acquired tokens programmatically. A new transaction must be initiated in order to perform any actions going forward.

ERC1363 was designed to extend ERC20 but without modifying its existing functionality, but rather to introduce new functions that can enhance the experience.
Unlike ERC777 which introduces hooks to the existing functions, ERC1363 just uses new functionality, thus it does not need to worry about backwards compatibility issues or issues with the tokens elsewhere.

ERC777 introduced a vulnerability to protocols that were not expecting their tokens to call other contracts. This introduced reentrancy, such as in the case of the imBTC hack.
