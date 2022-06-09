abstract type AbstractSurveyComponent end

id(x::AbstractSurveyComponent) = x.id
children(x::AbstractSurveyComponent) = x.children
title(x::AbstractSurveyComponent) = x.title
description(x::AbstractSurveyComponent) = x.description
language(x::AbstractSurveyComponent) = x.language

function tovector(child::T)::Vector{T} where {T<:AbstractSurveyComponent}
    return [child]
end

function tovector(children)::Vector{<:AbstractSurveyComponent}
    return [child for child in children]
end

tovector(::Nothing) = return Question[]

function Base.prepend!(c::AbstractSurveyComponent, item)
    prepend!(children(c), tovector(item))
    return item
end

function Base.append!(c::AbstractSurveyComponent, item)
    append!(children(c), tovector(item))
    return item
end

function Base.insert!(c::AbstractSurveyComponent, i::Int, item)
    insert!(children(c), i, item)
    return item
end
