// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {IERC20} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

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

contract EventFactory is ERC721, ERC721URIStorage, Ownable, AxelarExecutable {
    ILiveTipping public immutable i_liveTippingContract;
    ITicketFactory public immutable i_ticketFactory;
    IAxelarGasService public immutable gasService;
    string public i_streamStorageContract;
    uint256 public eventIdCounter;

    struct Event {
        address creator;
        uint startTime;
        address owner;
        string metadata;
        string pieceCid;
        string streamURI;
    }

    mapping(uint => Event) public events;

    constructor(
        ILiveTipping liveTippingContract,
        ITicketFactory ticketFactoryContract,
        string memory streamStorageContract,
        address gateway_,
        address gasReceiver_
    ) AxelarExecutable(gateway_) ERC721("RealityHaus", "RH") {
        i_liveTippingContract = liveTippingContract;
        i_ticketFactory = ticketFactoryContract;
        i_streamStorageContract = streamStorageContract;
        gasService = IAxelarGasService(gasReceiver_);
    }

    event EventCreated(
        uint indexed eventId,
        address indexed creator,
        uint startTime,
        string metadata
    );
    event EventEnded(
        uint indexed eventId,
        string pieceCid,
        string streamURI,
        address owner
    );

    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        require(
            keccak256(bytes(sourceChain_)) == keccak256(bytes("filecoin-2")),
            "invalid chain"
        );
        require(
            keccak256(bytes(sourceAddress_)) ==
                keccak256(bytes(i_streamStorageContract)),
            "invalid address"
        );

        (uint256 eventId, string memory pieceCid, string memory uri) = abi
            .decode(payload_, (uint256, string, string));

        _endEvent(eventId, pieceCid, uri);
    }

    function _endEvent(
        uint eventId,
        string memory pieceCid,
        string memory streamURI
    ) internal {
        // gets triggered on receiving cross-chain transaction from FVM on successful storage of stream chunks
        address highestTipper = i_liveTippingContract.endEvent(
            eventId,
            msg.sender
        );
        events[eventId].streamURI = streamURI;
        events[eventId].owner = highestTipper;
        events[eventId].pieceCid = pieceCid;
        _mint(highestTipper, eventId);
        emit EventEnded(eventId, pieceCid, streamURI, highestTipper);
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
            "",
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
