(* This is a block comment *)

fun iota (0, a) = a
    | (x, a) = iota (x-1, x :: a)
    | x = iota (x, []);
println ` iota 123;