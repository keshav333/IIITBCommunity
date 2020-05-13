pragma solidity >=0.4.24;

//Importing openzeppelin-solidity ERC-721 implemented Standard
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

// IIITB-c Contract declaration inheritance the ERC721 openzeppelin implementation
contract IIITB is ERC721 {

    // Community data
    struct Community {
        string name;
    }
 string public constant name = "IIITB Community Token";
    string public constant symbol = "IIITBC";

    // mapping the Community with the Owner Address
    mapping(uint256 => Community) public tokenIdToCommunityInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public communitysForSale;

    
    // Create Community using the Struct
    function createCommunity(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Community memory newCommunity = Community(_name); // Community is an struct so we are creating a new Community
        tokenIdToCommunityInfo[_tokenId] = newCommunity; // Creating in memory the Community -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the community with _tokenId to the sender address (ownership)
    }

    // Putting an Community for sale (Adding the community tokenid into the mapping communitysForSale, first verify that the sender is the owner)
    function putCommunityUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Community you don't owned");
        communitysForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }	

    function buyCommunity(uint256 _tokenId) public  payable {
        require (communitysForSale[_tokenId] > 0, "The Community should be up for sale");
        uint256 communityCost = communitysForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > communityCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer (communityCost);
        if(msg.value > communityCost) {
            msg.sender.transfer(msg.value - communityCost);
        }
    }

    
    function lookUptokenIdToCommunityInfo (uint _tokenId) public view returns (string memory) {

           return tokenIdToCommunityInfo[_tokenId].name;
    }

    function exchangeCommunitys(uint256 _tokenId1, uint256 _tokenId2) public {
      address token1Owner = ownerOf(_tokenId1);
        address token2Owner = ownerOf(_tokenId2);
         require(token1Owner != address(0), "Owner of the first token needs to exist");
        require(token2Owner != address(0), "Owner of the second token needs to exist");

        if(msg.sender == token1Owner) {
            _transferFrom(token1Owner, token2Owner, _tokenId1);
            _transferFrom(token2Owner, token1Owner, _tokenId2);
        }
        else if(msg.sender == token2Owner) {
            _transferFrom(token2Owner, token1Owner, _tokenId2);
            _transferFrom(token1Owner, token2Owner, _tokenId1);
        }
    }

    
    function transferCommunity(address _to1, uint256 _tokenId) public {
        
        require(msg.sender == ownerOf(_tokenId), "Sender needs to own the token");
        transferFrom(msg.sender, _to1, _tokenId);
    }

}
