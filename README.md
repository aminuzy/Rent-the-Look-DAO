# 👗 Rent-the-Look DAO

> A decentralized fashion rental marketplace powered by Stacks blockchain where outfits are lent with on-chain collateral and STX staking.

## 🌟 Overview

Rent-the-Look DAO enables users to rent fashion outfits in a trustless environment. Outfit owners list their items, renters provide collateral, and everything is secured on-chain with automatic expiration logic.

## ✨ Key Features

- 💰 **STX Staking**: Users stake STX to back the marketplace and earn protocol fees
- 👔 **Outfit Listings**: List your fashion items with custom pricing and collateral requirements
- 🔒 **Collateral Locking**: Secure rentals with on-chain collateral management
- ⏰ **Rental Expiration**: Automatic time-based rental periods using block height
- 🎯 **Protocol Fees**: 5% fee distributed to STX stakers (configurable)
- 🔐 **Trustless Returns**: Return outfits to unlock collateral, or owners claim after expiration

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet with STX tokens

### Installation

```bash
git clone <your-repo-url>
cd Rent-the-Look-DAO
clarinet check
```

## 📖 Usage Guide

### For Stakers 💎

**Stake STX to support the platform:**
```clarity
(contract-call? .Rent-the-Look-DAO stake-stx u1000000)
```

**Unstake STX:**
```clarity
(contract-call? .Rent-the-Look-DAO unstake-stx u500000)
```

### For Outfit Owners 👗

**List an outfit for rent:**
```clarity
(contract-call? .Rent-the-Look-DAO list-outfit 
    "Designer Evening Gown" 
    u100000        ;; rental price (1 STX)
    u500000        ;; collateral required (5 STX)
    u144           ;; rental duration (144 blocks ≈ 1 day)
)
```

**Claim collateral after rental expires:**
```clarity
(contract-call? .Rent-the-Look-DAO claim-collateral u1)
```

**Update outfit availability:**
```clarity
(contract-call? .Rent-the-Look-DAO update-outfit-availability u1 false)
```

### For Renters 🛍️

**Rent an outfit:**
```clarity
(contract-call? .Rent-the-Look-DAO rent-outfit u1)
```
*Automatically locks collateral + pays rental fee*

**Return the outfit:**
```clarity
(contract-call? .Rent-the-Look-DAO return-outfit u1)
```
*Unlocks your collateral immediately*

## 🔍 Read-Only Functions

**Get outfit details:**
```clarity
(contract-call? .Rent-the-Look-DAO get-outfit u1)
```

**Check rental status:**
```clarity
(contract-call? .Rent-the-Look-DAO get-rental-status u1)
```

**View user's outfits:**
```clarity
(contract-call? .Rent-the-Look-DAO get-user-outfits 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Check stake amount:**
```clarity
(contract-call? .Rent-the-Look-DAO get-stake 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Get total staked:**
```clarity
(contract-call? .Rent-the-Look-DAO get-total-staked)
```

## 📊 Contract Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `protocol-fee-percent` | 5% | Fee taken from each rental (adjustable by owner) |
| `rental-duration` | Custom | Set per outfit in blocks (144 blocks ≈ 1 day) |

## 🔐 Security Features

- ✅ Collateral locked in contract escrow
- ✅ Time-based rental expiration using block height
- ✅ Owner-only functions for critical operations
- ✅ No collateral loss if returned on time
- ✅ Automatic availability updates

## 🛠️ Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Action restricted to owner |
| u101 | `err-not-found` | Outfit or rental not found |
| u102 | `err-already-rented` | Outfit currently unavailable |
| u103 | `err-insufficient-collateral` | Not enough collateral provided |
| u104 | `err-not-renter` | Caller is not the renter |
| u105 | `err-rental-not-expired` | Rental period still active |
| u106 | `err-already-returned` | Outfit already returned |
| u107 | `err-insufficient-stake` | Not enough staked tokens |
| u108 | `err-no-stake` | No active stake found |
| u109 | `err-invalid-params` | Invalid parameters provided |

## 🧪 Testing

```bash
clarinet test
```

## 📝 Smart Contract Functions

### Public Functions
- `stake-stx` - Stake STX to support the platform
- `unstake-stx` - Withdraw staked STX
- `list-outfit` - List a new outfit for rent
- `rent-outfit` - Rent an available outfit
- `return-outfit` - Return a rented outfit
- `claim-collateral` - Claim collateral after expiration
- `update-outfit-availability` - Toggle outfit availability
- `update-protocol-fee` - Update protocol fee (owner only)

### Read-Only Functions
- `get-outfit` - Get outfit details
- `get-rental` - Get rental information
- `get-stake` - Get user's stake info
- `get-total-staked` - Get total STX staked
- `get-user-outfits` - Get user's outfit IDs
- `get-protocol-fee` - Get current protocol fee
- `is-rental-expired` - Check if rental expired
- `get-rental-status` - Get detailed rental status

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language](https://docs.stacks.co/clarity/)
- [Clarinet](https://github.com/hirosystems/clarinet)

---

Made with ❤️ for the Stacks ecosystem
