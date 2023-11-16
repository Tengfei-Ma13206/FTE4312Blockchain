// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract GuessGame {
    struct Player {
        address addr;   // address of player
        bytes32 commit; // hashed chosen number, we use Commit-Reveal pattern
        uint8 revealedNumber;  // when both players have finished committing number, reveal the chosen number
        uint8 announcedNumber; // announce the number to competitor, the number may dismatch the chosen number
        bool ifChallenge;      // if you challenge competitor, it will be true. Otherwise, false.
        bool hasCommitted;     // if you has committed your chosen number and announced number, it will be true. Otherwise, false.
        bool hasChallenged;    // if you has finished making decision whether you challenge competitor, it will be true. Otherwise, false.
        bool hasRevealed;      // if you has revealed your chosen number, it will be true. Otherwise, false.
        uint8 score;           // your score
    }

    Player public player1;
    Player public player2;
    uint8 public round; // when round = 4, game is over, namely, you can only run 3 rounds.

    constructor(address _player1_addr,address _player2_addr) {
        player1.addr = _player1_addr; 
        player2.addr = _player2_addr;// enroll players
        round = 1;
    }

    function commitNumber(uint8 _chosenNumber, uint8 _announcedNumber) external {
        require(round <= 3, "Game over");
        require(_chosenNumber >= 1 && _chosenNumber <= 10, "Invalid chosenNumber");
        require(_announcedNumber >= 1 && _announcedNumber <= 10, "Invalid announcedNumber");
        require(msg.sender == player1.addr || msg.sender== player2.addr, "Invalid player address");
        if (msg.sender == player1.addr) {
            require(!player1.hasCommitted, "You already has committed");// prevent repeating committing numbers
            player1.commit = keccak256(abi.encodePacked(_chosenNumber));// hash your chosen number, 
                                                                        // in case that competitor know your chosen number in advance
            player1.announcedNumber = _announcedNumber;// competitor can access the announced number
            player1.hasCommitted = true;
        } else{
            require(!player2.hasCommitted, "You already has committed");
            player2.commit = keccak256(abi.encodePacked(_chosenNumber));
            player2.announcedNumber = _announcedNumber;
            player2.hasCommitted = true;
        }
    }

    function challenge(bool _ifChanllge) external {
        require(round <= 3, "Game over");
        require(msg.sender == player1.addr || msg.sender== player2.addr, "Invalid player address");
        require(player1.hasCommitted && player2.hasCommitted, "Both players should finish committing numbers");// you should commit numbers first
        if (msg.sender == player1.addr) {
            require(!player1.hasChallenged, "You already has challenged");//prevent making challenge decision
            player1.ifChallenge = _ifChanllge;// true means you challenge competitor, false means you do not challenge.
            player1.hasChallenged = true;
        }
        else {
            require(!player2.hasChallenged, "You already has challenged");
            player2.ifChallenge = _ifChanllge;
            player2.hasChallenged = true;
        }
    }

    function revealNumber_and_calculateScores(uint8 _number) external {
        require(round <= 3, "Game over");
        require(_number >= 1 && _number <= 10, "Invalid number");
        require(msg.sender == player1.addr || msg.sender == player2.addr, "Invalid player address");
        require(player1.hasChallenged && player2.hasChallenged, "Both players should finish challenging");//after challenge, you can reveal chosen number
        
        if (player1.addr == msg.sender){// you are player1
            require(!player1.hasRevealed, "You already has revealed number");// repeating revealing is not allowed, but fail revealing allows to reveal again
            require(keccak256(abi.encodePacked(_number)) == player1.commit, "Invalid reveal");// you must reveal right chosen number
            player1.hasRevealed = true;
            player1.revealedNumber = _number;
            if (player1.revealedNumber == player1.announcedNumber){//you are honest
                if (player2.ifChallenge) {player1.score += 1;}// competitor challenges you, you get 1 score
                else {player2.score += 1;}// competitor does not challenge you, competitor gets 1 score
            }
            else{// you are not honest
                if (player2.ifChallenge) {player2.score += 2;}// competitor challenges you, competitor gets 2 scores
                else {player1.score += 2;}// competitor does not, you get 2 scores
            }
        }
        else{// you are player2
            require(!player2.hasRevealed, "You already has revealed number");
            require(keccak256(abi.encodePacked(_number)) == player2.commit, "Invalid reveal");
            player2.hasRevealed = true;
            player2.revealedNumber = _number;
            if (player2.revealedNumber == player2.announcedNumber){
                if (player1.ifChallenge) {player2.score += 1;}
                else {player1.score += 1;}
            }
            else{
                if (player1.ifChallenge) {player1.score += 2;}
                else {player2.score += 2;}
            }
        }
        if (player1.hasRevealed && player2.hasRevealed){
            round++; // go to next round
            // refresh the results of last round
            player1.hasCommitted = false;
            player1.hasChallenged = false;
            player1.hasRevealed = false;
            player1.ifChallenge = false;
            player1.revealedNumber = 0;
            player1.announcedNumber = 0;
            player1.commit = 0;
            player2.hasCommitted = false;
            player2.hasChallenged = false;
            player2.hasRevealed = false;
            player2.ifChallenge = false;
            player2.revealedNumber = 0;
            player2.announcedNumber = 0;
            player2.commit = 0;
        }
    }

    function getWinner() external view returns (address) {
        require(round > 3, "Game is not over yet");// only when game is over, you can get winner
        if (player1.score > player2.score) {//player1 wins
            return player1.addr;
        } else if (player1.score < player2.score) {//player2 wins
            return player2.addr;
        } else {
            return address(0); // It's a tie
        }
    }
}
