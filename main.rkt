#lang br/quicklang

(define (read-lines port)
  (define line (read port))
  (cond
    [(eof-object? line) empty]
    [else (cons line (read-lines port))]))

(define (read-syntax path port)
  (define src-lines (read-lines port))
  (define module-datum `(module egglog-mod "main.rkt"
                          ,@src-lines))
  (datum->syntax #f module-datum))
(provide read-syntax)


(define-macro (egglog-module-begin HANDLE-EXPR ...)
  #'(#%module-begin
     HANDLE-EXPR ...))
(provide (rename-out [egglog-module-begin #%module-begin]))
