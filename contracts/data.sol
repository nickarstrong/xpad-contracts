// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Data {
    // in seconds
    // start, end, vesting, price: 5 == 0.05$
    struct Round {
        uint timeStart;
        uint timeEnd;
        uint vesting;
        uint price;
        uint maxTotalAmount;
    }

    Round[] internal allRounds;

    constructor() {
        allRounds.push(Round(1682420772, 1683527630, 60, 5, 19000000));
        allRounds.push(Round(1683527630, 1684593572, 60, 7, 19000000));
        allRounds.push(Round(1684593572, 1684593572, 5000, 10, 19000000));
        allRounds.push(Round(1684593572, 1684593572, 5000, 15, 19000000));
    }

    function getPriceXPAD() public view returns (uint){
        uint priceXPAD;

        for (uint i = 0; i < allRounds.length; i++) {
            if (block.timestamp >= allRounds[i].timeStart && block.timestamp < allRounds[i].timeEnd) {
                priceXPAD = allRounds[i].price;
                break;
            }
        }

        return priceXPAD;
    }

    function getVestingXPAD(uint _timeStake) public view returns (uint){
        uint vestingXPAD;

        for (uint i = 0; i < allRounds.length; i++) {
            if (_timeStake >= allRounds[i].timeStart && _timeStake < allRounds[i].timeEnd) {
                vestingXPAD = allRounds[i].vesting;
                break;
            }
        }

        return vestingXPAD;
    }

    function getAllRounds() public view returns(Round[] memory) {
        return allRounds;
    }

    function getCurrentRound() public view returns(uint) {
        uint round;

        for (uint i = 0; i < allRounds.length; i++) {
            if (block.timestamp >= allRounds[i].timeStart && block.timestamp < allRounds[i].timeEnd) {
                round = i;
                break;
            }
        }

        return round;
    }

    function getCurrentMaxTotalAmount() public view returns(uint) {
        uint maxTotalAmount;

        for (uint i = 0; i < allRounds.length; i++) {
            if (block.timestamp >= allRounds[i].timeStart && block.timestamp < allRounds[i].timeEnd) {
                maxTotalAmount = allRounds[i].maxTotalAmount;
                break;
            }
        }

        return maxTotalAmount;
    }

}