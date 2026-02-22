"""
Main module for `Albatross.jl` -- a Julia software for reduced-order analysis
of vertical-axis wind turbines.
"""
module Albatross

using ConcreteStructs: @concrete
using NNFoil: NNFoil
using NonlinearSolve: NonlinearSolve

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
include("turbine/h-darrieus.jl")

include("aerodynamics/aerodynamics.jl")

include("solvers/solvers.jl")
include("solvers/dmst/discretization.jl")
include("solvers/dmst/output.jl")
include("solvers/dmst/solver.jl")

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
    LocalFlowState,
    AerodynamicCoefficients,
    AbstractSectionAerodynamics,
    NeuralSectionAerodynamics,

    # Solvers
    AbstractSolver,
    solve,
    AbstractDMSTDiscretization,
    UniformAzimuth,
    DMST

end
