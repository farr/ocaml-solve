open OUnit
open Solve

let eps = sqrt epsilon_float
let reps = eps /. 100.0 

let assert_equal_float ?(epsabs = eps) ?(epsrel = eps) = 
  assert_equal ~cmp:(cmp_float ~epsabs:epsabs ~epsrel:epsrel) ~printer:string_of_float

let random_poly_and_roots n = 
  let roots = Array.init n (fun _ -> Random.float 1.0 -. 0.5) in 
    Array.fast_sort Pervasives.compare roots;
    (Poly.from_roots roots, roots)

let random_root_and_bracket roots = 
  let nr = Array.length roots in 
    assert(nr >= 3);
    let ri = 1 + Random.int (nr - 2) in 
    let r = roots.(ri) in
    let rmin = 0.5*.(roots.(ri-1) +. r) and 
        rmax = 0.5*.(roots.(ri+1) +. r) in 
      (r, rmin, rmax)

let test_bisect_root () = 
  for i = 1 to 100 do 
    let n = 3 + (Random.int 5) in 
    let (p, roots) = random_poly_and_roots n in 
    let (r,rmin,rmax) = random_root_and_bracket roots in 
    let brk_r = bisect_root ~epsabs:reps ~epsrel:reps ~epsf:0.0 
      rmin rmax (fun x -> Poly.eval p x) in 
      assert_equal_float r brk_r
  done

let test_bounded_newton () = 
  for i = 1 to 100 do 
    let n = 3 + (Random.int 5) in 
    let (p, roots) = random_poly_and_roots n in 
    let dp = Poly.deriv p in 
    let (r,rmin,rmax) = random_root_and_bracket roots in 
    let newt_r = bounded_newton ~epsabs:reps ~epsrel:reps ~epsf:0.0
      rmin rmax (fun x -> Poly.eval p x) (fun x -> Poly.eval dp x) in 
      assert_equal_float r newt_r
  done

let test_extended_bounded_newton_handwritten () = 
  let f x = (x -. 3.0)*.(x +. 4.0)*.(x +. 3.0)*.(x -. 2.0) and 
      df x = (-18.0) +. x*.(-34.0 +. x*.(6.0 +. 4.0*.x)) and 
      ddf x = (-34.0) +. x*.(12.0 +. 12.0*.x) and 
      dddf x = 12.0 +. 24.0*.x in 
  let r = extended_bounded_newton ~epsabs:reps ~epsrel:reps ~epsf:0.0 
    2.5 4.0 [|f; df; ddf; dddf|] in 
    assert_equal_float 3.0 r

let test_extended_bounded_newton () = 
  for i = 1 to 100 do 
    let n = 3 + (Random.int 5) in 
    let (p, roots) = random_poly_and_roots n in 
    let dp = Poly.deriv p in 
    let ddp = Poly.deriv dp in 
    let dddp = Poly.deriv ddp in 
    let (r, rmin, rmax) = random_root_and_bracket roots in 
    let ebnewt_r = extended_bounded_newton ~epsabs:reps ~epsrel:reps ~epsf:0.0 
      rmin rmax [|(fun x -> Poly.eval p x);
                  (fun x -> Poly.eval dp x);
                  (fun x -> Poly.eval ddp x);
                  (fun x -> Poly.eval dddp x)|] in 
      assert_equal_float ~msg:(Printf.sprintf "failed on iteration %d; f(x) = %g" i (Poly.eval p ebnewt_r)) r ebnewt_r
  done

let tests = "solve.ml tests" >:::
  ["bisect_root test" >:: test_bisect_root;
   "bounded_newton test" >:: test_bounded_newton;
   "handwritten extended_bounded_newton test" >:: test_extended_bounded_newton_handwritten;
   "extended_bounded_newton test" >:: test_extended_bounded_newton]
