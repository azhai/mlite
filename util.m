
;; generate rotations of a list:
;; rot [1,2,3]  -->  [[1,2,3], [2,3,1], [3,1,2]]

fun rot (_, 0) = []
      | (x :: xs, k) = (x :: xs) :: rot (xs @ [x], k - 1)
      | x = rot (x, len x)

;; distribute elements over lists:
;; dist (1, [[2], [3], [4]])  -->  [[1,2], [1,3], [1,4]]

fun dist (x, a :: as) = (x :: a) :: dist (x, as)
       | (x, []) = []

;; count members of lists:
;; count [1,[2],3]  -->  3

fun count [] = 0
        | x :: xs = count x + count xs
        | _ = 1

;; depth of lists:
;; depth [1,[2],3]  -->  2

fun depth x :: xs = 1 + (fold (max,0) ` map depth ` x :: xs)
        | _ = 0

;; split lists into fixed-length groups (except last group):
;; group ([1,2,3,4,5,6,7], 3)  -->  [[1,2,3], [4,5,6], [7]]

fun group (x, k) =
  let fun g ([], a, r, _)      = rev (rev a :: r)
          | (x, a, r, 0)       = g (x, [], rev a :: r, k)
          | (x :: xs, a, r, n) = g (xs, x :: a, r, n - 1)
  in g (x, [], [], k)
  end

;; flatten lists:
;; flatten [1,[2,[3]],4]  -->  [1,2,3,4]

fun flatten x = 
  let fun f ([], r) = r
          | (x :: xs, r) = f (x, f (xs, r))
          | (x, r) = x :: r
  in f (x, [])
  end

;; Scheme-like assoc:
;; assoc (2, [(1,"a"), (2,"b"), (3,"c")])  -->  (2,"b")

fun assoc (x, (k, v) :: as) where (x = k) = (k, v)
        | (x, _ :: as) = assoc (x, as)
        | (x, []) = false

;; map function over list tails:
;; maptail (fn x=x) [1,2,3,4]  -->  [[1,2,3,4], [2,3,4], [3,4], [4]]

fun maptail f =
  let fun m [] = []
          | x :: xs = f (x :: xs) :: m xs
  in fn a = m a
  end

;; partition lists:
;; part (fn x = x mod 2 = 0) [1,2,3,4,5]  -->  ([2,4], [1,3,5])

fun part f =
  let fun p ([], s1, s0)        = (rev s1, rev s0)
          | (f a :: as, s1, s0) = p (as, a :: s1, s0)
          | (a :: as, s1, s0)   = p (as, s1, a :: s0)
  in fn a = p (a, [], [])
  end

;; sort lists with Quicksort:
;; qsort op < [3,1,5,2,4]  -->  [1,2,3,4,5]

fun qsort f = 
  let fun q [] = []
          | [x] = [x]
          | x = let val n = len x;
                    val k = n div 2;
                    val m = ref (x, k);
                    val x = sub (x, 0, k) @ sub (x, k+1, n);
                    val p = part (fn x = f (x, m)) x
                in q #0p @ [m] @ q #1p
                end
  in fn a = q a
  end

;; split lists in the middle:
;; split [1,2,3,4,5]  -->  [[1,2,3], [4,5]]

fun split x = group (x, ceil ` len x / 2)

;; merge lists under a predicate:
;; merge (<, [1,3,5], [2,4,6])  -->  [1,2,3,4,5,6]

fun merge (f, a, b) =
  let fun m ([], [], r) = r
          | (a :: as, [], r) = m (as, [], a :: r)
          | ([], b :: bs, r) = m ([], bs, b :: r)
          | (a :: as, b :: bs, r) where f (a, b)
                             = m (a :: as, bs, b :: r)
          | (a :: as, b :: bs, r)
                             = m (as, b :: bs, a :: r)
  in m (rev a, rev b, [])
  end

;; sort lists with Mergesort:
;; mergesort op < [3,1,5,2,4]  -->  [1,2,3,4,5]

fun mergesort f =
  let fun s [] = []
          | [x] = [x]
          | a = let val [p1,p2] = split a
                in merge (f, s p1, s p2)
                end
  in fn a = s a
  end

;; generate k-combinations of lists
;; kcomb (2, [1,2,3])  -->  [[1,2], [1,3], [2,3]]

fun kcomb (0, _) = []
        | (1, a) = map (fn x = [x]) a
        | (k, a) = append_map (fn h :: t =
                                map (fn x = h :: x)
                                    ` kcomb (k - 1, t))
                              ` maptail (fn x = x) a

;; generate multicombinations of lists
;; mcomb (2, [1,2,3])  -->  [[1,1], [1,2], [1,3], [2,2], [2,3], [3,3]]

fun mcomb (0, _) = []
        | (1, a) = map (fn x = [x]) a
        | (k, a) = append_map (fn h :: t =
                                map (fn x = h :: x)
                                    ` mcomb (k - 1, h :: t))
                              ` maptail (fn x = x) a

;; generate permutations of lists
;; perm [1,2,3]  -->  [[1,2,3],[1,3,2],[2,3,1],[2,1,3],[3,1,2],[3,2,1]]

fun perm [x] = [[x]]
       | x = let val r = rot x
             in let val ts = map (perm o tail) r
                in append_map dist ` zip x ts
                end
             end

