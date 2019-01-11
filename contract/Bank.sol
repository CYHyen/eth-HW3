pragma solidity ^0.4.23;

contract Bank {
	// 此合約的擁有者
    address private owner;

    // 儲存所有會員的ether餘額
    mapping (address => uint256) private balance;

	// 儲存所有會員的coin餘額
    mapping (address => uint256) private coinBalance;

	// 事件們，用於通知前端 web3.js
    event DepositEvent(address indexed from, uint256 value, uint256 timestamp);
    event WithdrawEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);

    event MintEvent(address indexed from, uint256 value, uint256 timestamp);
    event BuyCoinEvent(address indexed from, uint256 value, uint256 timestamp);
    event TransferCoinEvent(address indexed from, address indexed to, uint256 value, uint256 timestamp);
    event TransferOwnerEvent(address indexed oldOwner, address indexed newOwner, uint256 timestamp);

    modifier isOwner() {
        require(owner == msg.sender, "you are not owner");
        _;
    }
    
	// 建構子
    constructor() public payable {
        owner = msg.sender;
    }

	// 存錢
    function deposit() public payable {
        balance[msg.sender] += msg.value;

        emit DepositEvent(msg.sender, msg.value, now);
    }

	// 提錢
    function withdraw(uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        msg.sender.transfer(weiValue);

        balance[msg.sender] -= weiValue;

        emit WithdrawEvent(msg.sender, etherValue, now);
    }

	// 轉帳
    function transfer(address to, uint256 etherValue) public {
        uint256 weiValue = etherValue * 1 ether;

        require(balance[msg.sender] >= weiValue, "your balances are not enough");

        balance[msg.sender] -= weiValue;
        balance[to] += weiValue;

        emit TransferEvent(msg.sender, to, etherValue, now);
    }

	// 檢查銀行帳戶餘額
    function getBankBalance() public view returns (uint256) {
        return balance[msg.sender];
    }

    function kill() public isOwner {
        selfdestruct(owner);
    }

    function mint(uint256 coinValue) public isOwner{
        uint256 value = coinValue * 1 ether;

        coinBalance[msg.sender] = coinBalance[msg.sender] + value;

        emit MintEvent( msg.sender,coinValue,block.timestamp);

    }

    function buy(uint coinValue) public{
        uint256 value = coinValue * 1 ether;
        // require owner 的 coinBalance 不小於 value
        require(coinBalance[owner] >= value , "coinBalance of owner is not enough");
        // require msg.sender 的 etherBalance 不小於 value
        require (balance[msg.sender] >= value,"coinBalance of message sender is not enough");
        // msg.sender 的 etherBalance 減少 value        
        balance[msg.sender] = balance[msg.sender]-value;
        // owner 的 etherBalance 增加 value
        balance[owner] = balance[owner]+value;
         // msg.sender 的 coinBalance 增加 value
        coinBalance[msg.sender] = coinBalance[msg.sender] +value;
        // owner 的 coinBalance 減少 value
        coinBalance[owner] = coinBalance[owner] - value;
        // emit BuyCoinEvent
        emit BuyCoinEvent(msg.sender, coinValue, block.timestamp);

    }

    function transfercoin(address to,uint256 coinValue) public {
        uint value = coinValue * 1 ether;

        require(coinBalance[msg.sender] >= value,"coinBalacne of message sender is not enough");

        coinBalance[msg.sender] = coinBalance[msg.sender]- value;
        coinBalance[to] = coinBalance[to]+value;

        emit TransferCoinEvent(msg.sender,to,value,block.timestamp);
         

    }

    function transferOwner(address newOwner) public isOwner {
        // transfer ownership
        
        address oldowner = owner;
        owner = newOwner;
        // emit TransferOwnerEvent
        emit TransferOwnerEvent( oldowner, owner, block.timestamp);

    }

}