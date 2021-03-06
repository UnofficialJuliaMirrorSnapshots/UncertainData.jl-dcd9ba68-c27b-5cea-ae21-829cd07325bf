""" 
    CertainValue

A simple wrapper type for values with no uncertainty (i.e. represented by a scalar).

## Examples 

The two following ways of constructing values without uncertainty are equivalent. 

```julia 
u1, u2 = CertainValue(2.2), CertainValue(6)
w1, w2 = UncertainValue(2.2), UncertainValue(6)
```
"""
struct CertainValue{T} <: AbstractUncertainValue
    value::T
end

Broadcast.broadcastable(x::CertainValue) = Ref(x.value)

function summarise(uval::CertainValue)
    _type = typeof(uval)
    val = uval.value
    "$_type($val)"
end
Base.show(io::IO, uval::CertainValue) = print(io, summarise(uval))

eltype(v::CertainValue{T}) where {T} = T

Base.size(x::CertainValue) = ()
Base.size(x::CertainValue,d) = convert(Int,d)<1 ? throw(BoundsError()) : 1
Base.axes(x::CertainValue) = ()
Base.axes(x::CertainValue,d) = convert(Int,d)<1 ? throw(BoundsError()) : Base.OneTo(1)
Base.ndims(x::CertainValue) = 0
Base.ndims(::Type{<:CertainValue}) = 0
Base.length(x::CertainValue) = 1
Base.firstindex(x::CertainValue) = 1
Base.lastindex(x::CertainValue) = 1
Base.IteratorSize(::Type{<:CertainValue}) = Base.HasShape{0}()
Base.keys(::CertainValue) = Base.OneTo(1)
Base.getindex(x::CertainValue) = x

function Base.getindex(x::CertainValue, i::Integer)
    Base.@_inline_meta
    @boundscheck i == 1 || throw(BoundsError())
    x
end
function Base.getindex(x::CertainValue, I::Integer...)
    Base.@_inline_meta
    @boundscheck all([i == 1 for i in I]) || throw(BoundsError())
    x
end

Base.first(x::CertainValue) = x
Base.last(x::CertainValue) = x
Base.copy(x::CertainValue) = x

Base.minimum(v::CertainValue) = v.value
Base.maximum(v::CertainValue) = v.value
Base.isnan(x::CertainValue) = Base.isnan(x.value)
Base.abs2(x::CertainValue) = Base.abs2(x.value)

StatsBase.mean(v::CertainValue) = v.value
StatsBase.median(v::CertainValue) = v.value
StatsBase.middle(v::CertainValue) = v.value
StatsBase.quantile(v::CertainValue, q) = v.value
StatsBase.quantile(v::CertainValue, q, n::Int) = v.value
StatsBase.std(v::CertainValue{T}) where {T} = zero(T)

Base.rand(v::CertainValue) = v.value
Base.rand(v::CertainValue{T}, n::Int) where T = repeat([v.value], n)

Base.float(v::CertainValue) = float(v.value)

function Base.:<(x::CertainValue{T1}, y::CertainValue{T2}) where {
        T1 <: Real, T2 <: Real} 
    x.value < y.value
end

function IntervalArithmetic.interval(x::CertainValue{T1}, y::CertainValue{T2}) where {
        T1 <: Real, T2 <: Real} 
    interval(x.value, y.value)
end 


export
CertainValue,
UncertainValue