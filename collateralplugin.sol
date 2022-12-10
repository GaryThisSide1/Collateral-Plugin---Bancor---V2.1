pragma solidity ^0.6.0;

// Bancor reserve protocol collateral plugin smart contract
// This contract allows users to provide collateral for their reserve contributions on the Bancor network

// Import necessary libraries
import "https://github.com/bancorprotocol/contracts/BancorConverter.sol";
import "https://github.com/bancorprotocol/contracts/BancorConverterRegistry.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/Escrow.sol";

// Set contract as a BancorConverterRegistry plugin
contract BancorCollateralPlugin is BancorConverterRegistryPlugin {
    using SafeMath for uint256;
    using Escrow for address;

    // Define necessary variables
    BancorConverterRegistry public registry;
    mapping(address => Escrow) public escrowAccounts;
    mapping(address => uint256) public reserveCollateral;
    uint256 public collateralRequirement;
    uint256 public collateralLiquidationThreshold;
    address public collateralToken;

    // Constructor function to initialize the contract
    constructor(
        address _registry,
        uint256 _collateralRequirement,
        uint256 _collateralLiquidationThreshold,
        address _collateralToken
    ) public {
        // Set the BancorConverterRegistry contract address
        registry = BancorConverterRegistry(_registry);

        // Set the collateral requirement and liquidation threshold
        collateralRequirement = _collateralRequirement;
        collateralLiquidationThreshold = _collateralLiquidationThreshold;

        // Set the collateral token
        collateralToken = _collateralToken;
    }

    // Function to create a new reserve on the Bancor network
    // This function requires the reserve contributor to provide collateral for their reserve
    function createReserve(
        address _reserve,
        uint256 _reserveCollateral
    ) external {
        // Check that the reserve contributor has provided the required amount of collateral
        require(_reserveCollateral >= collateralRequirement, "Insufficient collateral provided");

        // Create an escrow account for the reserve contributor's collateral
        escrowAccounts[_reserve] = new Escrow();

        // Deposit the reserve contributor's collateral into the escrow account
        escrowAccounts[_reserve].deposit(_reserveCollateral);

        // Record the amount of collateral deposited by the reserve contributor
        reserveCollateral[_reserve] = _reserveCollateral;

        // Register the reserve with the BancorConverterRegistry contract
        registry.register(_reserve);
    }

    // Function to modify an existing reserve on the Bancor network
    // This function allows the reserve contributor to deposit additional collateral or withdraw excess collateral
    function modifyReserve(
        address _reserve,
        uint256 _reserveCollateral
    ) external {
        // Check that the reserve contributor has provided the required amount of collateral
    // Function to retrieve the current status of a reserve
function status(address _reserve) public view returns (string) {
    // Retrieve the reserve's current collateral balance
    uint256 reserveBalance = escrowAccounts[_reserve].balanceOf(collateralToken);

    // Check if the reserve's collateral balance is below the liquidation threshold
    if (reserveBalance < collateralLiquidationThreshold) {
        // Return "under-collateralized" if the reserve's collateral balance is below the liquidation threshold
        return "under-collateralized";
    } else {
        // Return "normal" if the reserve's collateral balance is above the liquidation threshold
        return "normal";
    }
}

// Function to retrieve the current price of a reserve's collateral
function price(address _reserve) public view returns (uint256) {
    // Retrieve the reserve's current collateral balance
    uint256 reserveBalance = escrowAccounts[_reserve].balanceOf(collateralToken);

    // Calculate and return the reserve's current collateral price
    return reserveCollateral[_reserve].div(reserveBalance);
}

