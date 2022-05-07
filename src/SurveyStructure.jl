abstract type AbstractSurveyComponent end

@kwdef mutable struct Question <: AbstractSurveyComponent
    code::AbstractString
    question::AbstractString
    help::AbstractString
end

@kwdef mutable struct QuestionGroup <: AbstractSurveyComponent
    id::Integer
    # text elements
    title::AbstractString
    description::AbstractString
    children::Vector{Question} = Question[]
end

question_group(; kwargs...) = QuestionGroup(; kwargs..., children=[])
function question_group(children::Function; kwargs...)
    return QuestionGroup(; kwargs..., children=tovector(children()))
end

@kwdef mutable struct Survey
    # general settings
    id::Integer
    # text elements
    title::AbstractString
    description::AbstractString = ""
    # children
    children::Vector{QuestionGroup} = QuestionGroup[]
end

survey(; kwargs...) = Survey(; kwargs..., children=[])
function survey(children; kwargs...)
    return Survey(; kwargs..., children=tovector(children()))
end

function tovector(child::T)::Vector{T} where {T<:AbstractSurveyComponent}
    return [child]
end

function tovector(children)::Vector{<:AbstractSurveyComponent}
    return [child for child in children]
end
