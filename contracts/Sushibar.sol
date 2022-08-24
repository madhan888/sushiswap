pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/maths/SafeMath.sol";

contract SushiBar is ERC20("SushiBar","xSUSHI"){
    using SafeMath for uint256;
    IERC20 puvlic sushi;

    struct Stake{
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) userStake;

    constructor(IERC20 _sushi) public{
        suhi = _sushi;
    }

    function enter(uint256 _amount) public{

        uint256 totalSushi = sushi.balanceOf(address(this));
        uint256 totalShares = totalSupply;

        if(totalShares == 0 || totalSushi ==0){
            _mint(msg.sender,_amount);

            }

        else {
            uint256 what = _amount.mul(totalShares).div(totalSushi);
            _mint(msg.sender,what);
        }

        userStake[msg.sender].timestamp = block.timestamp;
        userStake[msg.sender].amount = _amount;

        sushi.transferFrom(msg.sender , address(this), _amount);
        
    }

    function leave(uint256 _share) public{

        uint256 totalShares = totalSupply();

    uint256 what = _share.mul(sushi.balanceOf(address(this))).div(totalShares);
    
    uint256 unlock = _unlock(userStake[msg.sender].amount);

    require(what > 0 && what <= unlock,"unable to unstake at this time" );

    uint256 tax = _tax(what);
    sushi.transfer(address(this),tax);

    uint256 finalAmount = unlock.sub(tax);
    sushi.transfer(msg.sender, finalAmount);

    userStake[msg.sender].amount -= unlock;

    _burn(msg.sender , unlock);
 
    }



    function _unlock(uint256 _what) internal view returns(uint256)
    {
        if(userStake[msg.sender].amount == 0){
            return 0;
        }

        else{
            uint256 time = block.timestamp - userStake[msg.sender].timestamp;
            if (time < 2*24*60*60){
                return 0;
            }
            else if (time < 4*24*60*60){
                return _what.mul(25).div(100);
            }

            else if (time < 6*24*60*60){
                return _what.mul(50).div(100);
            } 

            else if (time < 8*24*60*60){
                return _what.mul(75).div(100);
            }

            else{
                return _what;
            }
        }
    }


    function _tax(uint256 _unlocked) internal view returns(uint256)
    {
        if (userStake[msg.sender].amount == 0)
        {
            return 0;
        }

        else{
            uint256 time = block.timestamp - userStake[msg.sender].timestamp;

            if(time < 2*24*60*60)
            {
                return 0;
            }

            else if(time < 4*24*60*60)
            {
                return _unlocked.mul(75).div(100);
            }

            else if ( time < 6*24*60*60)
            {
                return _unlocked.mul(50).div(100);
            }

            else if ( time < 8*24*60*60)
            {
                return _unlocked.mul(25).div(100); 
            }

            else{
                return 0;
            }
        }
    }

}