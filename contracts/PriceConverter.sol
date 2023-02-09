// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Library to convert ETH to USD
library PriceConverter {
    // Retrieves the latest price of ETH in terms of USD from a specific price feed contract (AggregatorV3Interface)
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Address of the price feed contract
        // Retrieves the latest price data from the price feed contract
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH in terms of USD
        //3000.00000000 8 Decimals
        return uint256(price * 1e10); // 1**10 == 10000000000
    }

    // Converts input ETH amount to USD
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Retrieves the current ETH price in USD
        uint256 ethPrice = getPrice(priceFeed);
        // Calculates the equivalent USD value of the input ETH amount
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }
}
