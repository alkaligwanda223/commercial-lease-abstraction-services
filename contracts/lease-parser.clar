(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))

(define-map records { record-id: uint } { data: (string-ascii 300), timestamp: uint })
(define-data-var next-id uint u1)

(define-public (record-data (content (string-ascii 300)))
  (let ((id (var-get next-id)))
    (begin
      (map-set records { record-id: id } { data: content, timestamp: u0 })
      (var-set next-id (+ id u1))
      (ok id)
    )
  )
)

(define-read-only (get-record (record-id uint))
  (map-get? records { record-id: record-id })
)
