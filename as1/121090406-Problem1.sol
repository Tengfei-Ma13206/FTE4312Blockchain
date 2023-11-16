// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Contract A
contract A {
    string public name = "Token X";
    string public symbol = "X";
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    address minter;
    constructor() {
        minter = msg.sender;// minter is the contract constructor
    }
    function minting(address to, uint256 amount) external {
        require(minter == msg.sender,"Only minter can mint");
        balances[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address from, address to, uint256 amount) external {
        require(balances[from] >= amount, "Insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
}

// Contract B
contract B {
    string public name = "Token Y";
    string public symbol = "Y";
    uint256 public totalSupply = 0;
    mapping(address => uint256) public balances;
    address minter;
    A public a;

    constructor(address _A_Address) {
        a = A(_A_Address);// binds to contract A in order to mint Y
        minter = msg.sender;// minter is the contract constructor
    }

    function minting(address to, uint256 amount) external {
        require(minter == msg.sender,"Only minter can minter");
        require(totalSupply + amount <= 10000, "Total supply exceeded");
        require(amount >= 0, "amount should not be negative");

        uint256 requiredTokenX;
        if (totalSupply < 1000) {
            if (totalSupply + amount <= 1000){requiredTokenX = 10 * amount;} 
            else if (totalSupply + amount <= 5000){requiredTokenX = 10*(1000-totalSupply)+20*(amount-(1000-totalSupply));}
            else if (totalSupply + amount <= 9000){requiredTokenX = 10*(1000-totalSupply)+20*4000+50*(amount-(1000-totalSupply)-4000);}
            else {requiredTokenX = 10*(1000-totalSupply)+20*4000+50*4000+100*(amount-(1000-totalSupply)-4000-4000);}
        } else if (totalSupply < 5000) {
            if (totalSupply + amount <= 5000){requiredTokenX = 20*amount;}
            else if (totalSupply + amount <= 9000){requiredTokenX = 20*(5000-totalSupply)+50*(amount-(5000-totalSupply));}
            else{requiredTokenX = 20*(5000-totalSupply)+50*4000+100*(amount-(5000-totalSupply)-4000);}
        } else if (totalSupply < 9000) {
            if (totalSupply + amount <= 9000) {requiredTokenX = 50 * amount;}
            else {requiredTokenX = 50*(9000-totalSupply)+100*(amount - (9000-totalSupply));}
        } else {
            requiredTokenX = 100 * amount;
        }

        require(a.balances(to) >= requiredTokenX, "Insufficient Token X balance");
        a.transfer(to, address(this), requiredTokenX);

        balances[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function transfer(address from, address to, uint256 amount) external {
        require(balances[from] >= amount, "Insufficient balance");
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
}
