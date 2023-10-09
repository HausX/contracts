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
        require(
            msg.sender == eventFactoryContract,
            "Only the event factory can call this function"
        );
        _;
    }

    function initialize(
        address _eventFactoryContract,
        IDistributor _distributorContract
    ) public onlyOwner {
        eventFactoryContract = _eventFactoryContract;
        distributorContract = _distributorContract;
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

    function endEvent(uint eventId, address curator)
        public
        onlyEventFactory
        returns (address)
    {
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
