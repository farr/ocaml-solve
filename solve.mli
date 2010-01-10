(** Routines for solving non-liner equations formulated in terms of a
    function [f x]; the solution is the [x] such that [f x] is
    approximately zero.  All routines require that the root in
    question is {b bracketed}, i.e. that there are values [xmin] and
    [xmax], [xmin < xmax], such that [f xmin] and [f xmax] differ in
    sign.  In the event that the routines requiring derivative
    information are not converging, they will fall back to bisection,
    which, while slow, cannot fail to converge. *)

(** [bisect_root ?epsabs ?epsrel ?epsf xmin xmax f] finds a value [x]
    such that [f x] is approximately zero by repeatedly bisecting the
    interval \[[xmin], [xmax]\] until the limits surrounding the root
    meet the given tolerances.  [epsabs] and [epsrel] refer to the
    absolute and relative tolerance of this root; even if the root is
    not within these tolerances, the search will stop when [abs_float
    (f x) < epsf].  The signs of [f xmin] and [f xmax] must differ
    (i.e. a root must exist between [xmin] and [xmax]), and [xmin]
    must be smaller than [xmax]. *)
val bisect_root : ?epsabs : float -> ?epsrel : float -> ?epsf : float -> 
  float -> float -> (float -> float) -> float

(** [bounded_newton ?epsabs ?epsrel ?epsf xmin xmax f df] finds a
    value [x] such that [f x] is approximately zero using Newton's
    method.  [df] is the derivative of [f].  See {!Solve.bisect_root}
    for an explanation of the tolerance parameters [epsabs], [epsrel],
    and [epsf].  Like all routines in the [Solve] module,
    [bounded_newton] falls back on a bisection step if the Newton step
    would land outside the bracketing values [xmin] and [xmax]. *)
val bounded_newton : ?epsabs : float -> ?epsrel : float -> ?epsf : float -> 
  float -> float -> (float -> float) -> (float -> float) -> float

(** [bounded_extended_newton ?epsabs ?epsrel ?epsf xmin xmax fs] finds
    a value [x] such that [fs.(0) x] is approximately zero using an
    extension of Newton's method to higher order.  The array [fs]
    contains the function and successive derivatives to arbitrary
    order.  If there are derivatives up to order n, then the
    convergence of the method is order n+1.  See {!Solve.bisect_root}
    for an explanation of the tolerance parameters [epsabs], [epsrel],
    [epsf].  Like all routines in the [Solve] module,
    [bounded_extended_newton] falls back on a bisection step if the
    extended Newton step would land outside the bracketing values
    [xmin] and [xmax]. *)
val extended_bounded_newton : ?epsabs : float -> ?epsrel : float -> ?epsf : float -> 
  float -> float -> (float -> float) array -> float
