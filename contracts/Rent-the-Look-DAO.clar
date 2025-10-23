;; title: Rent-the-Look-DAO

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-rented (err u102))
(define-constant err-insufficient-collateral (err u103))
(define-constant err-not-renter (err u104))
(define-constant err-rental-not-expired (err u105))
(define-constant err-already-returned (err u106))
(define-constant err-insufficient-stake (err u107))
(define-constant err-no-stake (err u108))
(define-constant err-invalid-params (err u109))

(define-data-var next-outfit-id uint u1)
(define-data-var total-staked uint u0)
(define-data-var protocol-fee-percent uint u5)

(define-map outfits
    uint
    {
        owner: principal,
        name: (string-ascii 50),
        rental-price: uint,
        collateral-required: uint,
        rental-duration: uint,
        available: bool
    }
)

(define-map rentals
    uint
    {
        renter: principal,
        rental-start: uint,
        rental-end: uint,
        collateral-locked: uint,
        returned: bool
    }
)

(define-map stakes
    principal
    {
        amount: uint,
        staked-at: uint
    }
)

(define-map user-outfits
    principal
    (list 100 uint)
)

(define-public (stake-stx (amount uint))
    (let
        (
            (current-stake (default-to { amount: u0, staked-at: u0 } (map-get? stakes tx-sender)))
            (new-amount (+ (get amount current-stake) amount))
        )
        (asserts! (> amount u0) err-invalid-params)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set stakes tx-sender { amount: new-amount, staked-at: stacks-block-height })
        (var-set total-staked (+ (var-get total-staked) amount))
        (ok new-amount)
    )
)

(define-public (unstake-stx (amount uint))
    (let
        (
            (current-stake (unwrap! (map-get? stakes tx-sender) err-no-stake))
            (staked-amount (get amount current-stake))
        )
        (asserts! (>= staked-amount amount) err-insufficient-stake)
        (asserts! (> amount u0) err-invalid-params)
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        (if (is-eq staked-amount amount)
            (map-delete stakes tx-sender)
            (map-set stakes tx-sender { amount: (- staked-amount amount), staked-at: (get staked-at current-stake) })
        )
        (var-set total-staked (- (var-get total-staked) amount))
        (ok amount)
    )
)

(define-public (list-outfit (name (string-ascii 50)) (rental-price uint) (collateral-required uint) (rental-duration uint))
    (let
        (
            (outfit-id (var-get next-outfit-id))
            (user-outfit-list (default-to (list) (map-get? user-outfits tx-sender)))
        )
        (asserts! (> rental-price u0) err-invalid-params)
        (asserts! (> collateral-required u0) err-invalid-params)
        (asserts! (> rental-duration u0) err-invalid-params)
        (map-set outfits outfit-id {
            owner: tx-sender,
            name: name,
            rental-price: rental-price,
            collateral-required: collateral-required,
            rental-duration: rental-duration,
            available: true
        })
        (map-set user-outfits tx-sender (unwrap-panic (as-max-len? (append user-outfit-list outfit-id) u100)))
        (var-set next-outfit-id (+ outfit-id u1))
        (ok outfit-id)
    )
)

(define-public (rent-outfit (outfit-id uint))
    (let
        (
            (outfit (unwrap! (map-get? outfits outfit-id) err-not-found))
            (rental-price (get rental-price outfit))
            (collateral-required (get collateral-required outfit))
            (rental-duration (get rental-duration outfit))
            (total-payment (+ rental-price collateral-required))
            (protocol-fee (/ (* rental-price (var-get protocol-fee-percent)) u100))
            (owner-payment (- rental-price protocol-fee))
            (rental-end (+ stacks-block-height rental-duration))
        )
        (asserts! (get available outfit) err-already-rented)
        (try! (stx-transfer? collateral-required tx-sender (as-contract tx-sender)))
        (try! (stx-transfer? rental-price tx-sender (as-contract tx-sender)))
        (try! (as-contract (stx-transfer? owner-payment tx-sender (get owner outfit))))
        (map-set outfits outfit-id (merge outfit { available: false }))
        (map-set rentals outfit-id {
            renter: tx-sender,
            rental-start: stacks-block-height,
            rental-end: rental-end,
            collateral-locked: collateral-required,
            returned: false
        })
        (ok rental-end)
    )
)

(define-public (return-outfit (outfit-id uint))
    (let
        (
            (outfit (unwrap! (map-get? outfits outfit-id) err-not-found))
            (rental (unwrap! (map-get? rentals outfit-id) err-not-found))
            (collateral (get collateral-locked rental))
        )
        (asserts! (is-eq (get renter rental) tx-sender) err-not-renter)
        (asserts! (not (get returned rental)) err-already-returned)
        (try! (as-contract (stx-transfer? collateral tx-sender tx-sender)))
        (map-set outfits outfit-id (merge outfit { available: true }))
        (map-set rentals outfit-id (merge rental { returned: true }))
        (ok true)
    )
)

(define-public (claim-collateral (outfit-id uint))
    (let
        (
            (outfit (unwrap! (map-get? outfits outfit-id) err-not-found))
            (rental (unwrap! (map-get? rentals outfit-id) err-not-found))
            (collateral (get collateral-locked rental))
        )
        (asserts! (is-eq (get owner outfit) tx-sender) err-owner-only)
        (asserts! (not (get returned rental)) err-already-returned)
        (asserts! (>= stacks-block-height (get rental-end rental)) err-rental-not-expired)
        (try! (as-contract (stx-transfer? collateral tx-sender tx-sender)))
        (map-set outfits outfit-id (merge outfit { available: true }))
        (map-set rentals outfit-id (merge rental { returned: true }))
        (ok collateral)
    )
)

(define-public (update-outfit-availability (outfit-id uint) (available bool))
    (let
        (
            (outfit (unwrap! (map-get? outfits outfit-id) err-not-found))
        )
        (asserts! (is-eq (get owner outfit) tx-sender) err-owner-only)
        (map-set outfits outfit-id (merge outfit { available: available }))
        (ok true)
    )
)

(define-public (update-protocol-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-fee u20) err-invalid-params)
        (var-set protocol-fee-percent new-fee)
        (ok new-fee)
    )
)

(define-read-only (get-outfit (outfit-id uint))
    (ok (map-get? outfits outfit-id))
)

(define-read-only (get-rental (outfit-id uint))
    (ok (map-get? rentals outfit-id))
)

(define-read-only (get-stake (user principal))
    (ok (map-get? stakes user))
)

(define-read-only (get-total-staked)
    (ok (var-get total-staked))
)

(define-read-only (get-user-outfits (user principal))
    (ok (map-get? user-outfits user))
)

(define-read-only (get-protocol-fee)
    (ok (var-get protocol-fee-percent))
)

(define-read-only (is-rental-expired (outfit-id uint))
    (match (map-get? rentals outfit-id)
        rental (ok (>= stacks-block-height (get rental-end rental)))
        (ok false)
    )
)

(define-read-only (get-rental-status (outfit-id uint))
    (match (map-get? rentals outfit-id)
        rental 
        (ok {
            is-active: (not (get returned rental)),
            is-expired: (>= stacks-block-height (get rental-end rental)),
            blocks-remaining: (if (>= stacks-block-height (get rental-end rental)) u0 (- (get rental-end rental) stacks-block-height))
        })
        err-not-found
    )
)
