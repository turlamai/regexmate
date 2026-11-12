#lang racket/base

;; Qualification driver for the published-upgrade workflow
;; (.github/workflows/appimage-upgrade-qualification.yml): drives the exact
;; `regexmate update` path the CLI ships, against the real feed. The update
;; model is user-initiated (CLI `regexmate update` / `--check`), so driving
;; these entry points IS the real user path; a CLI has no auto-check
;; throttle to bypass.
;;
;; upgrade (default) — with current-exe-path aimed at a staged distributed
;;   install (bin/regexmate + lib/ + gui/), run check-for-update against
;;   the live signed feed (releases/latest/download/update-manifest.json),
;;   download-candidate! (rivet's redirect-following fetch with SHA-256 +
;;   size verification against the signed manifest), extract-archive,
;;   staged-pieces and install-update! — the updater's own atomic swap with
;;   its .old semantics. Emits one JSON object with the offered version,
;;   the archive path and its SHA-256.
;;
;; bad-signature (TAMPER_BYTES_PATH set) — the workflow hands us the real
;;   published feed bytes with one payload byte flipped (PRISTINE_BYTES_PATH
;;   carries the untampered bytes as the positive control). Verification is
;;   the first gate fetch-update-manifest applies, before selection or
;;   download; the pristine bytes must verify, the tampered bytes must be
;;   refused, and the install tree must stay untouched — a refused manifest
;;   can never reach disk as an artifact.
;;
;; Inputs (environment):
;;   INSTALL_DIR         staged distributed install root (bin/ + lib/ + gui/)
;;   EXPECTED_VERSION    N+1 version string (upgrade mode)
;;   PRISTINE_BYTES_PATH real feed bytes (bad-signature mode, positive control)
;;   TAMPER_BYTES_PATH   tampered feed bytes (bad-signature mode)
;;   OUTPUT_JSON         where to write the result object
;;
;; Prints or writes one JSON object and exits non-zero on any mismatch.

(require crypto
         json
         racket/file
         racket/format
         racket/string
         ;; only-in: keep the driver independent of which names the
         ;; installed rivet pin happens to export alongside the local trio
         (only-in rivet/distribution
                  base64-string->bytes
                  sha256-file/hex
                  update-artifact-installer
                  update-artifact-size
                  update-manifest-version
                  verify-signed-manifest)
         "../../racket/core/updater.rkt"
         "../../racket/version.rkt")

(define (need name)
  (or (getenv name)
      (error 'upgrade-qualification "~a is not set" name)))

(define (fail fmt . args)
  (apply error 'upgrade-qualification fmt args))

(define install-root-path (simplify-path (need "INSTALL_DIR")))
(define output-json (getenv "OUTPUT_JSON"))
(define pristine-path (getenv "PRISTINE_BYTES_PATH"))
(define tamper-path (getenv "TAMPER_BYTES_PATH"))

;; aim the updater's install-layout seam at the staged tree
(define (staged-exe-path)
  (build-path install-root-path "bin" "regexmate"))

;; nothing the update path produces may exist before a download: no
;; regexmate-update-* staging under the install root, no updates/ payload
;; directory
(define (foreign-artifacts)
  (define offenders '())
  (for ([entry (in-list (directory-list install-root-path #:build? #f))])
    (define n (path->string entry))
    (when (or (string-prefix? n "regexmate-update-")
              (string=? n "updates"))
      (set! offenders (cons n offenders))))
  offenders)

(define result
  (parameterize ([current-exe-path (staged-exe-path)])
    (cond
      ;; ---------- bad-signature mode ----------
      [tamper-path
       ;; positive control: the pristine published bytes must verify, so the
       ;; refusal below is attributable to the flipped byte alone
       (define pristine-ok
         (with-handlers ([exn:fail? (lambda (_) #f)])
           (verify-signed-manifest (open-input-bytes (file->bytes pristine-path))
                                   (embedded-public-key)
                                   #:key-id regexmate-update-key-id)
           #t))
       (unless pristine-ok
         (fail "the pristine live feed bytes did not verify — the environment, not the tamper, is broken"))
       (define tampered-accepted?
         (with-handlers ([exn:fail? (lambda (_) #f)])
           (verify-signed-manifest (open-input-bytes (file->bytes tamper-path))
                                   (embedded-public-key)
                                   #:key-id regexmate-update-key-id)
           #t))
       (when tampered-accepted?
         (fail "one-byte-tampered live feed bytes were ACCEPTED — signature enforcement is broken"))
       (define left (foreign-artifacts))
       (unless (null? left)
         (fail "a refused manifest must not reach download; install tree holds: ~a" left))
       (hasheq 'mode "bad-signature"
               'pristineVerified #t
               'tamperedRefused #t
               'foreignArtifacts '())]
      ;; ---------- upgrade mode ----------
      [else
       (define expected-version (need "EXPECTED_VERSION"))
       (define plan (check-for-update))
       (unless plan
         (fail "feed did not offer an update (selection said up to date)"))
       (define offered
         (update-manifest-version (update-plan-manifest plan)))
       (unless (equal? offered expected-version)
         (fail "expected version ~a, feed offered ~a" expected-version offered))
       (define updates-dir (build-path install-root-path "updates"))
       (make-directory* updates-dir)
       (define archive
         (build-path updates-dir
                     (string-append "regexmate-" expected-version "-archive.tar.gz")))
       (download-candidate! plan archive)
       (define extract-dir
         (build-path install-root-path
                     (string-append "regexmate-update-qualification-" expected-version)))
       (extract-archive archive extract-dir)
       (define-values (new-exe new-lib new-gui) (staged-pieces extract-dir))
       (define outcome (install-update! new-exe new-lib new-gui))
       (unless (eq? outcome 'installed)
         (fail "install-update! returned ~a" outcome))
       ;; the swap must have replaced the running exe's path
       (unless (file-exists? (staged-exe-path))
         (fail "no regexmate executable at ~a after the swap" (staged-exe-path)))
       (hasheq 'mode "upgrade"
               'status "installed"
               'availableVersion offered
               'installer (symbol->string (update-artifact-installer
                                           (update-plan-artifact plan)))
               'sizeBytes (update-artifact-size (update-plan-artifact plan))
               'feedUrl (manifest-url)
               'archivePath (path->string archive)
               'archiveSha256 (sha256-file/hex archive))])))

(if output-json
    (call-with-output-file output-json
      (lambda (out) (write-json result out) (newline out))
      #:exists 'truncate)
    (begin (write-json result) (newline)))
