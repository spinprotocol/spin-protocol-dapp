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

    event AttendEvent(uint256 _eventId, string _userId, address _userWallet, uint256 _rewardAmount);
    event RewardEvent(uint256 _eventId, string _userId, address _userWallet, uint256 _rewardAmount);

    function pushHistory(uint256 _eventId, string _userId, address _userWallet, uint256 _rewardAmount) public onlyUser {
        string memory CONTRACT_NAME = "Event";
        uint256 userBenefit = getEventBenefitCount(_eventId, _userId);
        setUintStorage(CONTRACT_NAME, keccak256(abi.encodePacked(_eventId, _userId)), userBenefit.add(1));
        emit AttendEvent(_eventId, _userId, _userWallet, _rewardAmount);
    }

    function sendReward(uint256 _eventId, string[] _userId, address[] _userWallet, uint256[] _rewardAmount)
        public
        onlyAdmin
    {
        for (uint256 i = 0; i < _userWallet.length; i++) {
            uint256 userBenefit = getEventBenefitCount(_eventId, _userId[i]);
            require(userBenefit > 0, "Event : Abnomal reward");
            _rewardAmount[i] = _rewardAmount[i].mul(1 ether);
            _sendToken("SPIN", _userWallet[i], _rewardAmount[i]);
            setUintStorage("Event", keccak256(abi.encodePacked(_eventId, _userId[i])), userBenefit.sub(1));
            emit RewardEvent(_eventId, _userId[i], _userWallet[i], _rewardAmount[i]);
        }
    }

    function getEventBenefitCount(uint256 _eventId, string _userId) public view returns(uint256) {
        return getUintStorage("Event", keccak256(abi.encodePacked(_eventId, _userId)));
    }
}