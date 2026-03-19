# Atomic Token Swapper (HTLC)

This repository provides a secure, expert-level implementation of an **Atomic Swap** using Hashed Timelock Contracts (HTLC). It allows for the peer-to-peer exchange of assets across different users with zero counterparty risk.

## Mechanism
- **Hashlock**: The swap is locked with a cryptographic hash. The originator creates a secret (preimage), and the recipient must provide this secret to claim the tokens.
- **Timelock**: If the swap is not completed within a specific timeframe, the originator can reclaim their tokens, preventing funds from being locked forever.

## Use Cases
- OTC (Over-the-Counter) private trades.
- Cross-chain swaps (when deployed on multiple EVM chains).
- Trustless escrow services.

## License
MIT
