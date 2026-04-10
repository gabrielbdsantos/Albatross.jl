import Pkg
using BenchmarkTools

const PROJECT = Pkg.project()

run_or_return(benchmark::BenchmarkTools.Benchmark, project::Pkg.API.ProjectInfo) = (
    split(dirname(project.path), "/")[end] == "benchmark"
        ? display(run(benchmark))
        : benchmark
)

run_or_return(benchmark::BenchmarkTools.Benchmark) = run_or_return(benchmark, PROJECT)
