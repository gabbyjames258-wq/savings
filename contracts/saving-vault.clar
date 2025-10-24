;; Savings Vault Contract
;; Allows depositing STX liquidity, tracking balances, and withdrawing with simulated interest.

(define-constant ERR-INSUFFICIENT-BALANCE (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant INTEREST-RATE u5) ;; 5% fixed for demo

(define-data-var total-liquidity uint u0)
(define-map user-balances
    principal
    uint
)

(define-public (deposit (amount uint))
    (let ((current-balance (default-to u0 (map-get? user-balances tx-sender))))
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set user-balances tx-sender (+ current-balance amount))
        (var-set total-liquidity (+ (var-get total-liquidity) amount))
        (ok true)
    )
)

(define-public (withdraw (amount uint))
    (let (
            (current-balance (default-to u0 (map-get? user-balances tx-sender)))
            (interest (/ (* amount INTEREST-RATE) u100))
            (total-withdraw (+ amount interest))
        )
        (if (>= current-balance amount)
            (begin
                (try! (as-contract (stx-transfer? total-withdraw tx-sender tx-sender)))
                (map-set user-balances tx-sender (- current-balance amount))
                (var-set total-liquidity (- (var-get total-liquidity) amount))
                (ok total-withdraw)
            )
            ERR-INSUFFICIENT-BALANCE
        )
    )
)

(define-read-only (get-balance (user principal))
    (default-to u0 (map-get? user-balances user))
)

(define-read-only (get-total-liquidity)
    (var-get total-liquidity)
)

(define-public (emergency-withdraw-all)
    (let ((balance (default-to u0 (map-get? user-balances tx-sender))))
        (if (> balance u0)
            (begin
                (try! (as-contract (stx-transfer? balance tx-sender tx-sender)))
                (map-delete user-balances tx-sender)
                (var-set total-liquidity (- (var-get total-liquidity) balance))
                (ok balance)
            )
            ERR-INSUFFICIENT-BALANCE
        )
    )
)