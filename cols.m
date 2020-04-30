(*
 * Convert input stream to two-column format.
 * Nils M Holm, 2014
 * In the public domain
 *
 * This is just a quick hack to format the
 * TOC of the manual.
 *)

fun readfile () = readfile []
           | x = let val ln = readln ()
                 in if eof ln then
                      rev x
                    else
                      readfile ` ln :: x
                 end

fun group (x, k) =
  let fun g ([], a, r, _)      = rev (rev a :: r)
          | (x, a, r, 0)       = g (x, [], rev a :: r, k)
          | (x :: xs, a, r, n) = g (xs, x :: a, r, n - 1)
  in g (x, [], [], k)
  end

fun split x = group (x, ceil ` len x / 2)

fun cols () = let val [c1, c2] = split ` readfile ();
                  val c2 = if len c2 < len c1 then
                             c2 @ [""]
                           else
                             c2
              in zipwith (fn (s1,s2) = (print s1;
                                        print ` chr 9;
                                        println s2))
                         c1 c2
              end

;
cols ()