;; generate k-permutations of lists
;; kperm (2, [1,2,3])  -->  [[1,2], [2,1], [1,3], [3,1], [2,3], [3,2]]

fun kperm (k, a) = append_map perm ` kcomb (k, a)

;; member of
;; mem (2, [1,2,3])  -->  [2, 3]

fun mem (x, []) = false
      | (x, a :: as) where (x = a)
                = a :: as
      | (x, _ :: as)
                = mem (x, as)

;; intersection of a and b
;; isect ([1,2,3], [2,3,4])  -->  [2, 3]

fun isect (a, b) =
  let fun is ([], _, r) = rev r
           | (a :: as, b, r) where mem(a, b)
                        = is (as, b, a :: r)
           | (_ :: as, b, r)
                        = is (as, b, r)
           | (_, [], r) = rev r
  in is (a, b, [])
  end

;; union of a and b
;; union ([1,2,3], [2,3,4])  -->  [1, 2, 3, 4]

fun union (a, b) =
  let fun U ([], r) = rev r
           | (a :: as, r) where mem(a, r)
                    = U (as, r)
           | (a :: as, r)
                    = U (as, a :: r)
  in U (a @ b, [])
  end

;; binomial coefficient "n choose k"
;; (choose 49 6)  -->  13983816

fun choose (n, k) =
  let fun prod (x, y, r) where (x = y) = x*r
             | (x, y, r) = prod (x+1, y, x*r)
             | (x, y) = prod (x, y, 1)
  in prod (n-k+1, n) div prod (1, k)
  end

;; factorize integers
;; factor 36  -->  [(3,2), (2,2)]
;;                 = 3^2  * 2^2

local
  fun quotexpt (n, m, r) = if (n rem m = 0)
                           then quotexpt (n div m, m, r+1)
                           else (n, r)
             | (n, m) = quotexpt (n, m, 0)
  and addexpt (b, 0, r) = r
            | (b, e, r) = (b, e) :: r
in
  fun factor n =
        let val lim = ceil ` sqrt n;
            fun fact (n, d, r) =
                  let val re = quotexpt (n, d);
                      val q = #0re;
                      val e = #1re
                  in if q < 2 then addexpt (d, e, r)
                     else if d > lim then addexpt (n, 1, r)
                     else fact (q, if d = 2 then 3 else d+2,
                                addexpt (d, e, r))
                  end
        in fact (n, 2, [])
        end
end

;; check whether a predicate applies to each two subsequent elements of a list
;; andfold op < [1,2,3,4,5]  -->  true

fun andfold f =
  let fun fld a :: b :: xs where f (a, b) = fld (b :: xs)
            | [_] = true
            | [] = true
            | _ = false
  in fn a = fld a
  end

;; find partitions of a positive integer
;; numpart 4  -->  [[1, 1, 1, 1], [1, 1, 2], [1, 3], [2, 2], [4]]

local
  fun part 0 = [[]]
         | 1 = [[1]]
         | n = append_map (fn x = map (fn p = x :: p)
                                      ` numpart ` n - x)
                          ` iota n
in fun numpart n = filter (andfold op <=) ` part n
end

;; fold with intermediate results
;; scan (+,0) [1,2,3,4,5]  -->  [1, 3, 6, 10, 15]

fun scan (f, x) =
  let fun fold2 ([], a, r) = rev r
              | (x :: xs, a, r) = let val y = f (a, x)
                                  in fold2 (xs, y, y :: r)
                                  end
  in fn a = fold2 (a, x, [])
  end

;; fold right with intermediate results
;; scanr (::,[]) [1,2,3]  -->  [[3], [2, 3], [1, 2, 3]]

fun scanr (f, x) =
  let fun fold2 ([], a, r) = rev r
               | (x :: xs, a, r) = let val y = f (x, a)
                                       in fold2 (xs, y, y :: r)
                                       end
  in fn a = fold2 (rev a, x, [])
  end

fun null x = x = []

fun any p = let fun find [] = false
                       | (p a :: as) = true
                       | a :: as = find as
            in fn a = find a
            end

fun all p = let fun find [] = true
                       | (p a :: as) = find as
                       | _ = false
            in fn a = find a
            end

fun transp (any null x, new) = rev new
         | (x, new) =  transp (map tail x, (map head x) :: new)
         | x :: xs = transp (x :: xs, [])
         | [] = []
