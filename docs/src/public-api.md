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
thrust_coefficient
```

## Environment

```@docs
AbstractFluid
IncompressibleFluid
ConstantPropertyFluid
AbstractInflow
UniformInflow
Environment
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
reference_point
radial_position
spanwise_position
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
DMSTSubmodels
DMSTStreamtubeContext
DMSTNonlinearSolution
DMSTStreamtubeFields
build_streamtube_contexts
evaluate_streamtube_fields
```

### Curvature Correction

```@docs
AbstractCurvatureCorrection
Bangga
Goude
aoa_correction
```

## Utilities

```@docs
@define_cat_methods
```
