#lang cur
(require
 cur/stdlib/prop
 cur/stdlib/sugar
 cur/stdlib/bool
 cur/stdlib/nat
 cur/stdlib/equality
 "curunit.rkt")

(check-equal?
 (elim ML-= (λ (x : Bool) (y : Bool) (p : (ML-= Bool x y)) Nat)
       ((λ (x : Bool) z))
       (ML-refl Bool true))
 z)

(define (id (A : Type) (x : A)) x)

(check-equal?
 ((id (ML-= True T T))
  (ML-refl True (run (id True T))))
 (ML-refl True T))

(check-equal?
 ((id (ML-= True T T))
  (ML-refl True (id True T)))
 (ML-refl True T))

;; prove some properties of equality
;; - with both built-in and user-defined datatypes

;; ML-= symmetric
(check-type
 (λ [A : (Type 0)]
   (λ [x : A]
     (λ [y : A]
       (λ [e : (ML-= A x y)]
         (new-elim e
                   (λ (a : A) (λ (b : A) (λ (e : (ML-= A a b)) (ML-= A b a))))
                   (λ (c : A) (ML-refl A c)))))))
 : (Π (A : (Type 0))
      (Π (x : A)
         (Π (y : A)
            (-> (ML-= A x y)
                (ML-= A y x))))))

;; ML-= transitive (partial)
(check-type
 (λ [A : (Type 0)]
   (λ [x : A] [y : A] [z : A]
      (λ [e1 : (ML-= A x y)] [e2 : (ML-= A y z)]
         (new-elim
          e1
          (λ [a : A] [b : A]
             (λ [e : (ML-= A a b)]
               (Π [c : A] (→ (ML-= A b c) (ML-= A a c)))))
          (λ [a : A]
            (λ [c : A]
              (λ [e : (ML-= A a c)] e)))))))
 : (Π (A : (Type 0))
      (Π [x : A] [y : A] [z : A]
         (→ (ML-= A x y)
            (ML-= A y z)
            (Π [a : A]
               (→ (ML-= A y a) (ML-= A x a)))))))

;; ML-= transitive
(check-type
 (λ [A : (Type 0)]
   (λ [x : A] [y : A] [z : A]
      (λ [e1 : (ML-= A x y)] [e2 : (ML-= A y z)]
         ((new-elim
           e1
           (λ [a : A] [b : A]
              (λ [e : (ML-= A a b)]
                (Π [c : A] (→ (ML-= A b c) (ML-= A a c)))))
           (λ [a : A]
             (λ [c : A]
               (λ [e : (ML-= A a c)] e))))
          z e2))))
 : (Π (A : (Type 0))
      (Π [x : A] [y : A] [z : A]
         (→ (ML-= A x y)
            (ML-= A y z)
            (ML-= A x z)))))

;; plus 0 (left)
(check-type (λ [x : Nat] (ML-refl Nat x)) : (Π [x : Nat] (ML-= Nat (plus 0 x) x)))

;; plus 0 (right)
(check-type
 (λ [x : Nat]
   (new-elim
    x
    (λ [n : Nat] (ML-= Nat (plus n 0) n))
    (ML-refl Nat 0)
    (λ [x-1 : Nat]
      (λ [ih : (ML-= Nat (plus x-1 0) x-1)]
        (new-elim
         ih
         ;; a=b => a+1=b+1
         (λ [a : Nat] [b : Nat]
            (λ [e : (ML-= Nat a b)]
              (ML-= Nat (s a) (s b))))
         (λ [c : Nat]
           (ML-refl Nat (s c))))))))
 : (Π [x : Nat] (ML-= Nat (plus x 0) x)))

;; new my= equality

(data my= : 1 (Π (A : (Type 0)) (Π (a : A) (Π (b : A) (Type 0))))
      (my-refl : (Π (A : (Type 0)) (Π (a : A) (my= A a a)))))

(check-type (my-refl Nat 1) : (my= Nat 1 1))
(check-type (my-refl Nat 1) : (my= Nat 1 (plus 1 0)))
(check-type (my-refl Nat 1) : (my= Nat (plus 1 0) (plus 1 0)))
(check-type (my-refl Nat 2) : (my= Nat (plus 1 1) (plus 1 (plus 1 0))))

;; my= symmetric
(check-type
 (λ [A : (Type 0)]
   (λ [x : A] [y : A]
       (λ [e : (my= A x y)]
         (new-elim 
          e
          (λ [a : A] [b : A]
             (λ [e : (my= A a b)]
               (my= A b a)))
          (λ [c : A]
            (my-refl A c))))))
 : (Π [A : (Type 0)]
      (Π [x : A] [y : A]
         (→ (my= A x y) (my= A y x)))))

;; = transitive
(check-type
 (λ [A : (Type 0)]
   (λ [x : A] [y : A] [z : A]
      (λ [e1 : (my= A x y)] [e2 : (my= A y z)]
         ((new-elim
           e1
           (λ [a : A] [b : A]
              (λ [e : (my= A a b)]
                (Π [c : A] (→ (my= A b c) (my= A a c)))))
           (λ [a : A]
             (λ [c : A]
               (λ [e : (my= A a c)] e))))
          z e2))))
 : (Π (A : (Type 0))
      (Π [x : A] [y : A] [z : A]
         (→ (my= A x y)
            (my= A y z)
            (my= A x z)))))