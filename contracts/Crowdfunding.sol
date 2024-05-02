// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Crowdfunding {
    
    // Add a state variable to act as a reentrancy guard
    bool private locked = false;

    // Modifier to prevent reentrancy
    modifier noReentrancy() {
        require(!locked, "Reentrant call detected!");
        locked = true;
        _;
        locked = false;
    }
    
    struct Campaign {
        address payable creator;
        string description;
        uint goal;
        uint fundedAmount;
        uint deadline;
        bool isOpen;
    }

    uint public numCampaigns;
    mapping(uint => Campaign) public campaigns;
    mapping(address => mapping(uint => uint)) public contributions;

    // Events to emit results of actions
    event CampaignCreated(uint indexed campaignID, address indexed creator, string description, uint goal, uint deadline);
    event CampaignFunded(uint indexed campaignID, address indexed contributor, uint amount);
    event FundsRefunded(uint indexed campaignID, address indexed contributor, uint amount);
    event CampaignClosed(uint indexed campaignID, bool success);

    // Function to create a new crowdfunding campaign
    function createCampaign(string memory description, uint goal, uint duration) external {
        uint deadline = block.timestamp + duration;
        campaigns[numCampaigns] = Campaign({
            creator: payable(msg.sender),
            description: description,
            goal: goal,
            fundedAmount: 0,
            deadline: deadline,
            isOpen: true
        });
        emit CampaignCreated(numCampaigns, msg.sender, description, goal, deadline);
        numCampaigns++;
    }

    // Function to fund a specific campaign
    function fundCampaign(uint campaignID) external payable {
        require(campaigns[campaignID].isOpen, "Campaign is closed");
        require(block.timestamp < campaigns[campaignID].deadline, "Campaign has ended");
        require(msg.value > 0, "Funding amount must be greater than 0");

        Campaign storage campaign = campaigns[campaignID];
        campaign.fundedAmount += msg.value;
        contributions[msg.sender][campaignID] += msg.value;
        emit CampaignFunded(campaignID, msg.sender, msg.value);
    }

    // Function to allow contributors to retrieve their funds if the campaign does not reach its goal
    function refundCampaign(uint campaignID) external noReentrancy  {
        Campaign storage campaign = campaigns[campaignID];
        require(!campaign.isOpen && block.timestamp > campaign.deadline, "Campaign is not over yet or still open");
        require(campaign.fundedAmount < campaign.goal, "Campaign funding goal was met");

        uint amountContributed = contributions[msg.sender][campaignID];
        require(amountContributed > 0, "No contributions found");

        contributions[msg.sender][campaignID] = 0;
        payable(msg.sender).transfer(amountContributed);
        emit FundsRefunded(campaignID, msg.sender, amountContributed);
    }

    // Function for campaign creators to withdraw funds when goals are met
    function withdrawFunds(uint campaignID) external noReentrancy {
        Campaign storage campaign = campaigns[campaignID];
        require(msg.sender == campaign.creator, "Only the creator can withdraw funds");
        require(campaign.fundedAmount >= campaign.goal, "Funding goal not reached");
        require(campaign.isOpen, "Campaign is not open");

        uint amount = campaign.fundedAmount;
        campaign.fundedAmount = 0;
        campaign.isOpen = false;
        campaign.creator.transfer(amount);
        emit CampaignClosed(campaignID, true);
    }

    // Function to get the details of a campaign
    function getCampaign(uint campaignID) external view returns (Campaign memory) {
        return campaigns[campaignID];
    }
}
