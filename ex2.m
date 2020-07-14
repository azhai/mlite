(* This is a block comment *)

fun iota (0, a) = a
    | (x, a) = iota (x-1, x :: a)
    | x = iota (x, []);
fun extract (f, []) = []
    | (f, f x :: xs) = x :: extract (f, xs)
    | (f, x :: xs) = extract (f, xs);
println ` extract(fn x = x mod 7 = 0, iota 123);