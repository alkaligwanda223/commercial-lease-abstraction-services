(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))

(define-map lease-documents
  { lease-id: uint }
  {
    tenant-id: principal,
    property-address: (string-ascii 200),
    lease-start: uint,
    lease-end: uint,
    annual-rent: uint,
    document-hash: (string-ascii 100)
  }
)

(define-map critical-terms
  { lease-id: uint, term-id: uint }
  {
    term-name: (string-ascii 100),
    term-value: (string-ascii 300),
    renewal-option: bool,
    escalation-percent: uint,
    extracted-date: uint
  }
)

(define-map database-records
  { record-id: uint }
  {
    lease-id: uint,
    field-name: (string-ascii 100),
    field-value: (string-ascii 300),
    data-quality: uint,
    populated-date: uint
  }
)

(define-map abstraction-reports
  { report-id: uint }
  {
    lease-id: uint,
    total-pages: uint,
    critical-terms-found: uint,
    completeness-percent: uint,
    generated-date: uint
  }
)

(define-data-var next-lease-id uint u1)
(define-data-var next-term-id uint u1)
(define-data-var next-record-id uint u1)
(define-data-var next-report-id uint u1)

(define-public (register-lease-document (tenant principal) (property (string-ascii 200)) (start uint) (end uint) (rent uint) (hash (string-ascii 100)))
  (let ((lease-id (var-get next-lease-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set lease-documents
        { lease-id: lease-id }
        {
          tenant-id: tenant,
          property-address: property,
          lease-start: start,
          lease-end: end,
          annual-rent: rent,
          document-hash: hash
        }
      )
      (var-set next-lease-id (+ lease-id u1))
      (ok lease-id)
    )
  )
)

(define-public (extract-critical-term (lease-id uint) (term-name (string-ascii 100)) (term-value (string-ascii 300)) (renewal bool) (escalation uint))
  (let ((term-id (var-get next-term-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set critical-terms
        { lease-id: lease-id, term-id: term-id }
        {
          term-name: term-name,
          term-value: term-value,
          renewal-option: renewal,
          escalation-percent: escalation,
          extracted-date: u0
        }
      )
      (var-set next-term-id (+ term-id u1))
      (ok term-id)
    )
  )
)

(define-public (populate-database-record (lease-id uint) (field (string-ascii 100)) (value (string-ascii 300)) (quality uint))
  (let ((record-id (var-get next-record-id)))
    (begin
      (map-set database-records
        { record-id: record-id }
        {
          lease-id: lease-id,
          field-name: field,
          field-value: value,
          data-quality: quality,
          populated-date: u0
        }
      )
      (var-set next-record-id (+ record-id u1))
      (ok record-id)
    )
  )
)

(define-public (generate-abstraction-report (lease-id uint) (pages uint) (terms-found uint) (completeness uint))
  (let ((report-id (var-get next-report-id)))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
      (map-set abstraction-reports
        { report-id: report-id }
        {
          lease-id: lease-id,
          total-pages: pages,
          critical-terms-found: terms-found,
          completeness-percent: completeness,
          generated-date: u0
        }
      )
      (var-set next-report-id (+ report-id u1))
      (ok report-id)
    )
  )
)

(define-read-only (get-lease (lease-id uint))
  (map-get? lease-documents { lease-id: lease-id })
)

(define-read-only (get-critical-term (lease-id uint) (term-id uint))
  (map-get? critical-terms { lease-id: lease-id, term-id: term-id })
)

(define-read-only (get-report (report-id uint))
  (map-get? abstraction-reports { report-id: report-id })
)
