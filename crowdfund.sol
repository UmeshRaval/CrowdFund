// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfund {
    address public creator;
    uint256 public goal;
    uint256 public deadline;
    mapping(address => uint256) public contributions;
    uint256 public totalContributions;
    bool public isFunded;
    bool public isCompleted;

    event GoalReached(uint totalContributions);
    event DeadlineReached(uint totalContributions);
    event FundTransfer(address backer, uint256 amount);

    constructor(uint256 fundingGoalInEther, uint256 durationInMinutes) {
        creator = msg.sender;
        goal = fundingGoalInEther * 1 ether;
        deadline = block.timestamp + durationInMinutes * 1 minutes;
        isFunded = false;
        isCompleted = false;
    }

    modifier onlyCreator() {
        require(
            msg.sender == creator,
            "Only the creator can ask for this function"
        );
        _;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Funding time is over.");
        require(!isCompleted, "Crowdfunding is already done");
        uint256 contribution = msg.value;
        contributions[msg.sender] += contribution;
        totalContributions += contribution;
        if (totalContributions >= goal) {
            isFunded = true;
            emit GoalReached(totalContributions);
        }
        emit FundTransfer(msg.sender, contribution);
    }

    function withdrawFunds() public onlyCreator {
        require(isFunded, "Goal reached then only withdraw");
        require(!isCompleted, "Crowdfunding already done");
        isCompleted = true;
        payable(creator).transfer(address(this).balance);
    }

    function getRefund() public {
        require(block.timestamp >= deadline, "Funding time incomplete");
        require(!isFunded, "The goal hasn't been reached");
        require(
            contributions[msg.sender] > 0,
            "No contribution left to be refunded"
        );
        uint256 contribution = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalContributions -= contribution;
        payable(msg.sender).transfer(contribution);
        emit FundTransfer(msg.sender, contribution);
    }

    function getCurrentBal() public view returns (uint256) {
        return address(this).balance;
    }

    function extendDeadline(uint256 durationInMinutes) public onlyCreator {
        deadline += durationInMinutes * 1 minutes;
    }
}
