The SafeERC20 library exists because the ERC20 token standard is loosely defined and therefore, not all tokens behave the same way.
In order to mitigate some of the issues (returns/reverts for example), the SafeERC20 library was introduced. Under the hood, this library is checking whether the transfer/approve has reverted/has returned false and will in turn revert to the user. Non-reverts mean the call went through.

Arguably, SafeERC20 should be use everywhere someone might be using ERC20 tokens, as for example, USDT, one of the most common tokens out there does not return a boolean and this causes issues for protocols such as Aave if not using SafeERC20.
