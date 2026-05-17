"""
    AbstractSolver

Abstract supertype for aerodynamic and performance solvers.

A subtype of `AbstractSolver` represents a complete numerical procedure that
evaluates a turbine model under given environment and operating conditions
(e.g. DMST, Actuator Cylinder, or other rotor solvers).

This abstraction defines the solver algorithm itself and is independent of the
turbine geometry, inflow, and fluid models, which are provided as inputs to
[`solve`](@ref).
"""
abstract type AbstractSolver end

"""
    solve(solver::AbstractSolver, args...; kwargs...)

Execute the solver and return its results.

Concrete solver implementations must define this method and specify the
required input arguments (for example turbine model, inflow model, fluid model,
and numerical settings).

The return type is solver-dependent and typically contains integrated rotor
loads, performance coefficients, and auxiliary diagnostic information.
"""
function solve end
