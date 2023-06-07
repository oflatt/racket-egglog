#lang racket
 
(module reader racket
  (require syntax/strip-context)
 
  (provide (rename-out [literal-read read]
                       [literal-read-syntax read-syntax]))
 
  (define (literal-read in)
    (syntax->datum
     (literal-read-syntax #f in)))
 
  (define (literal-read-syntax src in)
    (with-syntax ([str (port->string in)])
      (strip-context
       #'(module anything racket
           (provide data)
           (define data 'str))))))

#;
(define (read-syntax path port)
  (define src-lines (read-lines port))
  (define module-datum
    `(module egglog-module racket
       (require racket/runtime-path)
        (define-runtime-path egglog-binary
  "egglog/target/release/egg-smol")
     (define (instrument-egglog lines)
      (define-values (egglog-process egglog-output egglog-in err)
      (subprocess (current-output-port) #f (current-error-port) egglog-binary))

      (for ([line lines])
        (displayln line egglog-in))
      (close-output-port egglog-in)

      (subprocess-wait egglog-process))
             (instrument-egglog (quote ,src-lines))))
  (datum->syntax #f module-datum))
