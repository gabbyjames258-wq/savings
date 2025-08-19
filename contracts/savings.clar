;; contracts/savings.clar
;; Simple STX Savings Pool
;; - Users deposit STX
;; - Users can withdraw their deposits
;; - Track balances + total deposits

(define-map balances
    { user: principal }
    { amount: uint }
)
(define-data-var total-deposits uint u0)
(define-data-var contract-owner principal tx-sender)

(define-constant ERR-NOT-ENOUGH u100)
(define-constant ERR-NOT-OWNER u101)
(define-constant ERR-INVALID u102)

;; --- deposit STX into pool ---
(define-public (deposit (amount uint))
    (begin
        (asserts! (> amount u0) (err ERR-INVALID))
        (try! (stx-transfer? amount tx-sender (contract-of self)))
        (let ((prev (default-to u0 (get amount (map-get? balances { user: tx-sender })))))
            (map-set balances { user: tx-sender } { amount: (+ prev amount) })
            (var-set total-deposits (+ (var-get total-deposits) amount))
            (ok true)
        )
    )
)

;; --- withdraw STX from pool ---
(define-public (withdraw (amount uint))
    (let ((current (default-to u0 (get amount (map-get? balances { user: tx-sender })))))
        (begin
            (asserts! (> amount u0) (err ERR-INVALID))
            (asserts! (>= current amount) (err ERR-NOT-ENOUGH))
            (try! (stx-transfer? amount (contract-of self) tx-sender))
            (map-set balances { user: tx-sender } { amount: (- current amount) })
            (var-set total-deposits (- (var-get total-deposits) amount))
            (ok true)
        )
    )
)

;; --- read-only views ---
(define-read-only (get-balance (who principal))
    (default-to u0 (get amount (map-get? balances { user: who })))
)

(define-read-only (get-total)
    (var-get total-deposits)
)

(define-read-only (get-owner)
    (var-get contract-owner)
)