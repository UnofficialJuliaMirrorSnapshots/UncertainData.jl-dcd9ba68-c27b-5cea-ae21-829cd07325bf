import ..UncertainDatasets: AbstractUncertainIndexValueDataset

"""
    resample(x::AbstractUncertainIndexValueDataset, resampling::SequentialResampling)

Resample `x` according to a sequential resampling constraint. 

This way of resampling introduces some serial dependence between the elements of `x` - 
*beyond* what might already be present in the dataset. This is because imposing a 
sequential constraint (e.g. `StrictlyIncreasing`) to the `i`-th value of the dataset 
imposes constraints on what is possible to sample from the `i+1`th value.

## Example 

```julia
# Some example data 
N = 50
x_uncertain = [UncertainValue(Normal, x, rand(Uniform(0.1, 0.8))) for x in rand(N)]
y_uncertain = [UncertainValue(Normal, y, rand(Uniform(0.1, 0.8))) for y in rand(N)]
x = UncertainValueDataset(x_uncertain)
y = UncertainValueDataset(y_uncertain)

time_uncertain = [UncertainValue(Normal, i, 1) for i = 1:length(x)];
time_certain = [CertainValue(i) for i = 1:length(x)];
timeinds_x = UncertainIndexDataset(time_uncertain)
timeinds_y = UncertainIndexDataset(time_certain)

X = UncertainIndexValueDataset(timeinds_x, x)
Y = UncertainIndexValueDataset(timeinds_y, y);

# Resample 
seq_resampling = SequentialResampling(StrictlyIncreasing())
resample(X, seq_resampling)
```
"""
function resample(x::AbstractUncertainIndexValueDataset, 
        resampling::SequentialResampling{S}) where {S}
    resample(x, resampling.sequential_constraint)
end

"""
    resample(x::AbstractUncertainIndexValueDataset, resampling::SequentialInterpolatedResampling)

Resample `x` according to a sequential resampling constraint, then interpolate the draw(s) to 
some specified grid. 

This way of resampling introduces some serial dependence between the elements of `x` - 
*beyond* what might already be present in the dataset. This is because imposing a 
sequential constraint (e.g. `StrictlyIncreasing`) to the `i`-th value of the dataset 
imposes constraints on what is possible to sample from the `i+1`th value.

## Example 

```julia
# Some example data 
N = 50
x_uncertain = [UncertainValue(Normal, x, rand(Uniform(0.1, 0.8))) for x in rand(N)]
y_uncertain = [UncertainValue(Normal, y, rand(Uniform(0.1, 0.8))) for y in rand(N)]
x = UncertainValueDataset(x_uncertain)
y = UncertainValueDataset(y_uncertain)

time_uncertain = [UncertainValue(Normal, i, 1) for i = 1:length(x)];
time_certain = [CertainValue(i) for i = 1:length(x)];
timeinds_x = UncertainIndexDataset(time_uncertain)
timeinds_y = UncertainIndexDataset(time_certain)

X = UncertainIndexValueDataset(timeinds_x, x)
Y = UncertainIndexValueDataset(timeinds_y, y);

# Resample 
seqintp_resampling = SequentialInterpolatedResampling(StrictlyIncreasing(), RegularGrid(0:2:N))
resample(X, seqintp_resampling)
```
"""
function resample(x::AbstractUncertainIndexValueDataset, 
        resampling::SequentialInterpolatedResampling{S, G}) where {S, G}
    resample(x, resampling.sequential_constraint, resampling.grid)
end

"""
    resample(x::AbstractUncertainValueDataset, resampling::ConstrainedValueResampling)

Resample `x` by first constraining the supports of the distributions/populations 
furnishing the uncertain values, then drawing samples from the limited supports.

Sampling is done without assuming any sequential dependence between the 
elements of `x`, such no that no dependence is introduced in the draws beyond what 
is potentially already present in the collection of values.

## Example 

```julia
# Some example data 
N = 50
x_uncertain = [UncertainValue(Normal, x, rand(Uniform(0.1, 0.8))) for x in rand(N)]
y_uncertain = [UncertainValue(Normal, y, rand(Uniform(0.1, 0.8))) for y in rand(N)]
x = UncertainValueDataset(x_uncertain)
y = UncertainValueDataset(y_uncertain)

# Resample with different constraints
resample(x, ConstrainedValueResampling(TruncateStd(1.5))
resample(y, ConstrainedValueResampling(TruncateStd(0.5))
resample(y, ConstrainedValueResampling(TruncateQuantiles(0.2, 0.8))
```
"""
function resample(x::AbstractUncertainValueDataset, resampling::ConstrainedValueResampling{1})
    constrained_x = constrain(x, resampling.constraints[1]) 
    
    resample(constrained_x, resampling.n)
end

"""
    resample(x::AbstractUncertainIndexValueDataset, resampling::ConstrainedIndexValueResampling)

Resample `x` by first constraining the supports of the distributions/populations 
furnishing the uncertain indices and values, then drawing samples from the limited supports.

Sampling is done without assuming any sequential dependence between the 
elements of `x`, such no that no dependence is introduced in the draws beyond what 
is potentially already present in the collection of values.

## Example 

```julia
# Some example data 
N = 50
x_uncertain = [UncertainValue(Normal, x, rand(Uniform(0.1, 0.8))) for x in rand(N)]
y_uncertain = [UncertainValue(Normal, y, rand(Uniform(0.1, 0.8))) for y in rand(N)]
x = UncertainValueDataset(x_uncertain)
y = UncertainValueDataset(y_uncertain)

time_uncertain = [UncertainValue(Normal, i, 1) for i = 1:length(x)];
time_certain = [CertainValue(i) for i = 1:length(x)];
timeinds_x = UncertainIndexDataset(time_uncertain)
timeinds_y = UncertainIndexDataset(time_certain)

X = UncertainIndexValueDataset(timeinds_x, x)
Y = UncertainIndexValueDataset(timeinds_y, y);

###########################
# Define resampling scheme 
###########################

# Truncate each of the indices for x at 0.8 their standard deviation around the mean
constraints_x_inds = TruncateStd(0.8)

# Truncate each of the indices for y at 1.5 their standard deviation around the mean
constraints_y_inds = TruncateStd(1.5)

# Truncate each of the values of x at the 20th percentile range
constraints_x_vals = [TruncateQuantiles(0.4, 0.6) for i = 1:N];

# Truncate each of the values of x at the 80th percentile range
constraints_y_vals = [TruncateQuantiles(0.1, 0.9) for i = 1:N];

cs_x = (constraints_x_inds, constraints_x_vals)
cs_y = (constraints_y_inds, constraints_y_vals)

###########
# Resample 
###########
resample(X, ConstrainedIndexValueResampling(cs_x))
resample(Y, ConstrainedIndexValueResampling(cs_y))
```
"""
function resample(x::AbstractUncertainIndexValueDataset, resampling::ConstrainedIndexValueResampling{2, 1})
    
    constrained_inds = constrain(x.indices, resampling.constraints[1][1])
    constrained_vals = constrain(x.values, resampling.constraints[1][2])
    
    d = UncertainIndexValueDataset(constrained_inds, constrained_vals)
    
    resample(d, resampling.n)
end
