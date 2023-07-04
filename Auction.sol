pragma solidity 0.5.2;
pragma experimental ABIEncoderV2;

contract AuctionManager{

enum AuctionState{
    CREATED,
    LIVE,
    CLOSED

}

enum BidState{
    PLACED,
    ACCEPTED
}

struct Auction {
    string id;
    address payable owner;
    uint index;
    uint256 startDate;
    uint256 endDate;
    uint256 highestBid;
    address highestBidder;
    bool isLive;
    AuctionState state;
}

struct Bid{
    string id;
    address owner;
    string auctionId;
    uint256 payableDate;
    uint256 value;
    bool isAccepted;
    
}

mapping (uint256 => Auction) auctions;
mapping (uint256 => Bid[]) bids;
mapping (address => uint256) balances;

modifier onlyAuctionOwner(uint _auctionIndex) {
    require(msg.sender == auctions[_auctionIndex].owner, "Only Auction Owner Allowed");
    _;
}

modifier  onlyBidOwner(uint _bidIndex, uint _auctionIndex ){
    require(msg.sender == bids[_auctionIndex][_bidIndex].owner, "Only Bid Owner Allowed");
    _;
}

modifier  onlyAuctionOrBidOwner(uint _bidIndex, uint _auctionIndex ){
    require((msg.sender == auctions[_auctionIndex].owner || msg.sender == bids[_auctionIndex][_bidIndex].owner), "Only Auction or Bid Owner Allowed");
    _;
}

Auction[] auctionList;
uint auctionIndex = 0;
uint bidIndex = 0;

function createAuction(string memory _auctionID) public returns (bool){
    auctions[auctionIndex].id = _auctionID;
    auctions[auctionIndex].owner = msg.sender;
    auctions[auctionIndex].index = auctionIndex;
    auctions[auctionIndex].startDate = now;
    auctions[auctionIndex].endDate = now + 2 days;
    auctions[auctionIndex].highestBid = 0;
    auctions[auctionIndex].state = AuctionState.CREATED;
    auctions[auctionIndex].isLive = true;
    auctionIndex++;
    return true;
}

function getAuctionnAt(uint _auctionIndex) public view returns (string memory id, uint index, 
      uint256 startDate, uint256 endDate,  uint256 highestBid, AuctionState state, bool live) {
          Auction memory  auction = auctions[_auctionIndex];
          return (auction.id, auction.index, auction.startDate, auction.endDate, auction.highestBid, 
          auction.state, auction.isLive);
      }

function placeBid(uint _auctionIndex, string memory _bidId, uint256 _bidAmount, uint256 _payableDate) public returns (bool success){
    require(auctions[_auctionIndex].owner != msg.sender, "Auction owners are not allowed to place a bid");
    require(auctions[_auctionIndex].isLive, "Only Live Auctions are opened for bidding");

    //Check if Bidder is rebidding
    uint bidIndex = 0;
    bool exists = false;
    for(uint bidIndex = 0; bidIndex < bids[_auctionIndex].length; bidIndex++){
        if(bids[_auctionIndex][bidIndex].owner == msg.sender){
            require(bids[_auctionIndex][bidIndex].value < _bidAmount, "New bid should be larger than the previous one");
            exists = true;
            break ;
        }
    }
    if(exists){
        // If rebidding update the bid anount
        bids[_auctionIndex][bidIndex].value = _bidAmount;
    }
    else{
        bids[_auctionIndex].push(Bid({id : _bidId, owner : msg.sender, auctionId: auctions[_auctionIndex].id, 
        payableDate : _payableDate, value : _bidAmount, isAccepted : false}));
        bidIndex++;
       
    }
     if(auctions[_auctionIndex].highestBid < _bidAmount){
            auctions[_auctionIndex].highestBid = _bidAmount;
            auctions[_auctionIndex].state = AuctionState.LIVE;
        }
    return  success = true;

}

function totalBids(uint _auctionIndex) public view onlyAuctionOwner(_auctionIndex) returns(uint256){
    return bids[_auctionIndex].length;
}

function getTotalBids(uint _auctionIndex) public view onlyAuctionOwner(_auctionIndex) returns(Bid[] memory ){
    return bids[_auctionIndex];
}

function getBid(uint _auctionIndex, uint _bidIndex) public view onlyAuctionOrBidOwner(_auctionIndex, _bidIndex) returns (Bid memory){
    Bid memory b = bids[_auctionIndex][_bidIndex];
    return b;
}

function acceptBid(uint _bidIndex, uint _auctionIndex) public onlyAuctionOwner(_auctionIndex){
    bids[_auctionIndex][bidIndex].isAccepted = true;
    auctions[_auctionIndex].state = AuctionState.CLOSED;
    auctions[_auctionIndex].isLive = false;
}

function closeAuction(uint _auctionIndex) public view onlyAuctionOwner(_auctionIndex) returns (bool success){
    Auction memory auction = auctions[_auctionIndex];
    require(auction.startDate < now, "Auction can not be closed before start date");
    auction.state = AuctionState.CLOSED;
    auction.isLive = false;
    return success = true;
}

function payBiddingAmount(uint _bidIndex, uint _auctionIndex) public payable onlyBidOwner(_bidIndex, _auctionIndex) returns (bool){
    Auction memory auction = auctions[_auctionIndex];
    require(bids[_auctionIndex][_bidIndex].isAccepted, "Your bid is not accepted");
    require(msg.value == bids[_auctionIndex][_bidIndex].value, "Bid amount is not matching");
    uint256 bidAmount = bids[_auctionIndex][_bidIndex].value;
    address payable auctionOwner = auction.owner;
    auctionOwner.transfer(bidAmount);
    return true;
}


}