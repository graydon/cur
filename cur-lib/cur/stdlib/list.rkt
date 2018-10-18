#lang s-exp "../main.rkt"
(require
 "nat.rkt"
 "maybe.rkt"
 "sugar.rkt")

(provide
 List
 elim-List
 nil cons (for-syntax ~nil ~cons)
 list-ref
 length
 build-list
 list-append)

(data List : 1 (Π (A : Type) Type)
  (nil : (Π (A : Type) (List A)))
  (cons : (Π (A : Type) (Π [x : A] (Π [xs : (List A)] (List A))))))

(define-syntax (build-list syn)
  (syntax-parse syn
    [(_ A)
     #'(nil A)]
    [(_ A e e^ ...)
     #'(cons A e (build-list A e^ ...))]))

(define/rec/match list-ref : [A : Type] [n : Nat] (List A) -> (Maybe A)
  [(nil B) => (none A)]
  [(cons B a rst) => (match n #:return (Maybe A)
                       [z (some A a)]
                       [(s n-1) (list-ref A n-1 rst)])])

(define/rec/match length : [A : Type] (List A) -> Nat
  [(nil _) => z]
  [(cons _ _ rst) => (s (length A rst))])

;; appends the second of two given lists onto the front of the first one
(define/rec/match list-append : (A : Type) [ls2 : (List A)] (List A) -> (List A)
  [(nil _) => ls2]
  [(cons _ a rst) => (cons A a (list-append A ls2 rst))])
