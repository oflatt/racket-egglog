#lang racket
 
(provide (rename-out [top-interaction #%top-interaction]) #%top #%app #%datum egglog-process egglog-in)
(require br/macro)
(require racket/runtime-path)

(define-runtime-path egglog-binary 
    "rust-egglog/target/release/egglog")



(define egglog-process (box #f))
(define egglog-in (box #f))
(define egglog-out (box #f))

(define (read-egglog-output port)
  (let loop ()
      (let ([line (read-line (unbox egglog-out))])
            (when (not (equal? line "(done)"))
                  (displayln line port)
                  (loop))))
  (flush-output port))

(define-runtime-path svg-path
  "temp.svg")

(define-macro (top-interaction . CODE)
  #'(#%top-interaction .
       (begin
          (when (not (unbox egglog-process))
            (define-values (new-egglog-process new-egglog-output new-egglog-in new-egglog-err)
            (subprocess #f #f #f egglog-binary))
            (set-box! egglog-process new-egglog-process)
            (set-box! egglog-in new-egglog-in)
            (set-box! egglog-out new-egglog-err)
            
            (writeln `(set-option interactive_mode 1) (unbox egglog-in))
            (flush-output (unbox egglog-in))
            (read-egglog-output (open-output-nowhere))
          )
          (writeln (quote CODE) (unbox egglog-in))
          (flush-output (unbox egglog-in))
          (read-egglog-output (current-output-port))
       )))

(module reader racket
  (require syntax/strip-context)
  (require racket/runtime-path)
 
  (provide (rename-out [literal-read read]
                       [literal-read-syntax read-syntax]))
 
  (define (literal-read in)
    (syntax->datum
     (literal-read-syntax #f in)))
  

  (define (read-lines port)
    (cond
      [(eof-object? (peek-char port))
      '()]
      [else
        (cons (read port)
              (read-lines port))]))

  (define-runtime-path egglog-binary 
    "rust-egglog/target/release/egg-smol")

 
  (define (literal-read-syntax src in)
    (with-syntax ([src-lines (read-lines in)]
                  [egglog-binary egglog-binary])
      (strip-context
       #`(module egglog racket
     (define (run-egglog lines)
      (define-values (egglog-process egglog-output egglog-in err)
      (subprocess (current-output-port) #f (current-error-port) egglog-binary))

      (for ([line lines])
        (displayln line egglog-in))
      (close-output-port egglog-in)

      (subprocess-wait egglog-process))
             (run-egglog (quote src-lines))
           )))))
