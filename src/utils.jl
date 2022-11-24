VectorOrElement{T} = Union{T,Vector{T}} where {T}

isnumber(c::AbstractChar) = !isnothing(tryparse(Int, string(c)))
isalphanumeric(c::AbstractChar) = isletter(c) || isnumber(c)

prefix(i, n) = i == n ? "└──" : "├──"

function tovector(child::T)::Vector{T} where {T}
    return T[child]
end

function tovector(children::Vector{T})::Vector{T} where {T}
    return children
end

function tovector(children::Tuple{Vararg{T}})::Vector{T} where {T}
    return T[child for child in children]
end

function tovector(children::Base.Generator)
    return collect(children)
end

tovector(::Nothing) = return []

