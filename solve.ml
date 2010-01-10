(*  solve.ml: Solve 1-D non-linear equations. 
    Copyright (C) 2010 Will M. Farr <wmfarr@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)

let eps = sqrt epsilon_float

let rec bisect_root ?(epsabs = eps) ?(epsrel = eps) ?(epsf = eps) xmin xmax f = 
  let fxmax = f xmax and 
      fxmin = f xmin in 
    if fxmax *. fxmin > 0.0 then 
      raise (Failure "bisect_root: f does not change sign over interval");
    let rec bisect_loop xmin xmax fxmin fxmax = 
      let x = 0.5*.(xmin +. xmax) and 
          dx = abs_float (xmax -. xmin) in 
        if dx <= epsabs +. epsrel*.(abs_float x) then 
          x
        else
          let fx = f x in 
            if abs_float fx <= epsf then 
              x
            else if fx *. fxmin >= 0.0 then 
              (* f xmin and f x are same sign. *)
              bisect_loop x xmax fx fxmax
            else
              bisect_loop xmin x fxmin fx in 
      bisect_loop xmin xmax fxmin fxmax

let rec bounded_newton ?(epsabs = eps) ?(epsrel = eps) ?(epsf = eps) xmin xmax f df = 
  let x = 0.5*.(xmin +. xmax) and 
      dx = abs_float (xmax -. xmin) in 
    if dx <= epsabs +. epsrel*.(abs_float x) then begin
      x
    end else
      let rec newton_loop x = 
        let fx = f x in
          if abs_float fx < epsf then 
            x
          else
            let dfx = df x in 
            let xnew = x -. fx /. dfx in 
              if xmin <= xnew && xnew <= xmax then 
                let dx = abs_float (x -. xnew) in 
                  if dx <= epsabs +. epsrel*.(abs_float xnew) then 
                    xnew
                  else
                    newton_loop xnew
              else if fx*.(f xmin) >= 0.0 then 
                bounded_newton ~epsabs:epsabs ~epsrel:epsrel ~epsf:epsf
                  x xmax f df
              else 
                bounded_newton ~epsabs:epsabs ~epsrel:epsrel ~epsf:epsf
                  xmin x f df in 
        newton_loop x
  
let extended_newton_delta fs = 
  let n = Array.length fs in 
    assert(n >= 2);
    let delta = ref 0.0 in 
      for i = 1 to n - 1 do 
        let denom = ref 0.0 and 
            coeff = ref 1.0 and 
            counter = ref 1.0 in 
          for j = 1 to i do 
            denom := !denom +. !coeff*.fs.(j);
            counter := !counter +. 1.0;
            coeff := !coeff *. !delta /. !counter
          done;
          delta := ~-.(fs.(0) /. !denom)
      done;
      !delta

let rec extended_bounded_newton ?(epsabs = eps) ?(epsrel = eps) ?(epsf = eps) xmin xmax fs = 
  let f = fs.(0) and 
      x = 0.5*.(xmin +. xmax) and 
      dx = abs_float (xmax -. xmin) in 
    if dx <= epsabs +. epsrel*.(abs_float x) then begin
      x
    end else
      let farr = Array.make (Array.length fs) 0.0 in 
      let rec extended_newton_loop x = 
        farr.(0) <- f x;
        if abs_float farr.(0) <= epsf then 
          x 
        else begin 
          for i = 1 to Array.length fs - 1 do 
            farr.(i) <- fs.(i) x 
          done;
          let xnew = x +. extended_newton_delta farr in 
            if xmin <= xnew && xnew <= xmax then 
              let dx = abs_float (x -. xnew) in 
                if dx <= epsabs +. epsrel*.(abs_float xnew) then begin
                  xnew
                end else
                  extended_newton_loop xnew
            else if farr.(0)*.(f xmin) > 0.0 then 
              extended_bounded_newton ~epsabs:epsabs ~epsrel:epsrel ~epsf:epsf
                x xmax fs
            else
              extended_bounded_newton ~epsabs:epsabs ~epsrel:epsrel ~epsf:epsf
                xmin x fs 
        end in 
        extended_newton_loop x
