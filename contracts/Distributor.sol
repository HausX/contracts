// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Distributor is Ownable {
    address public liveTippingContract;
    address public dao;

    mapping(uint => bool) public isEventOver;

    event FundsDistributed(
        uint indexed eventId,
        address indexed creator,
        uint creatorAmount,
        address curator,
        uint curatorAmount,
        uint daoAmount
    );

    modifier onlyLiveTipping() {
        require(liveTippingContract!=address(0)&&dao!=address(0),"not initialized");
        require(msg.sender == liveTippingContract, "Invalid Caller");
        _;
    }

    function initialize(address _dao, address _liveTippingContract)
        public
        onlyOwner
    {
        dao = _dao;
        liveTippingContract = _liveTippingContract;
    }

    function distributeFunds(
        uint eventId,
        address creator,
        address curator,
        uint curatorCut
    ) public payable onlyLiveTipping {
        require(!isEventOver[eventId], "Event is already over");

        isEventOver[eventId] = true;

        uint creatorAmount = (msg.value * (90 - curatorCut)) / 100;
        uint curatorAmount = (msg.value * curatorCut) / 100;
        uint daoAmount = (msg.value * 10) / 100;
        (bool success1, ) = creator.call{value: creatorAmount}("");
        (bool success2, ) = curator.call{value: curatorAmount}("");
        (bool success3, ) = dao.call{value: daoAmount}("");
        require(success1 && success2 && success3, "Transfer failed");
        emit FundsDistributed(
            eventId,
            creator,
            creatorAmount,
            curator,
            curatorAmount,
            daoAmount
        );
    }
}
