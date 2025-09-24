;; Title: BitTrust Protocol
;;
;; Summary:
;; An innovative Bitcoin-secured reputation system that enables 
;; trustless peer-to-peer lending through algorithmic credit scoring
;; and decentralized risk assessment on the Stacks blockchain.
;;
;; Description:
;; BitTrust Protocol creates a new paradigm for decentralized finance
;; by building verifiable trust networks secured by Bitcoin's proof-of-work.
;; Through transparent on-chain behavior analysis, users establish
;; digital reputation that unlocks progressive lending opportunities.
;; The protocol's intelligent risk engine automatically adjusts loan
;; parameters based on historical performance, creating a self-sustaining
;; credit ecosystem that operates without traditional banking intermediaries.
;; By anchoring trust to Bitcoin's immutable ledger, BitTrust enables
;; global financial inclusion while maintaining cryptographic security.
;;
;; PROTOCOL CONFIGURATION

;; Core system constants
(define-constant CONTRACT_OWNER tx-sender)

;; Error definitions
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_PARAMETERS (err u102))
(define-constant ERR_LOAN_NOT_FOUND (err u103))
(define-constant ERR_LOAN_EXPIRED (err u104))
(define-constant ERR_CREDIT_INSUFFICIENT (err u105))
(define-constant ERR_LOAN_LIMIT_REACHED (err u106))
(define-constant ERR_REPAYMENT_NOT_DUE (err u107))

;; Credit system parameters
(define-constant INITIAL_CREDIT_SCORE u350)
(define-constant MAXIMUM_CREDIT_SCORE u900)
(define-constant LENDING_THRESHOLD u450)
(define-constant CONCURRENT_LOAN_LIMIT u5)

;; Lending configuration
(define-constant MAX_LOAN_TERM u35040) ;; ~8 months in blocks
(define-constant BASE_APR u1000) ;; 10% baseline annual rate
(define-constant COLLATERAL_CEILING u140) ;; 140% maximum collateral ratio
(define-constant MIN_LOAN_AMOUNT u100000) ;; 0.1 STX minimum

;; DATA MODELS

;; Comprehensive credit profile structure
(define-map user-profiles
  { address: principal }
  {
    credit-score: uint,
    total-volume-borrowed: uint,
    total-volume-repaid: uint,
    completed-loans: uint,
    failed-loans: uint,
    average-repayment-speed: uint,
    last-interaction: uint,
    profile-inception: uint,
  }
)

;; Detailed loan tracking
(define-map active-loans
  { loan-id: uint }
  {
    borrower-address: principal,
    loan-principal: uint,
    collateral-amount: uint,
    due-block: uint,
    applied-rate: uint,
    repayment-progress: uint,
    loan-state: (string-ascii 20),
    origination-block: uint,
  }
)

;; User loan portfolio management
(define-map borrower-portfolios
  { borrower: principal }
  { loan-identifiers: (list 5 uint) }
)

;; PROTOCOL STATE VARIABLES

(define-data-var loan-counter uint u1)
(define-data-var protocol-tvl uint u0)
(define-data-var total-loans-originated uint u0)
(define-data-var protocol-active bool true)

;; CORE PROTOCOL FUNCTIONS

;; Initialize user credit identity on Bitcoin-secured infrastructure
(define-public (initialize-credit-profile)
  (let ((user-address tx-sender))
    (asserts! (is-none (map-get? user-profiles { address: user-address }))
      ERR_NOT_AUTHORIZED
    )

    (ok (map-set user-profiles { address: user-address } {
      credit-score: INITIAL_CREDIT_SCORE,
      total-volume-borrowed: u0,
      total-volume-repaid: u0,
      completed-loans: u0,
      failed-loans: u0,
      average-repayment-speed: u0,
      last-interaction: stacks-block-height,
      profile-inception: stacks-block-height,
    }))
  )
)

