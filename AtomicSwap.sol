// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AtomicSwap
 * @dev Implementation of an HTLC for swapping ERC20 tokens trustlessly.
 */
contract AtomicSwap {
    struct Swap {
        address initiator;
        address participant;
        address token;
        uint256 amount;
        bytes32 hashLock; // keccak256(secret)
        uint256 expiration; // timestamp
        bool completed;
        bool refunded;
    }

    mapping(bytes32 => Swap) public swaps;

    event SwapInitiated(bytes32 indexed swapId, address indexed initiator, address indexed participant, uint256 amount);
    event SwapClaimed(bytes32 indexed swapId, bytes32 secret);
    event SwapRefunded(bytes32 indexed swapId);

    /**
     * @dev Initiator locks tokens into the contract.
     */
    function initiate(
        bytes32 _swapId,
        address _participant,
        address _token,
        uint256 _amount,
        bytes32 _hashLock,
        uint256 _timelock
    ) external {
        require(swaps[_swapId].initiator == address(0), "Swap ID exists");
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        swaps[_swapId] = Swap({
            initiator: msg.sender,
            participant: _participant,
            token: _token,
            amount: _amount,
            hashLock: _hashLock,
            expiration: block.timestamp + _timelock,
            completed: false,
            refunded: false
        });

        emit SwapInitiated(_swapId, msg.sender, _participant, _amount);
    }

    /**
     * @dev Participant claims tokens by providing the secret preimage.
     */
    function claim(bytes32 _swapId, bytes32 _secret) external {
        Swap storage swap = swaps[_swapId];
        require(keccak256(abi.encodePacked(_secret)) == swap.hashLock, "Invalid secret");
        require(!swap.completed, "Already completed");
        require(!swap.refunded, "Already refunded");

        swap.completed = true;
        require(IERC20(swap.token).transfer(swap.participant, swap.amount), "Transfer failed");

        emit SwapClaimed(_swapId, _secret);
    }

    /**
     * @dev Initiator refunds tokens if the timelock has expired.
     */
    function refund(bytes32 _swapId) external {
        Swap storage swap = swaps[_swapId];
        require(msg.sender == swap.initiator, "Not initiator");
        require(block.timestamp >= swap.expiration, "Not expired");
        require(!swap.completed, "Already completed");
        require(!swap.refunded, "Already refunded");

        swap.refunded = true;
        require(IERC20(swap.token).transfer(swap.initiator, swap.amount), "Transfer failed");

        emit SwapRefunded(_swapId);
    }
}
