# BitTrust Protocol

![BitTrust Protocol](https://img.shields.io/badge/Protocol-BitTrust-orange)
![Stacks](https://img.shields.io/badge/Blockchain-Stacks-blue)
![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-yellow)
![Clarity](https://img.shields.io/badge/Language-Clarity-green)
![License](https://img.shields.io/badge/License-ISC-blue)

## 🚀 Overview

BitTrust Protocol is an innovative Bitcoin-secured reputation system that enables trustless peer-to-peer lending through algorithmic credit scoring and decentralized risk assessment on the Stacks blockchain. By leveraging Bitcoin's proof-of-work security, BitTrust creates a new paradigm for decentralized finance where users can establish verifiable digital reputation that unlocks progressive lending opportunities.

### Key Features

- **🔐 Bitcoin-Secured Trust**: Anchored to Bitcoin's immutable ledger for maximum security
- **📊 Algorithmic Credit Scoring**: Dynamic reputation system based on on-chain behavior
- **🏦 Trustless Lending**: Peer-to-peer loans without traditional banking intermediaries
- **⚡ Progressive Credit Building**: Users can improve their scores through successful repayments
- **🎯 Intelligent Risk Engine**: Automatically adjusts loan parameters based on historical performance
- **🌍 Global Financial Inclusion**: Accessible to anyone with a Stacks wallet

## 🏗️ Architecture

### Core Components

1. **Credit Profile System**: Comprehensive user reputation tracking
2. **Loan Management Engine**: Automated loan origination and tracking
3. **Collateral Vault**: Secure collateral management with automatic release
4. **Risk Assessment Algorithm**: Dynamic interest rate and collateral calculations
5. **Reputation Engine**: Bitcoin-secured credit score updates

### Protocol Constants

| Parameter | Value | Description |
|-----------|-------|-------------|
| Initial Credit Score | 350 | Starting reputation for new users |
| Maximum Credit Score | 900 | Highest achievable reputation |
| Lending Threshold | 450 | Minimum score required for borrowing |
| Concurrent Loan Limit | 5 | Maximum active loans per user |
| Max Loan Term | 35,040 blocks | ~8 months maximum loan duration |
| Base APR | 10% | Baseline annual interest rate |
| Collateral Ceiling | 140% | Maximum collateral requirement |
| Minimum Loan | 0.1 STX | Smallest loan amount allowed |

## 🛠️ Getting Started

### Prerequisites

- [Clarinet](https://docs.hiro.so/stacks/clarinet) v2.0 or higher
- [Node.js](https://nodejs.org/) v18 or higher
- [Stacks Wallet](https://www.hiro.so/wallet) for interacting with the protocol

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/ekanah-iyene/BitTrust.git
   cd BitTrust
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Check contract syntax**

   ```bash
   clarinet check
   ```

4. **Run tests**

   ```bash
   npm test
   ```

### Local Development

Start the Clarinet console for interactive testing:

```bash
clarinet console
```

Deploy to local devnet:

```bash
clarinet integrate
```

## 📚 Usage Guide

### For Borrowers

#### 1. Initialize Credit Profile

Before borrowing, users must create their credit profile:

```clarity
(contract-call? .bittrust initialize-credit-profile)
```

#### 2. Preview Loan Eligibility

Check your borrowing capacity and terms:

```clarity
(contract-call? .bittrust preview-loan-eligibility 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u500000)
```

#### 3. Request a Loan

Execute a loan request with your desired parameters:

```clarity
(contract-call? .bittrust execute-loan-request 
  u500000    ;; Loan amount (0.5 STX)
  u700000    ;; Collateral deposit (0.7 STX)
  u17520)    ;; Loan term (~4 months)
```

#### 4. Make Repayments

Repay your loan to improve your credit score:

```clarity
(contract-call? .bittrust process-repayment 
  u1         ;; Loan ID
  u550000)   ;; Payment amount (principal + interest)
```

### For Protocol Administrators

#### Monitor Protocol Health

```clarity
(contract-call? .bittrust get-protocol-analytics)
```

#### Handle Loan Defaults

```clarity
(contract-call? .bittrust handle-loan-default u1) ;; Loan ID
```

#### Emergency Protocol Controls

```clarity
(contract-call? .bittrust toggle-protocol-status)
```

## 🔍 API Reference

### Public Functions

#### `initialize-credit-profile()`

Creates a new credit profile for the caller with initial credit score of 350.

**Returns:** `(response bool uint)`

#### `execute-loan-request(requested-amount, collateral-deposit, loan-duration)`

Processes a new loan request with dynamic terms based on the borrower's credit score.

**Parameters:**

- `requested-amount` (uint): Loan amount in micro-STX
- `collateral-deposit` (uint): Collateral amount in micro-STX  
- `loan-duration` (uint): Loan term in blocks

**Returns:** `(response uint uint)` - Loan ID on success

#### `process-repayment(loan-identifier, payment-amount)`

Processes loan repayment and updates credit score accordingly.

**Parameters:**

- `loan-identifier` (uint): Unique loan ID
- `payment-amount` (uint): Repayment amount in micro-STX

**Returns:** `(response bool uint)`

### Read-Only Functions

#### `get-user-profile(user-address)`

Retrieves comprehensive credit profile for a user.

#### `get-loan-information(loan-identifier)`

Returns detailed loan information including terms, progress, and status.

#### `get-borrower-portfolio(borrower-address)`

Gets all active loan IDs for a specific borrower.

#### `get-protocol-analytics()`

Returns protocol-wide statistics including TVL and loan metrics.

#### `preview-loan-eligibility(user-address, amount)`

Calculates loan terms without executing the transaction.

## 🧪 Testing

The protocol includes comprehensive test coverage using Vitest and Clarinet SDK.

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:report

# Watch mode for development
npm run test:watch
```

### Test Structure

```
tests/
├── bittrust.test.ts     # Main contract tests
└── integration/         # Integration test scenarios
```

## 🔐 Security Considerations

### Smart Contract Security

- **Reentrancy Protection**: All external calls are protected against reentrancy attacks
- **Input Validation**: Comprehensive parameter validation on all public functions
- **Access Control**: Role-based permissions for administrative functions
- **Integer Overflow Protection**: Safe arithmetic operations throughout

### Economic Security

- **Collateral Requirements**: Dynamic collateral ratios based on credit scores
- **Interest Rate Models**: Algorithmic rate adjustments prevent exploitation
- **Loan Limits**: Per-user concurrent loan limits prevent over-leveraging
- **Default Handling**: Automated liquidation mechanisms protect lender interests

### Audit Status

🚨 **This protocol is currently unaudited.** Use at your own risk in production environments.

## 🤝 Contributing

We welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add tests
4. Run the test suite: `npm test`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📊 Protocol Economics

### Credit Score Algorithm

Credit scores range from 350 (initial) to 900 (maximum) and are updated based on:

- **Successful Repayments**: +20 points (small loans) or +35 points (large loans)
- **Loan Defaults**: -60 points penalty
- **Loan Volume**: Higher volume transactions earn more points
- **Repayment Speed**: Early repayments improve score calculations

### Interest Rate Model

```
Interest Rate = Base Rate - (Credit Score Discount)
Minimum Rate = 5% (floor rate)
Maximum Rate = 10% (base rate)
```

### Collateral Requirements

```
Collateral Ratio = 140% - (Credit Score Bonus)
Range: 100% - 140% based on credit score
```

## 🗺️ Roadmap

### Phase 1: Core Protocol (Current)

- ✅ Basic lending functionality
- ✅ Credit scoring system
- ✅ Collateral management
- ✅ Automated repayments

### Phase 2: Enhanced Features (Q1 2025)

- 🔄 Multi-asset collateral support
- 🔄 Governance token integration
- 🔄 Advanced risk models
- 🔄 Cross-chain compatibility

### Phase 3: Ecosystem Growth (Q2 2025)

- 📋 Third-party integrations
- 📋 Mobile application
- 📋 Institutional lending pools
- 📋 Insurance mechanisms

## 📄 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.
