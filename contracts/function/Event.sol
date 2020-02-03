pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "../libs/SafeMath.sol";
import './DataControl.sol';
import "../components/token/TokenControl.sol";

/**
 * @title Event
 * @dev Manages event storage
 * CONTRACT_NAME = "Event"
 */
contract Event is DataControl, TokenControl {
    using SafeMath for uint256;

    event AttendEvent(uint256 _eventId, string _userId, uint256 _rewardAmount);
    event RewardEvent(uint256 _eventId, string _userId, address _userWallet, uint256 _rewardAmount);

    function pushHistory(uint256 eventId, string email, uint256 amount) public onlyUser {
        string memory CONTRACT_NAME = "Event";
        setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(eventId, email)), getRewardToBeReceived(eventId, email).add(amount));
        emit AttendEvent(eventId, email, amount);
    }

    function removeHistory(uint256 eventId, string email, uint256 amount) public onlyUser {
        string memory CONTRACT_NAME = "Event";
        setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(eventId, email)), getRewardToBeReceived(eventId, email).sub(amount));
    }

    function sendReward(uint256 _eventId, string[] _userId, address[] _userWallet, uint256[] _rewardAmount)
        public
        onlyAdmin
    {
        for (uint256 i = 0; i < _userWallet.length; i++) {
            uint256 userBenefit = getRewardToBeReceived(_eventId, _userId[i]);
            require(userBenefit >= _rewardAmount[i], "Event : Abnomal reward");
            setUintStorage("Event", keccak256(abi.encodePacked(_eventId, _userId[i])), userBenefit.sub(_rewardAmount[i]));
            _rewardAmount[i] = _rewardAmount[i].mul(1 ether);
            _sendToken("SPIN", _userWallet[i], _rewardAmount[i]);
            emit RewardEvent(_eventId, _userId[i], _userWallet[i], _rewardAmount[i]);
        }
    }

    function getRewardToBeReceived(uint256 _eventId, string _userId) public view returns(uint256) {
        return getUintStorage("Event", keccak256(abi.encodePacked(_eventId, _userId)));
    }
}