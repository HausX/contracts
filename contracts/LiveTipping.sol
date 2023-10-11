// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IDistributor {
    function distributeFunds(
        uint eventId,
        address creator,
        address curator,
        uint curatorCut
    ) external payable;
}

contract LiveTipping is Ownable {
    address public eventFactoryContract;
    address public ticketFactoryContract;
    IDistributor public distributorContract;

    struct Event {
        address creator;
        uint startTime;
        address highestTipper;
        uint baseTip;
        uint highestTip;
        uint totalTips;
        uint curatorCut;
        bool isEventOver;
    }

    mapping(uint => Event) public events;
    mapping(uint=>uint) public ticketPurchases;
    mapping(uint => mapping(address => uint)) public tipPerEvent;

    event LiveTippingCreated(
        uint indexed eventId,
        uint startTime,
        uint baseTip,
        uint curatorCut
    );
    event Tipped(
        uint indexed eventId,
        address indexed tipper,
        uint amount,
        bool isHighestTip
    );

    modifier onlyEventFactory() {
        require(eventFactoryContract != address(0), "not initialized");
        require(
            msg.sender == eventFactoryContract,
            "Only the event factory can call this function"
        );
        _;
    }

    modifier onlyTicketFactory()
    {
        require(ticketFactoryContract!=address(0),"not initialized");
        require(msg.sender==ticketFactoryContract,"Invalid sender");
        _;
    }
    function initialize(
        address _eventFactoryContract,
        IDistributor _distributorContract,
        address _ticketFactory
    ) public onlyOwner {
        eventFactoryContract = _eventFactoryContract;
        distributorContract = _distributorContract;
        ticketFactoryContract=_ticketFactory;
    }

    function createLiveTipping(
        uint eventId,
        address creator,
        uint startTime,
        uint baseTip,
        uint curatorCut
    ) public onlyEventFactory {
        events[eventId] = Event(
            creator,
            startTime,
            address(0),
            baseTip,
            0,
            0,
            curatorCut,
            false
        );
        emit LiveTippingCreated(eventId, startTime, baseTip, curatorCut);
    }

    function tipEvent(uint eventId) public payable {
        require(
            block.timestamp > events[eventId].startTime,
            "Event has not started"
        );
        require(msg.value > events[eventId].baseTip, "Tip is too low");
        require(!events[eventId].isEventOver, "Event is over");
        tipPerEvent[eventId][msg.sender] += msg.value;
        events[eventId].totalTips += msg.value;

        if (tipPerEvent[eventId][msg.sender] > events[eventId].highestTip) {
            events[eventId].highestTipper = msg.sender;
            events[eventId].highestTip = tipPerEvent[eventId][msg.sender];
            emit Tipped(eventId, msg.sender, msg.value, true);
        }
        emit Tipped(eventId, msg.sender, msg.value, false);
    }

    function ticketPurchaseDeposit(uint eventId)external payable onlyTicketFactory{
        ticketPurchases[eventId]+=msg.value;
    }

    function endEvent(uint eventId, address curator)
        public
        onlyEventFactory
        returns (address)
    {
        require(address(distributorContract) != address(0), "not initialized!");
        events[eventId].isEventOver = true;
        distributorContract.distributeFunds{value: events[eventId].totalTips}(
            eventId,
            events[eventId].creator,
            curator,
            events[eventId].curatorCut
        );

        return events[eventId].highestTipper;
    }
}
