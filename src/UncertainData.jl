module UncertainData

using Distributions
using IntervalArithmetic
using RecipesBase
using StatsBase
using StaticArrays
using Statistics
using KernelDensity



display_update = true
version = "v0.5.0"
update_name = "update_$version"

if display_update
if !isfile(joinpath(@__DIR__, update_name))
printstyled(stdout,
"""
\nUpdate message: UncertainData $version
----------------
New features
----------------

- Support for many more StatsBase functions. These can be applied to single uncertain values,
    pairs of uncertain values, single uncertain datasets, and to collections of uncertain values.
- The `UncertainValue` constructor accepts instances of distributions, and  
    instances of truncated distributions.
- Experimental support for nested populations.
"""; color = :light_magenta)
touch(joinpath(@__DIR__, update_name))
end
end

# Uncertain values
include("uncertain_values/UncertainValues.jl")

# Uncertain datasets
include("uncertain_datasets/UncertainDatasets.jl")

# Sampling constraints
include("sampling_constraints/SamplingConstraints.jl")

# Interpolation and interpolation grids 
include("interpolation/InterpolationsAndGrids.jl")

# Resampling
include("resampling/Resampling.jl")

# Mathematics 
include("mathematics/UncertainMathematics.jl")

# Uncertain statistics
include("statistics/UncertainStatistics.jl")

# Plot recipes
include("plot_recipes/UncertainDataPlotRecipes.jl")

# Operations between uncertain UncertainValues
include("uncertain_values/operations/merging.jl")

# Example datasets 
include("example_datasets/example_uvals.jl")

export UncertainScalarBinomialDistributed

end # module
