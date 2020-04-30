(*
 * mLite function library
 * by Nils M Holm, 2014
 * Placed in the public domain.
 *)

fun gcd (a, 0) = a
      | (0, b) = b
      | (a < b, b) = gcd (a, b rem a)
      | (a, b) = gcd (b, a rem b)

fun lcm (a, b) = let val d = gcd (a, b)
                 in a * b div d
                 end

fun ceil x = ~ (floor (~ x))

fun trunc x = (if x < 0 then ceil else floor) x

fun sgn x < 0 = ~1
      | x > 0 =  1
      | _     =  0

fun mod (a, b) = let val r = a rem b
                 in if r = 0 then 0
                    else if sgn a = sgn b then r
                    else b + r
                 end

infix mod = div;

local
  fun pow (x, 0) = 1
      | (x, y rem 2 = 0) = (fn x = x*x) (pow (x, y div 2))
      | (x, y) = x * (fn x = x*x) (pow (x, y div 2))
  and nth_root (n, x) =
        let fun nrt (r, last ~= r) = r
                  | (r, last) = nrt (r + (x / pow (r, n-1) - r) / n, r)
        in nrt (x, x/2+0.1)
        end
  and reduce (d, n) = let val g = gcd (floor d, n)
                      in if d/g > 100 then
                           (false, false)
                         else
                           (floor d div g, n div g)
                      end
  and rational (int d, n) = reduce (d, n)
             | (d, n) = rational (d*10, n*10)
             | (x = 1/3) = (1, 3)
             | (x = 1/6) = (1, 6)
             | (x = 1/7) = (1, 7)
             | (x = 1/9) = (1, 9)
             | x = rational (x, 1)
in
  fun ^ (x, y < 0) = 1 / pow (x, ~y)
      | (x, int y) = pow (x, floor y)
      | (x, y) = let val (n, d) = rational y
                 in if n then
                      pow (nth_root (d, x), n)
                    else
                      error ("no useful approximation for", (x, y))
                 end
  and nthroot (n, x) = nth_root (n, x)
end

infixr ^ > div

fun sqrt x = let fun sqrt2 (r, last = r) = r
                         | (r, last) = sqrt2 ((r + x / r) / 2, r)
             in if x < 0 then
                  error ("sqrt: argument is negative", x)
                else
                  sqrt2 (x, 0)
             end

fun o (f, g) = fn x = f (g x)

infixr o > ^

fun head h :: t = h

fun tail h :: t = t

local
  fun eqvec (a, b, 0) = true
            | (a, b, n) = eq (ref (a, n-1), ref (b, n-1))
                          also eqvec (a, b, n-1)
  and eq ([], []) = true
       | ((), ()) = true
       | (str a, b) = str b also a = b
       | (char a, b) = char b also a = b
       | (real a, b) = real b also a = b
       | (bool a, b) = bool b also a = b
       | (a :: as, b :: bs) = eq (a, b) also eq (as, bs)
       | (a, b) where order a > 1 =
                  order b > 1
                  also let val k = len a
                       in k = len b also eqvec (a, b, k)
                       end 
       | (vec a, b) = vec b
                      also let val k = len a
                           in k = len b also eqvec (a, b, k)
                           end
       | (a, b)   = false
in
  fun eql (a, b) = eq (a, b)
end

infix eql = =

fun iota (a, b) = let fun j (a = b, b, r) = a :: r
                          | (a, b, r) = j (a, b-1, b :: r)
                  in if a > b then
                       error ("iota: bad range", (a, b))
                     else
                       j (a, b, [])
                  end
       | a = iota (1, a)

fun map f = let fun map2 ([], r) = rev r
                       | (x :: xs, r) = map2 (xs, f x :: r)
            in fn a = map2 (a, [])
            end

fun append_map f = 
      let fun map2 [] = []
                 | (x :: xs) = f x @ map2 xs
      in fn a = map2 a
      end

fun foreach f = let fun iter [] = ()
                           | x :: xs = (f x; iter xs)
            in fn a = iter a
            end

fun fold (f, x) = let fun fold2 ([], r) = r
                              | (x :: xs, r) = fold2 (xs, f (r, x))
                  in fn a = fold2 (a, x)
                  end

fun foldr (f, x) = let fun fold2 ([], r) = r
                               | (x :: xs, r) = fold2 (xs, f (x, r))
                   in fn a = fold2 (rev a, x)
                   end

fun filter f = let fun filter2 ([], r) = rev r
                             | (f x :: xs, r) = filter2 (xs, x :: r)
                             | (x :: xs, r) = filter2 (xs, r)
               in fn a = filter2 (a, [])
               end

fun zipwith f = let fun zip (a, [], r) = rev r
                          | ([], b, r) = rev r
                          | (a :: as, b :: bs, r) =
                              zip (as, bs, f (a, b) :: r)
                in fn a b = zip (a, b, [])
                end

val zip = zipwith (fn x = x)

local
  fun fpstr (ds, v) = let val n = len ds
                          and f = conv (ds, 0)
                      in v + f * 10 ^ ~n
                      end
  and conv ([], v) = v
         | (#"." :: ds, v) = fpstr (ds, v)
         | (c_numeric d :: ds, v) = conv (ds, v * 10 + ord d - 48)
         | (d :: _, _) = false
in
  fun ston n = let val d :: ds = explode n
               in if d = #"-" or d = #"~" then
                    ~ ` conv (ds, 0)
                  else
                    conv (d :: ds, 0)
               end
end

local
  fun conv (0, []) = "0"
         | (0, s) = implode s
         | (n, s) = conv (n div 10, chr (n rem 10 + 48) :: s)
  and sconv (x < 0) = "-" @ conv (~x, [])
          | x = conv (x, [])
  and toint (x <> trunc x) = toint (x * 10)
          | x = trunc x
in
  fun ntos (int x) = sconv `floor x
         | x = let val f = conv (toint ` 1 + abs (x - trunc x), [])
                   and i = trunc x
               in sconv i @ "." @ sub (f, 1, len f)
               end
end
