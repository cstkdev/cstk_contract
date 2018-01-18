pragma solidity ^0.4.8;

contract ERC20Interface {
    // Get the total token supply
    function totalSupply() public constant returns (uint256 totalSupply2);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success);

    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract FixedSupplyToken is ERC20Interface {
    string public symbol = "CSTK";
    string public name = "Credit share token";
    uint8 public decimals = 0;
    uint256 _totalSupply = 1000000000;

    // Owner of this contract
    address public owner;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
	
    // 
    event TokenInfoChange(string name, string symbol, uint8 decimals);

    // Constructor
    function FixedSupplyToken() public{
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }

    function totalSupply() public constant returns (uint256 total) {
        total = _totalSupply;
        return total;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
     ) public returns (bool success) {
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
		     revert();
             return false;
         }
     }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount){
            allowed[msg.sender][_spender] = _amount;
            Approval(msg.sender, _spender, _amount);
            return true;
	    } else {
	        revert();
            return false;
        }
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function increaseAmount(uint256 mintedAmount) public onlyOwner {
        balances[owner] += mintedAmount;
        _totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, owner, mintedAmount);
    }

    function editNameSymbol(string newName, string newSymbol, uint8 newDecimals) public onlyOwner {
        name = newName;
		symbol = newSymbol;
		decimals = newDecimals;
		TokenInfoChange(name,symbol,decimals);
    }

 }