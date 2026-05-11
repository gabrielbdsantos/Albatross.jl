# Public API

```@meta
CurrentModule = Albatross
```

## Momentum

```@docs
AbstractMomentumTheory
RankineFroude
SteirosHultmark
wake_velocity_ratio
drag_coefficient
```

## Environment

```@docs
AbstractFluid
IncompressibleFluid
ConstantPropertyFluid
AbstractInflow
UniformInflow
EnvironmentConditions
density
viscosity
speed_of_sound
velocity
```

## Kinematics

```@docs
AbstractRotorKinematics
ConstantAngularVelocity
angular_velocity
```

## Geometry

```@docs
AbstractBladeSection
BladeSection
AbstractBladeGeometry
UniformStraightBlade
section
span
shape
chord
ref_point
radial_pos
span_pos
pitch
```

## Turbine

```@docs
AbstractTurbine
AbstractDarrieusTurbine
UniformBladeHDarrieus
num_blades
kinematics
blades
swept_area
```

## Aerodynamics

```@docs
AbstractSectionAerodynamics
NeuralSectionAerodynamics
aerodynamic_coefficients
```

## Grid

```@docs
AbstractGrid
AbstractGrid1D
UniformGrid1D
AbstractAzimuthalGrid
UniformAzimuthalGrid
AbstractSpanwiseGrid
UniformSpanwiseGrid
bounds
extent
points
weights
```

## Solvers

```@docs
AbstractSolver
solve
```

## DMST

```@docs
DMST
DMSTGrid
DMSTSolverOptions
DMSTSolveStats
DMSTStreamtubeContext
build_streamtube_contexts
DMSTNonlinearSolution
DMSTStreamtubeFields
evaluate_streamtube_fields
```

## Utilities

```@docs
@define_cat_methods
```
