(* Base-n conversion, originally by Bruce Axtens, 2014 *)

exception :radix_out_of_range and :unknown_digit;

fun to_radix (0, _, []) = "0"
           | (0, radix, result) = implode result
           | (n, radix > 36, result) = raise :radix_out_of_range
           | (n rem radix > 10, radix, result) =
               to_radix (n div radix, radix,
                         chr (n rem radix + ord #"a" - 10) :: result)
           | (n, radix, result) =
               to_radix (n div radix, radix,
                         chr (n rem radix + ord #"0") :: result)
           | (n, radix) = to_radix (n, radix, [])

fun from_radix (s, radix) =
      let val digits = explode "0123456789abcdefghijklmnopqrstuvwxyz";
          val len_digits = len digits;
          fun index (_, n >= radix, c) = raise :unknown_digit
                  | (h :: t, n, c = h) = n
                  | (_ :: t, n, c) = index (t, n + 1, c)
                  | c = index (digits, 0, c)
          and conv ([], radix, power, n) = n
                 | (h :: t, radix, power, n) =
                     conv (t, radix, power * radix, index h * power + n)
                 | (s, radix) = conv (rev ` explode s, radix, 1, 0)
          in
            conv (s, radix)
          end
