// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./data.sol";

contract crowdsale is Ownable, Pausable, Data {
    address XPADTokenAddress = 0xffE2d15aFE09b43C60E05B220018a643C9005CE9;
    IERC20 public XPADToken = IERC20(XPADTokenAddress);

    address BUSDTokenAddress = 0xDc2280A89e7Fa73D84f4e01c07f1421Cab69eacb;
    IERC20 public BUSDToken = IERC20(BUSDTokenAddress);

    address public BUSDRecipient = 0x7b76dBF7f01ebA3eE2fa1339C8C29FA6949b1bE4;
    address public XPADTokenHolder = 0x7b76dBF7f01ebA3eE2fa1339C8C29FA6949b1bE4;

    uint public minBUSD = 50 ether;

    uint public totalSold;

    mapping(address => Staker[]) internal addressToS;
    // address[] internal allStakers;
    struct Staker {
        uint timeStake;
        uint value;
    }

    event saleEvent(uint totalSold);

    constructor() {
        pause();
    }

    // public functions 

    // input: amount - XPAD token amount with decimals 10**18
    function sale(uint amount)
        public
        whenNotPaused
    {   
        uint amountBUSD = amount * getPriceXPAD() / 10**2;

        require(amountBUSD >= minBUSD, "The minimum purchase amount for the XPAD token is 50 BUSD");
        require(getCurrentMaxTotalAmount() >= totalSold + amount);

        fund(amount, msg.sender);

        totalSold = totalSold + amount;

        BUSDToken.transferFrom(msg.sender, BUSDRecipient, amountBUSD);

        emit saleEvent(totalSold);
    }

    function withdraw() public {
        uint _MaxvalueWithdraw;

        for (uint i = 0; i < addressToS[msg.sender].length; i++) {

            if (addressToS[msg.sender][i].timeStake + getVestingXPAD(addressToS[msg.sender][i].timeStake) < block.timestamp && addressToS[msg.sender][i].value != 0) {
                _MaxvalueWithdraw = _MaxvalueWithdraw + addressToS[msg.sender][i].value;

                addressToS[msg.sender][i].value = 0;
            }

        }

        XPADToken.transferFrom(XPADTokenHolder, msg.sender, _MaxvalueWithdraw);

        require(_MaxvalueWithdraw > 0, "Available for withdrawal 0 XPP");
    }

    // private functions 

    // input: amount - XPAD token amount with decimals 10**18
    function fund(uint _value, address _address) private {

        addressToS[_address].push(Staker(block.timestamp, _value));
    }

    // view functions

    function getStakerData() public view returns (Staker[] memory){
        return addressToS[msg.sender];
    }

    function getStakeBalance() public view returns (uint){
        uint _balance;

        if (addressToS[msg.sender].length != 0) {

            for (uint i = 0; i < addressToS[msg.sender].length; i++) {
                if (addressToS[msg.sender][i].value != 0) {
                    _balance = _balance + addressToS[msg.sender][i].value;
                }
            }
        }

        return _balance;
    }

    function getAmountXPPAvailebleToWithdraw() public view returns (uint){
        uint _MaxvalueWithdraw;

        if (addressToS[msg.sender].length != 0) {
            for (uint i = 0; i < addressToS[msg.sender].length; i++) {

                if (addressToS[msg.sender][i].timeStake + getVestingXPAD(addressToS[msg.sender][i].timeStake) < block.timestamp && addressToS[msg.sender][i].value != 0) {
                    _MaxvalueWithdraw = _MaxvalueWithdraw + addressToS[msg.sender][i].value;
                }
                
            }
        }

        return _MaxvalueWithdraw;
    }

    // only owner functions

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function changeRound(uint i, uint _timeStart, uint _timeEnd, uint _vesting, uint _price, uint _maxTotalAmount) public onlyOwner {
        allRounds[i] = Round(_timeStart, _timeEnd, _vesting, _price, _maxTotalAmount);
    }

    function addRound(uint _timeStart, uint _timeEnd, uint _vesting, uint _price, uint _maxTotalAmount) public onlyOwner {
        allRounds.push(Round(_timeStart, _timeEnd, _vesting, _price, _maxTotalAmount));
    }

    function deleteRound(uint i) public onlyOwner {
        uint lastIndex = allRounds.length - 1;

        if (i != lastIndex) {
            allRounds[i] = allRounds[lastIndex];
        }

        allRounds.pop();
    }

    function setXPADTokenAddress(address _address) public onlyOwner {
        XPADTokenAddress = _address;
    }

    function setBUSDTokenAddress(address _address) public onlyOwner {
        BUSDTokenAddress = _address;
    }

    function setXPADTokenHolder(address _address) public onlyOwner {
        XPADTokenHolder = _address;
    }

    function setminBUSD(uint _minBUSD) public onlyOwner {
        minBUSD = _minBUSD;
    }

    function setBUSDRecipient(address _address) public onlyOwner {
        BUSDRecipient = _address;
    }

    function getStakerDataOwner(address _address) public onlyOwner view returns (Staker[] memory){
        return addressToS[_address];
    }

    function getStakeBalanceOwner(address _address) public onlyOwner view returns (uint){
        uint _balance;

        if (addressToS[_address].length != 0) {

            for (uint i = 0; i < addressToS[_address].length; i++) {
                if (addressToS[_address][i].value != 0) {
                    _balance = _balance + addressToS[_address][i].value;
                }
            }
        }

        return _balance;
    }

    function getAmountXPPAvailebleToWithdrawOwner(address _address) public onlyOwner view returns (uint){
        uint _MaxvalueWithdraw;

        if (addressToS[_address].length != 0) {
            for (uint i = 0; i < addressToS[_address].length; i++) {

                if (addressToS[_address][i].timeStake + getVestingXPAD(addressToS[_address][i].timeStake) < block.timestamp && addressToS[_address][i].value != 0) {
                    _MaxvalueWithdraw = _MaxvalueWithdraw + addressToS[_address][i].value;
                }
                
            }
        }

        return _MaxvalueWithdraw;
    }

}