// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITicketFactory {
    function createTicket(
        uint256 eventId,
        uint256 maxTickets,
        uint256 ticketPrice,
        string memory metadata
    ) external;
}

interface ILiveTipping {
    function createLiveTipping(
        uint eventId,
        address creator,
        uint startTime,
        uint baseTip
    ) external;

    function endEvent(uint eventId, address curator) external returns (address);
}

contract EventFactory is ERC721, ERC721URIStorage, Ownable {
    ILiveTipping public immutable i_liveTippingContract;
    ITicketFactory public immutable i_ticketFactory;
    uint256 public eventIdCounter;

    struct Event {
        address creator;
        uint startTime;
        address owner;
        string metadata;
        string streamURI;
    }

    mapping(uint => Event) public events;

    constructor(
        ILiveTipping liveTippingContract,
        ITicketFactory ticketFactoryContract
    ) ERC721("RealityHaus", "RH") {
        i_liveTippingContract = liveTippingContract;
        i_ticketFactory = ticketFactoryContract;
    }

    event EventCreated(
        uint indexed eventId,
        address indexed creator,
        uint startTime,
        string metadata
    );
    event EventEnded(uint indexed eventId, string streamURI, address owner);

    function _endEvent(uint eventId, string memory streamURI) internal {
        // gets triggered on receiving cross-chain transaction from FVM on successful storage of stream chunks
        address highestTipper = i_liveTippingContract.endEvent(
            eventId,
            msg.sender
        );
        events[eventId].streamURI = streamURI;
        events[eventId].owner = highestTipper;
        _mint(highestTipper, eventId);
        emit EventEnded(eventId, streamURI, highestTipper);
    }

    function createEvent(
        uint startTime,
        uint baseTip,
        uint maxTickets,
        uint ticketPrice,
        string memory metadata
    ) public {
        require(startTime > block.timestamp, "Invalid start time");
        uint eventId = eventIdCounter++;
        events[eventId] = Event(
            msg.sender,
            startTime,
            address(0),
            metadata,
            ""
        );
        i_ticketFactory.createTicket(
            eventId,
            maxTickets,
            ticketPrice,
            metadata
        );
        i_liveTippingContract.createLiveTipping(
            eventId,
            msg.sender,
            startTime,
            baseTip
        );
        _setTokenURI(eventId, metadata);
        emit EventCreated(eventId, msg.sender, startTime, metadata);
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}
