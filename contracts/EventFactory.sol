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
        uint baseTip,
        uint curatorCut
    ) external;

    function endEvent(uint eventId, address curator) external returns (address);
}

struct DealRequest {
    bytes piece_cid;
    uint64 piece_size;
    bool verified_deal;
    string label;
    int64 start_epoch;
    int64 end_epoch;
    uint256 storage_price_per_epoch;
    uint256 provider_collateral;
    uint256 client_collateral;
    uint64 extra_params_version;
    ExtraParamsV1 extra_params;
}

struct ExtraParamsV1 {
    string location_ref;
    uint64 car_size;
    bool skip_ipni_announce;
    bool remove_unsealed_copy;
}


contract EventFactory is ERC721, ERC721URIStorage, Ownable, AxelarExecutable {
    ILiveTipping public immutable i_liveTippingContract;
    ITicketFactory public immutable i_ticketFactory;
    IAxelarGasService public immutable gasService;
    string public i_streamStorageContract;
    uint256 public eventIdCounter;

    struct Event {
        address creator;
        address curator;
        uint startTime;
        address owner;
        string metadata;
        string pieceCid;
        string streamURI;
    }

    struct CreateEventInputParams{
        uint startTimeDelta;
        uint baseTip;
        uint maxTickets;
        uint ticketPrice;
        address curator;
        uint curatorCut;
        string metadata;
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
        address curator,
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
            events[eventId].curator
        );
        events[eventId].streamURI = streamURI;
        events[eventId].owner = highestTipper;
        events[eventId].pieceCid = pieceCid;
        transferFrom(address(this),highestTipper, eventId);
        emit EventEnded(eventId, pieceCid, streamURI, highestTipper);
    }

    function createEvent(
       CreateEventInputParams memory params,
       DealRequest memory deal
    ) public payable {
        require(params.curatorCut <= 90, "Curator cut must be less than 90%");
        uint eventId = eventIdCounter++;
        events[eventId] = Event(
            msg.sender,
            params.curator,
            block.timestamp+params.startTimeDelta,
            address(0),
            params.metadata,
            "",
            ""
        );
        i_ticketFactory.createTicket(
            eventId,
            params.maxTickets,
            params.ticketPrice,
            params.metadata
        );
        i_liveTippingContract.createLiveTipping(
            eventId,
            msg.sender,
            block.timestamp+params.startTimeDelta,
            params.baseTip,
            params.curatorCut
        );
        _mint(address(this), eventId);
        _setTokenURI(eventId, params.metadata);

        // Cross chain transaction
        require(msg.value > 0, "no CC gas");

        bytes memory payload = abi.encode(
            eventId,
            deal
        );

        gasService.payNativeGasForContractCall{value: msg.value}(
            address(this),
            "filecoin-2",
            i_streamStorageContract,
            payload,
            msg.sender
        );
        gateway.callContract("filecoin-2", i_streamStorageContract, payload);
        emit EventCreated(eventId, msg.sender, params.curator, block.timestamp+params.startTimeDelta, params.metadata);
    }

    function getCurrentBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }
    
    function getEventStartTime() public view returns (uint256) {
        return events[eventIdCounter].startTime;
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
