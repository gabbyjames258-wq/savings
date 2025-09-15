;; contracts/messagechain.clar
;; MessageChain - On-Chain Messages 
;; Users can post short text messages stored on-chain.

(define-map messages
  principal
  (string-utf8 100)
)

;; Post a message
(define-public (post (msg (string-utf8 100)))
  (begin
    (map-set messages tx-sender msg)
    (ok msg)
  )
)

;; --- Views ---
(define-read-only (get-message (user principal)) (map-get? messages user))
