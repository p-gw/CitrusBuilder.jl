@kwdef struct QuestionGroup <: AbstractSurveyComponent
    id::Int
    title::String
    description::String = ""
    language::String = DEFAULT_LANGUAGE[]
    children::Vector{Question} = Question[]
    # internal
    order::Union{Nothing,Int} = nothing
    survey_id::Union{Nothing,Int} = nothing
end

question_group(; kwargs...) = QuestionGroup(; kwargs...)
question_group(children::Function; kwargs...) = QuestionGroup(; kwargs..., children=tovector(children()))
