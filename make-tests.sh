awk '
BEGIN	{ FS="\t" }
/^$/	{ next }
/^D/	{ print substr($0, 3, length($0)); next }
	{ s = $3
	  gsub("\\\\", "\\\\", s)
	  gsub("\\\"", "\\\"", s)
	  if ($1 == $2)
		printf "test3 (\"%s\", %s, %s);\n", s, $3, $1
	  else
		printf "test4 (\"%s\", %s, %s, %s);\n", s, $3, $1, $2
	}
' <<EOT
D ;; this is an in-line comment
D (* This is a block comment *)
D (*
D  * Another block comment
D  *)
D 
D (*(*(*Nested block comment*)(**)*)*)
D 
D val Errors = newvec (1, 0) and Tests = newvec (1, 0)
D 
D fun test3 (s, v, x) = (set (Tests, 0, ref (Tests, 0) + 1);
D                        if not \` v eql x then
D                          (print \` "FAILED: " @ s @ ", got ";
D                           println v;
D                           set (Errors, 0, ref (Errors, 0) + 1))
D                        else
D                          ());
D 
D fun test4 (s, v, l, h) = (set (Tests, 0, ref (Tests, 0) + 1);
D                           if v < l or v > h then
D                             (print \` "FAILED: " @ s @ ", got ";
D                              println v;
D                              set (Errors, 0, ref (Errors, 0) + 1))
D                           else
D                             ());
D 

D
D (* Literals *)
D

true	true	true
false	false	false

#"a"	#"a"	#"a"
#"#"	#"#"	#"#"
#"\""	#"\""	#"\""
chr 92	chr 92	#"backslash"
chr 10	chr 10	#"newline"
chr 34	chr 34	#"quote"
chr 32	chr 32	#"space"
chr 9	chr 9	#"tab"

""	""	""
"test"	"test"	"test"
"Test"	"Test"	"Test"
"\"hi\""	"\"hi\""	"\"hi\""

[]	[]	[]
[1]	[1]	[1]
[1,2,3]	[1,2,3]	[1,2,3]
[[[1]]]	[[[1]]]	[[[1]]]
[1,2]	[1,2]	1 :: [2]
[1,2,3]	[1,2,3]	1 :: 2 :: [3]

0	0	0
123	123	123
~(1)	~(1)	~1
~(456)	~(456)	~456

0.0	0.0	0.0
1.0	1.0	1.0
0.123	0.123	0.123
123.45	123.45	123.45
~(1.23)	~(1.23)	~1.23
100000	100000	1e5
123000	123000	12.3e4
0.0123	0.0123	1.23e~2
~(0.34)	~(0.34)	~34e~2

()	()	()
1	1	(1)
1	1	((1))
1	1	(((1)))
#"x"	#"x"	(#"x")
"x"	"x"	("x")
true	true	(true)
[]	[]	([])
[1]	[1]	([1])
(1,2)	(1,2)	(1,2)
(1,2,3)	(1,2,3)	(1,2,3)
1	1	#0(1,2)
2	2	#1(1,2)
(1,2)	(1,2)	(1,(2))
(1,2)	(1,2)	((1),2)
((1,2),3)	((1,2),3)	((1,2),3)
(1,(2,3))	(1,(2,3))	(1,(2,3))

D
D (* Arithmetics *)
D

6912	6912	1234+5678
4444	4444	~1234+5678
~4444	~4444	1234 + ~5678
~6912	~6912	~1234 + ~5678
1234	1234	1234+0
1234	1234	0+1234

~4444	~4444	1234-5678
~6912	~6912	~1234-5678
6912	6912	1234 - ~5678
4444	4444	~1234 - ~5678
1234	1234	1234-0
~1234	~1234	0-1234

56088	56088	123*456
~56088	~56088	~123*456
~56088	~56088	123 * ~456
56088	56088	~123 * ~456
123	123	123 * 1
123	123	1 * 123

3.70	3.71	456/123
~3.71	~3.70	~456/123
~3.71	~3.70	456 / ~123
3.70	3.71	~456 / ~123
123	123	123 / 1
0.008	0.009	1 / 123

3	3	456 div 123
~3	~3	~456 div 123
~3	~3	456 div ~123
3	3	~456 div ~123
123	123	123 div 1
1	1	123 div 123
0	0	123 div 124

87	87	456 rem 123
~87	~87	~456 rem 123
87	87	456 rem ~123
~87	~87	~456 rem ~123
0	0	123 rem 1
0	0	123 rem 123
123	123	123 rem 124

87	87	456 mod 123
36	36	~456 mod 123
~36	~36	456 mod ~123
~87	~87	~456 mod ~123
0	0	123 mod 1
0	0	123 mod 123
123	123	123 mod 124

1	1	123^0
123	123	123^1
15129	15129	123^2
0.008	0.009	123 ^ ~1
6.6e~5	6.7e~5	123 ^ ~2
11.09	11.1	123 ^ (1/2)
4.973	4.974	123 ^ (1/3)
2.0	2.0	256 ^ (1/8)

~1	~1	(~ o abs) 1
~1	~1	(~ o abs) ~1
1	1	(abs o ~) 1
1	1	(abs o ~) ~1

true	true	0 = 0
true	true	1 = 1
true	true	123 = 123
true	true	~123 = ~123
true	true	0.0 = 0.0
false	false	0 = 1
false	false	1 = 0
false	false	123 = 123.5
false	false	123.5 = 123
false	false	123 = ~123
false	false	~123 = 123

true	true	0 <> 1
true	true	1 <> 0
true	true	123 <> 123.5
true	true	123.5 <> 123
true	true	123 <> ~123
true	true	~123 <> 123
false	false	0 <> 0
false	false	1 <> 1
false	false	123 <> 123
false	false	~123 <> ~123
false	false	0.0 <> 0.0

true	true	~1 < 0
true	true	0 < 1
true	true	1 < 2
true	true	123 < 123.5
true	true	122.5 < 123
true	true	~123 < 123
true	true	~123.5 < 123.5
false	false	0 < 0
false	false	123 < 123
false	false	~123 < ~123
false	false	123.5 < 123.5
false	false	1 < 0
false	false	124 < 123
false	false	123.5 < 123

true	true	0 > ~1
true	true	1 > 0
true	true	2 > 1
true	true	123.5 > 123
true	true	123 > 122.5
true	true	123 > ~123
true	true	123.5 > ~123.5
false	false	0 > 0
false	false	123 > 123
false	false	~123 > ~123
false	false	123.5 > 123.5
false	false	0 > 1
false	false	123 > 124
false	false	123 > 123.5

true	true	~1 <= 0
true	true	0 <= 1
true	true	1 <= 2
true	true	123 <= 123.5
true	true	122.5 <= 123
true	true	~123 <= 123
true	true	~123.5 <= 123.5
true	true	0 <= 0
true	true	123 <= 123
true	true	123.5 <= 123.5
true	true	~123 <= ~123
false	false	1 <= 0
false	false	124 <= 123
false	false	123.5 <= 123

true	true	0 >= ~1
true	true	1 >= 0
true	true	2 >= 1
true	true	123.5 >= 123
true	true	123 >= 122.5
true	true	123 >= ~123
true	true	123.5 >= ~123.5
true	true	0 >= 0
true	true	123 >= 123
true	true	~123 >= ~123
true	true	123.5 >= 123.5
false	false	0 >= 1
false	false	123 >= 124
false	false	123 >= 123.5

D
D (* Char/String comparison *)
D

true	true	#"x" = #"x"
false	false	#"x" = #"y"
false	false	#"X" = #"x"
true	true	#"x" ~= #"x"
true	true	#"X" ~= #"x"
false	false	#"x" ~= #"y"

false	false	#"x" <> #"x"
true	true	#"x" <> #"y"
true	true	#"X" <> #"x"
false	false	#"x" ~<> #"x"
false	false	#"X" ~<> #"x"
true	true	#"x" ~<> #"y"

true	true	#"x" < #"y"
false	false	#"y" < #"x"
false	false	#"x" < #"Y"
false	false	#"x" < #"x"
true	true	#"x" ~< #"y"
true	true	#"x" ~< #"Y"
false	false	#"y" ~< #"x"
false	false	#"x" ~< #"X"

true	true	#"y" > #"x"
false	false	#"x" > #"y"
false	false	#"Y" > #"x"
false	false	#"x" > #"x"
true	true	#"y" ~> #"x"
true	true	#"Y" ~> #"x"
false	false	#"x" ~> #"y"
false	false	#"X" ~> #"x"

true	true	#"x" <= #"y"
false	false	#"y" <= #"x"
false	false	#"x" <= #"Y"
true	true	#"x" <= #"x"
true	true	#"x" ~<= #"y"
true	true	#"x" ~<= #"Y"
false	false	#"y" ~<= #"x"
true	true	#"x" ~<= #"X"

true	true	#"y" >= #"x"
false	false	#"x" >= #"y"
false	false	#"Y" >= #"x"
true	true	#"x" >= #"x"
true	true	#"y" ~>= #"x"
true	true	#"Y" ~>= #"x"
false	false	#"x" ~>= #"y"
true	true	#"X" ~>= #"x"

false	false	"test" < "test"
false	false	"test" < "tesa"
true	true	"test" < "tesz"
true	true	"TEST" < "tesa"
true	true	"TEST" < "tesz"
false	false	"test" < "TESA"
false	false	"test" < "TESZ"
false	false	"TEST" < "TESA"
true	true	"TEST" < "TESZ"
true	true	"tes" < "test"
false	false	"test" < "tes"
true	true	"test" < "test0"
false	false	"test0" < "test"

true	true	"test" <= "test"
false	false	"test" <= "tesa"
true	true	"test" <= "tesz"
true	true	"TEST" <= "tesa"
true	true	"TEST" <= "tesz"
false	false	"test" <= "TESA"
false	false	"test" <= "TESZ"
false	false	"TEST" <= "TESA"
true	true	"TEST" <= "TESZ"
false	false	"test" <= "tes"
true	true	"test" <= "test0"
false	false	"test0" <= "test"

false	false	"test" ~< "test"
false	false	"test" ~< "tesa"
true	true	"test" ~< "tesz"
false	false	"TEST" ~< "tesa"
true	true	"TEST" ~< "tesz"
false	false	"test" ~< "TESA"
true	true	"test" ~< "TESZ"
false	false	"TEST" ~< "TESA"
true	true	"TEST" ~< "TESZ"
false	false	"test" ~< "tes"
true	true	"tes" ~< "test"
true	true	"test" ~< "test0"
false	false	"test0" ~< "test"

true	true	"test" ~<= "test"
false	false	"test" ~<= "tesa"
true	true	"test" ~<= "tesz"
false	false	"TEST" ~<= "tesa"
true	true	"TEST" ~<= "tesz"
false	false	"test" ~<= "TESA"
true	true	"test" ~<= "TESZ"
false	false	"TEST" ~<= "TESA"
true	true	"TEST" ~<= "TESZ"
true	true	"tes" ~<= "test"
false	false	"test" ~<= "tes"
true	true	"test" ~<= "test0"
false	false	"test0" ~<= "test"

false	false	"test" > "test"
true	true	"test" > "tesa"
false	false	"test" > "tesz"
false	false	"TEST" > "tesa"
false	false	"TEST" > "tesz"
true	true	"test" > "TESA"
true	true	"test" > "TESZ"
true	true	"TEST" > "TESA"
false	false	"TEST" > "TESZ"
false	false	"tes" > "test"
true	true	"test" > "tes"
false	false	"test" > "test0"
true	true	"test0" > "test"

true	true	"test" >= "test"
true	true	"test" >= "tesa"
false	false	"test" >= "tesz"
false	false	"TEST" >= "tesa"
false	false	"TEST" >= "tesz"
true	true	"test" >= "TESA"
true	true	"test" >= "TESZ"
true	true	"TEST" >= "TESA"
false	false	"TEST" >= "TESZ"
false	false	"tes" >= "test"
true	true	"test" >= "tes"
false	false	"test" >= "test0"
true	true	"test0" >= "test"

false	false	"test" ~> "test"
true	true	"test" ~> "tesa"
false	false	"test" ~> "tesz"
true	true	"TEST" ~> "tesa"
false	false	"TEST" ~> "tesz"
true	true	"test" ~> "TESA"
false	false	"test" ~> "TESZ"
true	true	"TEST" ~> "TESA"
false	false	"TEST" ~> "TESZ"
false	false	"tes" ~> "test"
true	true	"test" ~> "tes"
false	false	"test" ~> "test0"
true	true	"test0" ~> "test"

true	true	"test" ~>= "test"
true	true	"test" ~>= "tesa"
false	false	"test" ~>= "tesz"
true	true	"TEST" ~>= "tesa"
false	false	"TEST" ~>= "tesz"
true	true	"test" ~>= "TESA"
false	false	"test" ~>= "TESZ"
true	true	"TEST" ~>= "TESA"
false	false	"TEST" ~>= "TESZ"
false	false	"tes" ~>= "test"
true	true	"test" ~>= "tes"
false	false	"test" ~>= "test0"
true	true	"test0" ~>= "test"

true	true	"abc" = "abc"
false	false	"aBc" = "abc"
false	false	"abc" = "abd"
false	false	"abc" = "abcd"
false	false	"abcd" = "abc"

true	true	"abc" ~= "abc"
true	true	"abC" ~= "abc"
true	true	"aBc" ~= "abc"
true	true	"aBC" ~= "abc"
true	true	"Abc" ~= "abc"
true	true	"AbC" ~= "abc"
true	true	"ABc" ~= "abc"
true	true	"ABC" ~= "abc"
true	true	"aBc" ~= "AbC"
false	false	"abc" ~= "abd"
false	false	"abc" ~= "abcd"
false	false	"abcd" ~= "abc"

true	true	"abc" = "abc"
false	false	"aBc" = "abc"
false	false	"abc" = "abd"
false	false	"abc" = "abcd"
false	false	"abcd" = "abc"

false	false	"abc" <> "abc"
true	true	"aBc" <> "abc"
true	true	"abc" <> "abd"
true	true	"abc" <> "abcd"
true	true	"abcd" <> "abc"

true	true	"abc" ~= "abc"
true	true	"abC" ~= "abc"
true	true	"aBc" ~= "abc"
true	true	"aBC" ~= "abc"
true	true	"Abc" ~= "abc"
true	true	"AbC" ~= "abc"
true	true	"ABc" ~= "abc"
true	true	"ABC" ~= "abc"
true	true	"aBc" ~= "AbC"
false	false	"abc" ~= "abd"
false	false	"abc" ~= "abcd"
false	false	"abcd" ~= "abc"

false	false	"abc" ~<> "abc"
false	false	"abC" ~<> "abc"
false	false	"aBc" ~<> "abc"
false	false	"aBC" ~<> "abc"
false	false	"Abc" ~<> "abc"
false	false	"AbC" ~<> "abc"
false	false	"ABc" ~<> "abc"
false	false	"ABC" ~<> "abc"
false	false	"aBc" ~<> "AbC"
true	true	"abc" ~<> "abd"
true	true	"abc" ~<> "abcd"
true	true	"abcd" ~<> "abc"

D
D (* Structual Operations *)
D

[1]	[1]	1 :: []
[[1]]	[[1]]	[1] :: []
[1,2]	[1,2]	1 :: [2]
[1,2]	[1,2]	1 :: 2 :: []
[1,2,3]	[1,2,3]	1 :: 2 :: [3]
[[1],2]	[[1],2]	[1] :: [2]

[]	[]	[] @ []
[1,2,3]	[1,2,3]	[1,2,3] @ []
[1,2,3]	[1,2,3]	[] @ [1,2,3]
[1,2]	[1,2]	[1] @ [2]
[1,2,3,4]	[1,2,3,4]	[1,2] @ [3,4]

""	""	"" @ ""
"abc"	"abc"	"abc" @ ""
"abc"	"abc"	"" @ "abc"
"ab"	"ab"	"a" @ "b"
"abcd"	"abcd"	"ab" @ "cd"

D (*------------------------------------------------------------
D fn application operators infix infixr nonfix let
D ; also or handle raise if case << >>
D val fun exception type local
D ~= ~<> (real)
D ~ abs ceil floor gcd lcm max min sgn trunc sqrt
D append_map clone eql explode filter fold foldr foreach
D head implode iota len map newstr newvec order ref rev
D set setvec sub tail zip zipwith
D bool char chr int not ntos ord real ston str vec
D c_alphabetic c_downcase c_lower c_numeric c_upcase c_upper
D c_whitespace
D append_stream close eof instream load outstream peekc
D print println readc readln
D ------------------------------------------------------------*)

D
D (* Miscellanea *)
D

D fun P (x, y)    = P (x, y, 1)
D     | (x, 0, r) = r
D     | (x, y, r) = P (x, y-1, x*r)
D     ;
D

1267650600228229401496703205376	1267650600228229401496703205376	P (2, 100)

D
D val evenodd = let
D   fun e x = if x=0 then true else o (x-1)
D   and o x = if x=0 then false else e (x-1)
D in
D   [e 5, o 5]
D end;
D

[false, true]	[false, true]	evenodd

D
D val evenodd_2 =
D   let fun e 0 = true
D           | x = o (x-1)
D       and o 0 = false
D           | x = e (x-1)
D   in
D     [e 5, o 5]
D   end;
D

[false, true]	[false, true]	evenodd_2

D
D type :list = :nil | :cons(x, :list)
D 
D fun length :nil         = 0
D          | :cons (_, t) = 1 + length t
D 
D local
D   fun j (0, r) = r
D       | (x, r) = j (x-1, :cons(x, r))
D in
D   fun numlist x = j (x, :nil)
D end;
D

100	100	length \` numlist 100

D
D type :L = :N | :c (x, :L)
D 
D infixr :c = @
D 
D fun ll :N         = 0
D      | (x=1) :c t = 1 + ll t
D      | _ :c t     = ll t
D      ;

3	3	ll \` 1 :c 0 :c 1 :c 0 :c 1 :c :N

D
D fun j (0, r) = r
D     | (x, r) = j (x-1, x :: r)
D     | x = j (x, []);
D

1000	1000	len \` j 1000

D
D local
D   fun map' (f, [])     = []
D          | (f, h :: t) = f h :: map' (f, t)
D in
D   fun map1 f = fn x = map' (f, x)
D end;
D

[~1,~2,~3]	[~1,~2,~3]	map1 ~ [1,2,3]

D 
D fun map f = let
D               fun map' []     = []
D                      | h :: t = f h :: map' t
D             in
D               fn x = map' x
D             end;
D 

[~1,~2,~3]	[~1,~2,~3]	map ~ [1,2,3]

D
D exception :exp
D 
D fun f x = if x then 0 else raise :exp
D 

2	2	f false handle :foo = 1 | :exp = 2 | :bar = 3

D
D exception :overflow
D 
D fun change (_, 0)  = []
D          | ([], _) = raise :overflow
D          | (coin :: coins, amt) =
D              if coin > amt then
D                change (coins, amt)
D              else
D                coin :: change (coin :: coins, amt - coin)
D                handle :overflow = change (coins, amt);
D

[5,5,2,2,2]	[5,5,2,2,2]	change ([5,2], 16)

D
D type :tree = :leaf (x) | :node (:tree, :tree)
D 
D fun depth :leaf _      = 1
D         | :node (l, r) = 1 + max (depth l, depth r)
D 
D val tree = :node (:node (:node (:leaf 1, :leaf 2),
D                          :node (:leaf 3, :leaf 4)),
D                  (:node (:leaf 3, :leaf 4)));
D 

4	4	depth tree

D
D println ("Passed "
D          @ (ntos \` ref (Tests, 0) - ref (Errors, 0))
D          @ " of "
D          @ (ntos \` ref (Tests, 0))
D          @ " tests")
D if ref (Errors, 0) > 0 then
D    println (ntos (ref (Errors, 0)) @ " ERROR(S)")
D else
D    println "Everything fine!"
D
EOT