;; Execute loan request with dynamic terms based on Bitcoin-secured reputation
(define-public (execute-loan-request
    (requested-amount uint)
    (collateral-deposit uint)
    (loan-duration uint)
  )
  (let (
      (borrower tx-sender)
      (current-loan-id (var-get loan-counter))
      (user-profile (unwrap! (map-get? user-profiles { address: borrower }) ERR_NOT_AUTHORIZED))
      (current-portfolio (default-to { loan-identifiers: (list) }
        (map-get? borrower-portfolios { borrower: borrower })
      ))
    )
    ;; Comprehensive validation
    (asserts! (var-get protocol-active) ERR_NOT_AUTHORIZED)
    (asserts! (>= (get credit-score user-profile) LENDING_THRESHOLD)
      ERR_CREDIT_INSUFFICIENT
    )
    (asserts!
      (< (len (get loan-identifiers current-portfolio)) CONCURRENT_LOAN_LIMIT)
      ERR_LOAN_LIMIT_REACHED
    )
    (asserts!
      (and
        (>= requested-amount MIN_LOAN_AMOUNT)
        (> loan-duration u0)
        (<= loan-duration MAX_LOAN_TERM)
      )
      ERR_INVALID_PARAMETERS
    )

    ;; Dynamic loan term calculation
    (let (
        (minimum-collateral (compute-collateral-requirement requested-amount
          (get credit-score user-profile)
        ))
        (personalized-rate (compute-interest-rate (get credit-score user-profile)))
      )
      (asserts! (>= collateral-deposit minimum-collateral)
        ERR_INSUFFICIENT_BALANCE
      )

      ;; Secure collateral in protocol vault
      (try! (stx-transfer? collateral-deposit borrower (as-contract tx-sender)))

      ;; Register loan in protocol
      (map-set active-loans { loan-id: current-loan-id } {
        borrower-address: borrower,
        loan-principal: requested-amount,
        collateral-amount: collateral-deposit,
        due-block: (+ stacks-block-height loan-duration),
        applied-rate: personalized-rate,
        repayment-progress: u0,
        loan-state: "active",
        origination-block: stacks-block-height,
      })

      ;; Update borrower portfolio
      (map-set borrower-portfolios { borrower: borrower } { loan-identifiers: (unwrap!
        (as-max-len?
          (append (get loan-identifiers current-portfolio) current-loan-id) u5
        )
        ERR_LOAN_LIMIT_REACHED
      ) }
      )

      ;; Transfer approved amount to borrower
      (as-contract (try! (stx-transfer? requested-amount tx-sender borrower)))

      ;; Update protocol metrics
      (var-set loan-counter (+ current-loan-id u1))
      (var-set protocol-tvl (+ (var-get protocol-tvl) collateral-deposit))
      (var-set total-loans-originated (+ (var-get total-loans-originated) u1))

      (ok current-loan-id)
    )
  )
)

;; Process loan repayment with Bitcoin-secured credit score updates
(define-public (process-repayment
    (loan-identifier uint)
    (payment-amount uint)
  )
  (let (
      (borrower tx-sender)
      (loan-data (unwrap! (map-get? active-loans { loan-id: loan-identifier })
        ERR_LOAN_NOT_FOUND
      ))
    )
    (asserts! (is-eq borrower (get borrower-address loan-data))
      ERR_NOT_AUTHORIZED
    )
    (asserts! (is-eq (get loan-state loan-data) "active") ERR_LOAN_EXPIRED)
    (asserts! (> payment-amount u0) ERR_INVALID_PARAMETERS)

    ;; Calculate total obligation
    (let ((total-obligation (+ (get loan-principal loan-data) (calculate-interest-due loan-data))))
      ;; Process payment transaction
      (try! (stx-transfer? payment-amount borrower (as-contract tx-sender)))

      (let ((updated-repayment (+ (get repayment-progress loan-data) payment-amount)))
        ;; Update loan record
        (map-set active-loans { loan-id: loan-identifier }
          (merge loan-data {
            repayment-progress: updated-repayment,
            loan-state: (if (>= updated-repayment total-obligation)
              "completed"
              "active"
            ),
          })
        )

        ;; Handle loan completion
        (if (>= updated-repayment total-obligation)
          (begin
            (try! (update-credit-reputation borrower true loan-data))
            (as-contract (try! (stx-transfer? (get collateral-amount loan-data) tx-sender borrower)))
            (var-set protocol-tvl
              (- (var-get protocol-tvl) (get collateral-amount loan-data))
            )
          )
          true
        )
        (ok true)
      )
    )
  )
)

;; ALGORITHMIC CREDIT ENGINE

;; Dynamic collateral calculation based on Bitcoin-secured trust score
(define-private (compute-collateral-requirement
    (loan-amount uint)
    (trust-score uint)
  )
  (let ((collateral-multiplier (- COLLATERAL_CEILING
      (/ (* (- trust-score INITIAL_CREDIT_SCORE) u40)
        (- MAXIMUM_CREDIT_SCORE INITIAL_CREDIT_SCORE)
      ))))
    (/ (* loan-amount collateral-multiplier) u100)
  )
)

;; Personalized interest rate engine
(define-private (compute-interest-rate (trust-score uint))
  (let ((rate-discount (/ (* (- trust-score INITIAL_CREDIT_SCORE) u500)
      (- MAXIMUM_CREDIT_SCORE INITIAL_CREDIT_SCORE)
    )))
    (if (>= BASE_APR rate-discount)
      (- BASE_APR rate-discount)
      u500
    )
  )
  ;; 5% floor rate
)

;; Interest calculation for loan obligations
(define-private (calculate-interest-due (loan-record {
  borrower-address: principal,
  loan-principal: uint,
  collateral-amount: uint,
  due-block: uint,
  applied-rate: uint,
  repayment-progress: uint,
  loan-state: (string-ascii 20),
  origination-block: uint,
}))
  (/ (* (get loan-principal loan-record) (get applied-rate loan-record)) u10000)
)

