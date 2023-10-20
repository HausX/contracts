// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface ILiveTipping{
    function ticketPurchaseDeposit(uint eventId)external payable;
}

contract TicketFactory is ERC1155URIStorage, Ownable {
    address public eventFactory;
    ILiveTipping public liveTipping;
    uint private _ticketId;

    struct Event {
        uint256 eventId;
        uint256 maxTickets;
        uint256 ticketPrice;
        uint256 currentSold;
    }

    struct Ticket {
        uint256 eventId;
        uint256 ticketId;
        address owner;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => Ticket) public tickets;
    mapping(uint256=>mapping(address=>uint256)) public eventToTicketId;

    constructor() ERC1155("") {
        _ticketId=1;
    }

    event TicketCreated(
        uint256 indexed eventId,
        uint256 maxTickets,
        uint256 ticketPrice
    );
    event TicketPurchased(
        uint256 indexed eventId,
        uint256 indexed ticketId,
        address purchaser
    );

    event TicketTransferred(
        uint256 indexed eventId,
        uint256 indexed ticketId,
        address from,
        address to
    );

    modifier onlyEventFactory() {
        require(eventFactory != address(0), "Not initialized"); 
        require(msg.sender == eventFactory, "Invalid Caller");
        _;
    }

    function initialize(address _eventFactory,ILiveTipping _liveTipping) public onlyOwner {
        eventFactory = _eventFactory;
        liveTipping=_liveTipping;
        
    }

    function createTicket(
        uint256 eventId,
        uint256 maxTickets,
        uint256 ticketPrice,
        string memory metadata
    ) public onlyEventFactory {
        _setURI(eventId, metadata);
        events[eventId] = Event(eventId, maxTickets, ticketPrice, 0);
        emit TicketCreated(eventId, maxTickets, ticketPrice);
    }

    function purchaseTicket(uint256 eventId, address user) public payable {
        require(balanceOf(user, eventId) == 0, "already purchased");
        require(msg.value >= events[eventId].ticketPrice, "insufficient funds");
        require(
            events[eventId].currentSold < events[eventId].maxTickets,
            "sold out"
        );
        liveTipping.ticketPurchaseDeposit{value: msg.value}(eventId);
        events[eventId].currentSold++;
        eventToTicketId[eventId][user]=_ticketId+1;
        tickets[_ticketId] = Ticket(eventId, _ticketId++, user);
        _mint(user, eventId, 1, "");

        emit TicketPurchased(eventId, _ticketId, msg.sender);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155) {
        for (uint i = 0; i < ids.length; i++) {
            require(balanceOf(to, ids[i]) == 0, "ticket already owned");
            if(from==address(0)){
                continue;
            }
            uint256 eventId=ids[i];
            uint256 ticketId=eventToTicketId[eventId][from];
            eventToTicketId[eventId][to]=ticketId;
            eventToTicketId[eventId][from]=0;
            emit TicketTransferred(eventId,ticketId,from,to);
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
      
           
    }

    function uri(uint256 tokenId)
        public
        view
        override(ERC1155URIStorage)
        returns (string memory)
    {
        return super.uri(tokenId);
    }
}
