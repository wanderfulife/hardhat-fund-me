//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error FundMe__NotOwner();

/** @title A contract for cornfunding
 * @author J. wndr
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our library
 */
contract FundMe {
    // Type declarations
    using PriceConverter for uint256;
    // State variables
    // Minimum funding value in USD
    uint256 public constant MINIMUM_USD = 10 * 1e18; // 1 * 10 ** 18
    // Array of addresses that have sent funds to the contract
    address[] private s_funders;
    // Mapping of addresses to the amount of funds they have sent to the contract
    mapping(address => uint256) private s_addressToAmountFunded;
    // The address of the contract owner
    address private immutable i_owner;
    AggregatorV3Interface private s_pricefeed;

    // Modifier that checks if the msg.sender is the contract owner
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    // Constructor sets the contract owner to the address that deployed the contract
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_pricefeed = AggregatorV3Interface(priceFeedAddress);
    }

    // What happen if someone send ETH to this contract without calling the fund() function
    // receive() external payable {
    //     fund();
    // }

    // fallback() external payable {
    //     fund();
    // }

    /**
     * @notice This function fund this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        // Check if the value sent is greater than or equal to the MINIMUM_USD constant
        require(
            msg.value.getConversionRate(s_pricefeed) >= MINIMUM_USD,
            "Didn't send enough"
        );
        // Add the sender's address to the funders array
        s_funders.push(msg.sender);
        // Add the amount sent to the addressToAmountFunded mapping
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    // Public function that can only be called by the contract owner
    function withdraw() public payable onlyOwner {
        // Iterate through the funders array
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            // Set the amount the funder has sent to 0 in the addressToAmountFunded mapping
            s_addressToAmountFunded[funder] = 0;
        }
        // Empty the funders array
        s_funders = new address[](0);

        // Try to transfer the remaining balance of the contract to the msg.sender
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            // Set the amount the funder has sent to 0 in the addressToAmountFunded mapping
            s_addressToAmountFunded[funder] = 0;
        }
        // Empty the funders array
        s_funders = new address[](0);

        // Try to transfer the remaining balance of the contract to the msg.sender
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_pricefeed;
    }
}
