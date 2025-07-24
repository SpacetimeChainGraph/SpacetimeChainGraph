// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ClaimShield - Decentralized claim scoring with referral logic
/// @author Pavan Kumar
/// @notice Handles trust anchoring and incentive scoring
contract ClaimShield {
    
    struct Claim {
        address claimant;
        string uri;             // IPFS CID or semantic URI
        uint256 timestamp;
        uint256 score;         // Reputation score
        bool verified;
    }

    mapping(bytes32 => Claim) public claims;       // Claim hash → data
    mapping(address => uint256) public reputation;  // User reputation score
    mapping(address => address[]) public referrals; // Who referred whom

    event ClaimSubmitted(bytes32 indexed claimHash, address indexed claimant);
    event ClaimVerified(bytes32 indexed claimHash, uint256 score);

    /// @dev Submits a claim and stores metadata
    function submitClaim(string memory uri) external {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, uri, block.timestamp));
        claims[hash] = Claim(msg.sender, uri, block.timestamp, 0, false);
        emit ClaimSubmitted(hash, msg.sender);
    }

    /// @dev Refers another user and earns passive reputation
    function refer(address newUser) external {
        referrals[msg.sender].push(newUser);
        reputation[msg.sender] += 1;
    }

    /// @dev Admin/validator verifies the claim and assigns score
    function verifyClaim(bytes32 claimHash, uint256 score) external {
        require(!claims[claimHash].verified, "Already verified");
        claims[claimHash].verified = true;
        claims[claimHash].score = score;
        reputation[claims[claimHash].claimant] += score;
        emit ClaimVerified(claimHash, score);
    }
}