;; Advanced reputation scoring algorithm secured by Bitcoin
(define-private (update-credit-reputation
    (user-address principal)
    (payment-success bool)
    (loan-record {
      borrower-address: principal,
      loan-principal: uint,
      collateral-amount: uint,
      due-block: uint,
      applied-rate: uint,
      repayment-progress: uint,
      loan-state: (string-ascii 20),
      origination-block: uint,
    })
  )
  (let (
      (current-profile (unwrap! (map-get? user-profiles { address: user-address })
        ERR_NOT_AUTHORIZED
      ))
      (reputation-delta (if payment-success
        (if (<= (get loan-principal loan-record) u1000000)
          u20
          u35
        )
        u60
      ))
      (updated-score (if payment-success
        (if (<= (+ (get credit-score current-profile) reputation-delta)
            MAXIMUM_CREDIT_SCORE
          )
          (+ (get credit-score current-profile) reputation-delta)
          MAXIMUM_CREDIT_SCORE
        )
        (if (>= (- (get credit-score current-profile) reputation-delta)
            INITIAL_CREDIT_SCORE
          )
          (- (get credit-score current-profile) reputation-delta)
          INITIAL_CREDIT_SCORE
        )
      ))
    )
    (ok (map-set user-profiles { address: user-address }
      (merge current-profile {
        credit-score: updated-score,
        total-volume-repaid: (if payment-success
          (+ (get total-volume-repaid current-profile)
            (get loan-principal loan-record)
          )
          (get total-volume-repaid current-profile)
        ),
        completed-loans: (if payment-success
          (+ (get completed-loans current-profile) u1)
          (get completed-loans current-profile)
        ),
        failed-loans: (if payment-success
          (get failed-loans current-profile)
          (+ (get failed-loans current-profile) u1)
        ),
        last-interaction: stacks-block-height,
      })
    ))
  )
)

;; PUBLIC QUERY INTERFACE

;; Retrieve comprehensive user credit profile
(define-read-only (get-user-profile (user-address principal))
  (map-get? user-profiles { address: user-address })
)

;; Get detailed loan information
(define-read-only (get-loan-information (loan-identifier uint))
  (map-get? active-loans { loan-id: loan-identifier })
)

;; Retrieve user's loan portfolio
(define-read-only (get-borrower-portfolio (borrower-address principal))
  (map-get? borrower-portfolios { borrower: borrower-address })
)

;; Protocol health and analytics
(define-read-only (get-protocol-analytics)
  {
    total-value-locked: (var-get protocol-tvl),
    loans-originated: (var-get total-loans-originated),
    next-loan-id: (var-get loan-counter),
    protocol-status: (var-get protocol-active),
  }
)

;; Preview loan eligibility and terms
(define-read-only (preview-loan-eligibility
    (user-address principal)
    (amount uint)
  )
  (match (map-get? user-profiles { address: user-address })
    profile (if (>= (get credit-score profile) LENDING_THRESHOLD)
      (ok {
        eligible: true,
        collateral-required: (compute-collateral-requirement amount (get credit-score profile)),
        interest-rate: (compute-interest-rate (get credit-score profile)),
        maximum-term: MAX_LOAN_TERM,
      })
      (ok {
        eligible: false,
        collateral-required: u0,
        interest-rate: u0,
        maximum-term: u0,
      })
    )
    (err ERR_NOT_AUTHORIZED)
  )
)

;; PROTOCOL ADMINISTRATION

;; Handle loan defaults and maintain protocol integrity
(define-public (handle-loan-default (loan-identifier uint))
  (let ((loan-record (unwrap! (map-get? active-loans { loan-id: loan-identifier })
      ERR_LOAN_NOT_FOUND
    )))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    ;; Validate loan identifier bounds
    (asserts!
      (and (> loan-identifier u0) (< loan-identifier (var-get loan-counter)))
      ERR_LOAN_NOT_FOUND
    )
    (asserts! (>= stacks-block-height (get due-block loan-record))
      ERR_REPAYMENT_NOT_DUE
    )
    (asserts! (is-eq (get loan-state loan-record) "active") ERR_LOAN_EXPIRED)

    ;; Mark loan as defaulted
    (map-set active-loans { loan-id: loan-identifier }
      (merge loan-record { loan-state: "defaulted" })
    )

    ;; Apply reputation penalty
    (try! (update-credit-reputation (get borrower-address loan-record) false
      loan-record
    ))

    (ok true)
  )
)

;; Emergency protocol controls
(define-public (toggle-protocol-status)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (var-set protocol-active (not (var-get protocol-active)))
    (ok (var-get protocol-active))
  )
)
