// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract SpaceShapes is ERC1155 {
    uint256 public constant POINTCOIN = 0; // used as token id
    uint256 public constant ALPHACOIN = 1; // used as token id

    struct Entity {
        address owner;
        string name;
        uint256 entityType; // 1 player, 2 space, 3 shape. // 0 is default and thus represents unset
    }

    struct Space {
        uint256 edgeDimension;
        uint256 maxCapacity;
        uint256 currentCapacity;
        mapping( uint256 => bool ) shapeTypes;
        mapping( uint256 => bool ) sownShapes;
        uint256 timesSeeded;
    }

    struct Shape {
        uint256 edgeDimension;
        uint256 spaceCapacity; // amount of spaces shape can been sown on
        uint256 spaceCount; // amount of spaces the shape is currently sown on
        uint256 shapeType;
        uint256 timesMined;
    }

    struct Miner {
        uint256 id;
        uint256 points;
        uint256[] shapes;   // owned shapes
        uint256[] spaces;   // owned spaces
    }

    /**
        Players, Shapes, and Spaces are all NFTs
        with unique IDs
     */
    uint256 public entityId;
    uint256[] shapes;
    uint256[] spaces;

    // contract owner
    address owner;

    mapping( address => Miner ) public player;        // address => Miner
    mapping( uint256 => Entity ) public entityObject;   // entityId => Entity
    mapping( uint256 => Space ) public spaceObject;     // entityId => Space
    mapping( uint256 => Shape ) public shapeObject;     // entityId => Shape

    constructor() ERC1155("") {
        owner = msg.sender;
        entityId = 2; // NFT IDs start at 2
    }

    function newPlayer(string memory _name) public payable {
        // all players are miners
        require(player[msg.sender].id == 0, "You've already joined");
        require(msg.value >= 0.001 ether, "not enough eth to join game");

        newEntity(_name, 1, entityId); // new player entity
        player[msg.sender].id = entityId;
        player[msg.sender].points = 1;
        _mint(msg.sender, entityId, 1, "");
        _mint(msg.sender, POINTCOIN, 1000, "");

        entityId++;
    }

    function getSelf() public view returns(uint256, uint256, uint256[] memory, uint256[] memory) {
        return(
            player[msg.sender].id,
            player[msg.sender].points,
            player[msg.sender].shapes,
            player[msg.sender].spaces
        );
    }

    function newSpace(string memory _name) public payable {
        // 
        require(player[msg.sender].id != 0, "You haven't joined the game");
        require(msg.value >= 0.01 ether, "not enough eth");

        spaceObject[entityId].edgeDimension = 1;
        spaceObject[entityId].multiplier = 1;
        spaceObject[entityId].maxCapacity = 1;
        spaceObject[entityId].shapeTypes[1] = true;

        newEntity(_name, 2, entityId); // new space entity        
        _mint(msg.sender, entityId, 1, "");
        player[msg.sender].points += 10;
        player[msg.sender].spaces.push(entityId);
        entityId++;
    }

    function newShape(string memory _name) public payable {
        require(player[msg.sender].id != 0, "You haven't joined the game");
        require(msg.value >= 0.01 ether, "not enough eth");

        shapeObject[entityId].edgeDimension = 1;
        shapeObject[entityId].fertility = 1;
        shapeObject[entityId].divisibility = 1;
        shapeObject[entityId].spaceCapacity = 3;
        shapeObject[entityId].shapeType = 1; // self minted shapes are always LINES

        newEntity(_name, 3, entityId); // new shape entity
        _mint(msg.sender, entityId, 1, "");
        player[msg.sender].points += 10;
        player[msg.sender].shapes.push(entityId);
        entityId++;
    }

    function newEntity(string memory _name, uint256 _type, uint256 _entityId) internal {
        entityObject[_entityId].owner = msg.sender;
        entityObject[_entityId].name = _name;
        entityObject[_entityId].entityType = _type;
    }
}