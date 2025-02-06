// SPDX-License-Identifier: No-License

pragma solidity 0.8.27;

contract BondingCurve {
    uint256 public constant MAX_SUPPLY = 1_000_000_000 ether;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant PRICE_INCREMENT = 0.00001 ether;
    uint256 public constant MAX_GAS_PRICE = 50 gwei;

    uint256 public totalSupply;
    uint256 public locked = 1;
    address public owner;
    bool public bonded;

    event TokenBought(address indexed owner, uint256 amount);
    event TokenSold(address indexed owner, uint256 amount);

    error FailedToSendETH();
    error InsufficientAmount();
    error InvalidAmount();
    error MaxSupplyExceeded();
    error Reentrancy();
    error Sandwich();

    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    modifier reentrancyGuard() {
        if (locked > 1) revert Reentrancy();
        locked = 2;
        _;
        locked = 1;
    }

    function buy(uint256 amount) external payable {
        if (tx.gasprice > MAX_GAS_PRICE) revert Sandwich();
        if (amount < 1) revert InvalidAmount();
        if (totalSupply + amount > MAX_SUPPLY) revert MaxSupplyExceeded();

        uint256 cost = _calculatePurchaseAmount(amount);
        if (msg.value < cost) revert InsufficientAmount();

        balances[msg.sender] += amount;
        totalSupply += amount;

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }

        emit TokenBought(msg.sender, amount);
    }

    function sell(uint256 amount) external reentrancyGuard {
        uint256 refund = _calculateSellAmount(amount);

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        (bool ok,) = payable(msg.sender).call{value: refund}("");

        if (!ok) revert FailedToSendETH();

        emit TokenSold(msg.sender, amount);
    }

    function _calculatePurchaseAmount(uint256 amount) internal view returns (uint256) {
        uint256 startPrice = INITIAL_PRICE + (PRICE_INCREMENT * totalSupply);
        uint256 endPrice = startPrice + (PRICE_INCREMENT * (amount - 1));
        return (amount * (startPrice + endPrice)) / 2;
    }

    function _calculateSellAmount(uint256 amount) internal view returns (uint256) {
        if (amount < 1 || amount > balances[msg.sender]) revert InvalidAmount();

        uint256 startPrice = INITIAL_PRICE + (PRICE_INCREMENT * (totalSupply - amount));
        uint256 endPrice = startPrice + (PRICE_INCREMENT * (amount - 1));
        return (amount * (startPrice + endPrice)) / 2;
    }
}
