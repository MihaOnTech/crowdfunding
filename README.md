# Crowdfunding

Crowdfunding app using web3 technologies.

## Smart Contract

This Solidity smart contract demonstrates a simple crowdfunding platform where users can create campaigns, contribute funds, and, if necessary, reclaim their contributions if the campaign does not meet its funding goal. Below is a detailed explanation of the contract’s components, including internal variables, functions, events, and other relevant mechanics.

### Internal Variables

- **Campaign struct**:
  - `creator (address payable)`: The address of the person who creates the campaign. It is marked as payable to allow refunds directly to this address.
  - `description (string)`: A textual description of the campaign.
  - `goal (uint)`: The financial goal of the campaign in wei (the smallest denomination of ether).
  - `fundedAmount (uint)`: Tracks the amount of ether raised by the campaign.
  - `deadline (uint)`: The UNIX timestamp (in seconds) denoting when the campaign will no longer accept funds.

- `numCampaigns (uint)`: A counter tracking the number of campaigns created. This is used as an index for new campaigns.

- `campaigns (mapping(uint => Campaign))`: A mapping from a campaign ID to a Campaign struct, storing all details of each campaign.

- `contributions (mapping(address => mapping(uint => uint)))`: A nested mapping that records the amount of ether each address has contributed to each campaign.

### Functions

- **`createCampaign(string memory description, uint goal, uint duration)`**:
  - **Accessibility**: Anyone can execute.
  - **Costs**: Consumes gas as it updates state variables (numCampaigns and campaigns).
  - **Purpose**: Allows a user to create a new crowdfunding campaign.
  - **Parameters**: `description`: Description of the campaign; `goal`: Funding goal in wei; `duration`: Duration in seconds for which the campaign will run.
  - **Mechanism**: Adds a new Campaign to the campaigns mapping and increments numCampaigns.

- **`fundCampaign(uint campaignID)`**:
  - **Accessibility**: Anyone can execute.
  - **Costs**: Transaction must include ETH (payable). Consumes gas for updating the fundedAmount and contributions.
  - **Purpose**: Allows a user to contribute ether to a specific campaign.
  - **Parameter**: `campaignID`: The ID of the campaign to fund.

- **`refundCampaign(uint campaignID)`**:
  - **Accessibility**: Can only be executed by contributors to that specific campaign.
  - **Costs**: Consumes gas. Involves the transfer of ether if conditions are met.
  - **Purpose**: Refunds contributors if the campaign has ended without reaching its goal.
  - **Parameter**: `campaignID`: The ID of the campaign for which to claim a refund.

- **`getCampaign(uint campaignID) public view returns (Campaign memory)`**:
  - **Accessibility**: Anyone can view.
  - **Costs**: No gas cost when called externally (view function).
  - **Purpose**: Retrieves details of a specific campaign.
  - **Parameter**: `campaignID`: The ID of the campaign to retrieve.

### Events

Events in a Solidity contract provide an efficient way to emit logs that front-end applications and listening services can capture off-chain. This facilitates tracking of operations within the contract without incurring the cost of state-reading transactions. Below are the events defined in the crowdfunding contract:

- **`CampaignCreated`**:
  - **Triggered**: When a new campaign is created.
  - **Data**: Includes the `campaignID`, `creator`, `description`, `goal`, and `deadline` of the campaign.

- **`CampaignFunded`**:
  - **Triggered**: When a contribution is made to a campaign.
  - **Data**: Includes the `campaignID`, `contributor`, and the `amount` contributed.

- **`FundsRefunded`**:
  - **Triggered**: When a refund is issued.
  - **Data**: Includes the `campaignID`, `contributor`, and the `amount` refunded.
