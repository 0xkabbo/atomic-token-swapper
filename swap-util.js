const crypto = require('crypto');
const { ethers } = require('ethers');

/**
 * Helper to generate the secret and hashlock for the swap.
 */
function generateSecret() {
    const secret = crypto.randomBytes(32);
    const hashLock = ethers.keccak256(secret);
    
    return {
        secret: '0x' + secret.toString('hex'),
        hashLock: hashLock
    };
}

const pair = generateSecret();
console.log("Secret (Preimage):", pair.secret);
console.log("HashLock (To be used in initiate):", pair.hashLock);
