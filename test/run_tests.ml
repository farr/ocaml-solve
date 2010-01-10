open OUnit

let tests = "all tests" >:::
  ["solve.ml tests" >: Solve_test.tests]

let _ = 
  Random.self_init ();
  let results = run_test_tt_main tests in 
  let nfail = 
    List.fold_left
      (fun nf res -> 
         match res with 
           | RSuccess(_) -> nf
           | _ -> nf + 1)
      0
      results in 
    exit nfail
