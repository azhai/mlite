(* Triginometric function by Bruce Axtens, 2014 *)

val PI = 3.14159265358979323846264338327950288419716939937510

(* Degrees to Radians *)
fun d2r d = d * PI / 180

(* Radians to Degrees *)
fun r2d r = 180 * r / PI

(* Sine using the function at http://getpocket.com/a/read/373110659 *)
fun sine x = 
      let val a0 = 1.0
          and a1 = ~0.1666666666640169148537065260055
          and a2 =  0.008333333316490113523036717102793
          and a3 = ~0.0001984126600659171392655484413285
          and a4 =  0.000002755690114917374804474016589137
          and a5 = ~0.00000002502845227292692953118686710787
          and a6 =  0.0000000001538730635926417598443354215485
          and x2 = x * x
      in      
          x * (a0 + x2*(a1 + x2*(a2 + x2*(a3 + x2*(a4 + x2*(a5 + x2*a6))))))
      end

(* Cosine defined as an identity based on Sine *)
fun cosine theta = sine (PI / 2 - theta)

(* Tangent theta = Sine theta / Cosine theta *)
fun tangent theta = (sine theta) / (cosine theta)

(* Secant theta = 1 / Cosine theta *)
fun secant theta = 1 / (cosine theta)

(* Cosecant theta = 1 / Sine theta *)
fun cosecant theta = 1 / (sine theta)

(* Cotangent theta = Cosine theta / Sine theta *)
fun cotangent theta = cosine theta / sine theta

(* http://blogs.scientificamerican.com/roots-of-unity/2013/09/12/10-trig-functions-youve-never-heard-of/ *)

(* Versine:             *) fun versin theta = 1 - (cosine theta)
(* Vercosine:           *) fun vercosin theta = 1 + (cosine theta)
(* Coversine:           *) fun coversin theta = 1 - (sine theta)
(* Covercosine:         *) fun covercosine theta = 1 + (sine theta)
(* Haversine:           *) fun haversin theta = (versin theta) / 2
(* Havercosine:         *) fun havercosin theta = (vercosin theta) / 2
(* Hacoversine:         *) fun hacoversin theta = (coversin theta) / 2
(* Hacovercosine:       *) fun hacovercosin theta = (covercosin theta) / 2
(* Exsecant:            *) fun exsec theta = (secant theta) - 1
(* Excosecant:          *) fun excsc theta = (cosecant theta) - 1
