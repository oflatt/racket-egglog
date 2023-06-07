#lang racket
 
(module reader racket
  (require syntax/strip-context)
 
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

 
  (define (literal-read-syntax src in)
    (with-syntax ([src-lines (read-lines in)])
      (strip-context
       #`(module anything racket
           (require racket/runtime-path)
        (define-runtime-path egglog-binary
  "rust-egglog/target/release/egg-smol")
     (define (run-egglog lines)
      (define-values (egglog-process egglog-output egglog-in err)
      (subprocess (current-output-port) #f (current-error-port) egglog-binary))

      (for ([line lines])
        (displayln line egglog-in))
      (close-output-port egglog-in)

      (subprocess-wait egglog-process))
             (run-egglog (quote src-lines))
           )))))
