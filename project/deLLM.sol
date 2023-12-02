// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract deLLM {
    struct Block{
        uint256 prevBlockID;
        address author;
        uint256[] parameters;
        uint256 prevBlockHash;
        string[] data;
        string model;
        uint256 time;
        uint256 nonce;
    }

    Block[] public blocks;
    uint256 public ID = 0;//next block ID

    constructor(uint256 _prevBlockID,  address _author, uint256[] memory _parameters, uint256 _prevBlockHash, string[] memory _data, string memory _model, uint256 _nonce)
    {
        Block memory newBlock = Block
        ({
            prevBlockID: _prevBlockID,
            author: _author,
            parameters: _parameters,
            prevBlockHash: _prevBlockHash,
            data: _data,
            model: _model,
            time: block.timestamp,
            nonce: _nonce
        });

        blocks.push(newBlock);
        ID = ID + 1;
    }

    function commitBlock(uint256 _prevBlockID,  address _author, uint256[] memory _parameters, uint256 _prevBlockHash, string[] memory _data, string memory _model, uint256 _nonce) external
    {
        Block memory newBlock = Block
        ({
            prevBlockID: _prevBlockID,
            author: _author,
            parameters: _parameters,
            prevBlockHash: _prevBlockHash,
            data: _data,
            model: _model,
            time: block.timestamp,
            nonce: _nonce
        });

        blocks.push(newBlock);
        ID = ID + 1;       
    }

    function ownershipCheck(uint256 blockID1, uint256 blockID2) external view returns (address) //ownership belongs to earlier author
    {
        if (blocks[blockID1].time < blocks[blockID2].time)
        {
            return blocks[blockID1].author;
        }
        else if (blocks[blockID1].time > blocks[blockID2].time)
        {
            return blocks[blockID2].author;
        }
        else
        {
            return address(0);//the block belongs to both author
        }
    }

    function getParameters(uint256 blockID) public view returns (uint256[] memory) 
    {
        return blocks[blockID].parameters;
    }

    function getPrevBlockID(uint256 blockID) public view returns (uint256) 
    {
        return blocks[blockID].prevBlockID;
    }

    function getAuthor(uint256 blockID) public view returns (address) 
    {
        return blocks[blockID].author;
    }
    
    function getPrevBlockHash(uint256 blockID) public view returns (uint256) 
    {
        return blocks[blockID].prevBlockHash;
    } 

    function getData(uint256 blockID) public view returns (string[] memory) 
    {
        return blocks[blockID].data;
    }       

    function getModel(uint256 blockID) public view returns (string memory) 
    {
        return blocks[blockID].model;
    } 

    function getTime(uint256 blockID) public view returns (uint256) 
    {
        return blocks[blockID].time;
    }

    function getNonce(uint256 blockID) public view returns (uint256) 
    {
        return blocks[blockID].nonce;
    }

}