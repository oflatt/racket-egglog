#lang br/quicklang

(define (read-lines port)
  (define line (read port))
  (cond
    [(eof-object? line) empty]
    [else (cons line (read-lines port))]))


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

(provide read-syntax)


(define-macro (egglog-module-begin HANDLE-EXPR ...)
  #'(#%module-begin
     HANDLE-EXPR ...))

(provide (rename-out [egglog-module-begin #%module-begin]))
