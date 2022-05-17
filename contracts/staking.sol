pragma solidity ^0.8.7;

//importing IERC20 contract from oppenzepplin
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//errors for the contract
// error saves gas compared to "require" 
error Staking__TransferFailed();

contract Staking {

    //IERC20 wrapper to convert the staking token
    IERC20 public staking_token; //storing the staking token address
    uint256 public totalSupply; // storing the total pool of the contract
    uint256 public rewardPerTokenStored;
    uint256 public RewardRate;
    uint256 public lastUpdateTime;

    mapping(address => uint256) public balances; //mapping address -> amount they stake

    // modifier to keep updating the reward
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        _;
    }

    function rewardPerToken() public view returns(uint256){
        if (totalSupply == 0){
            return rewardPerTokenStored;
        }
        //1e18 is to convert it to wei
        return rewardPerTokenStored + (((block.timestamp - lastUpdateTime)*RewardRate *1e18)/totalSupply);
    }

    constructor(address token) {
        // storing the token address
        staking_token = IERC20(token);
    }

    //staking function
    function stake(uint256 amount) external {
        //updating the balance
        balances[msg.sender] = balances[msg.sender] + amount;
        //updating the total supply of the contract
        totalSupply = totalSupply + amount;

        // now transfering the staking tokens from sender's address to this contract
        bool success = staking_token.transferFrom(msg.sender, address(this), amount);

        // would require successful transfering
        // require(success, "failed to receipt stakes"); 
        if(!success) {
            revert Staking__TransferFailed();
            // 'revert' will unchange the states and changes happend just priviously, if error happens
        }

    }

    // withdraw function
    function withdraw(uint256 amount) external {
        //updating the balance
        balances[msg.sender] = balances[msg.sender] - amount;
        //updating the total supply of the contract
        totalSupply = totalSupply - amount;

        //now transfering the staked token from this contract to the user
        bool success = staking_token.transfer(msg.sender, amount);

        if(!success){
            revert Staking__TransferFailed();
        }

    }


    // claim reward function
    function claimReward() external {
          
    }
}
