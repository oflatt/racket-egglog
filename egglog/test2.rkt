#lang racket
(require racket/runtime-path)

(define-runtime-path egglog-binary 
    "rust-egglog/target/release/egglog")


(define-values (new-egglog-process new-egglog-output new-egglog-in new-egglog-err)
            (subprocess (current-output-port) #f #f egglog-binary))



(define (read-egglog-output port)
  (let loop ()
      (let ([line (read-line new-egglog-err)])
            (println line port)
            (when (not (equal? line "(done)"))
                  (loop))))
  (flush-output port))


(displayln `(set-option interactive_mode 1) new-egglog-in)
(flush-output new-egglog-in)
(read-egglog-output (current-output-port))

(displayln `(extract 2) new-egglog-in)
(flush-output new-egglog-in)
(read-egglog-output (current-output-port))

