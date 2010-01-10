open Ocamlbuild_plugin

let oUnit_dir = "/Users/farr/Documents/code/oUnit"
let poly_dir = "/Users/farr/Documents/code/ocamlUtils/poly/_build"

let _ = dispatch begin function 
  | After_rules -> 
      ocaml_lib ~extern:true ~dir:oUnit_dir "oUnit";
      ocaml_lib ~extern:true ~dir:poly_dir "poly"
  | _ -> ()
end
