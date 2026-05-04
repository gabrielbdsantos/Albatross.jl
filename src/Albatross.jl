"""
Main module for `Albatross.jl` -- a Julia software for reduced-order analysis
of vertical-axis wind turbines.
"""
module Albatross

using LinearAlgebra: LinearAlgebra
using ConcreteStructs: @concrete
using FillArrays: Fill
using NNFoil: NNFoil
using NonlinearSolve: NonlinearSolve
using StructArrays

include("utils.jl")

include("momentum/momentum.jl")
include("momentum/rankine_froude.jl")
include("momentum/steiros_hultmark.jl")

include("environment/fluid.jl")
include("environment/inflow.jl")
include("environment/environment.jl")

include("kinematics/kinematics.jl")

include("geometry/section.jl")
include("geometry/blade.jl")

include("turbine/turbine.jl")
include("turbine/h_darrieus.jl")

include("aerodynamics/aerodynamics.jl")

include("grid/grid.jl")
include("grid/azimuthal.jl")
include("grid/spanwise.jl")

include("solvers/solvers.jl")
include("solvers/dmst/dmst.jl")

export
    # Momentum
    AbstractMomentumTheory,
    RankineFroude,
    SteirosHultmark,

    # Environment
    AbstractFluid,
    ConstantPropertyFluid,
    AbstractInflow,
    UniformInflow,
    EnvironmentConditions,

    # Kinematics
    AbstractRotorKinematics,
    ConstantAngularVelocity,

    # Geometry
    AbstractBladeSection,
    BladeSection,
    AbstractBladeGeometry,
    UniformStraightBlade,

    # Turbine
    AbstractTurbine,
    AbstractDarrieusTurbine,
    UniformBladeHDarrieus,

    # Aerodynamics
    # LocalFlowState,
    # AerodynamicCoefficients,
    AbstractSectionAerodynamics,
    NeuralSectionAerodynamics,

    # Grid
    AbstractGrid,
    AbstractGrid1D,
    UniformGrid1D,
    AbstractAzimuthalGrid,
    UniformAzimuthalGrid,
    AbstractSpanwiseGrid,
    UniformSpanwiseGrid,

    # Solvers
    AbstractSolver,
    solve,

    ## DMST
    DMST,
    DMSTGrid,
    DMSTSolverOptions,
    DMSTSolveStats,
    # DMSTSolution,
    DMSTStreamtubeFields,
    evaluate_streamtube_fields

end
