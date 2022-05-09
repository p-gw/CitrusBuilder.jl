# subquestions / response options
@kwdef struct SubQuestion <: AbstractQuestion
    code::AbstractString
    subquestion::AbstractString
end

subquestion(; kwargs...) = SubQuestion(; kwargs...)

# text questions
abstract type AbstractTextQuestion <: AbstractQuestion end

mutable struct ShortTextQuestion <: AbstractTextQuestion
    core::QuestionCore
end

function short_text_question(; kwargs...)
    return ShortTextQuestion(QuestionCore(; kwargs...))
end

mutable struct LongTextQuestion <: AbstractTextQuestion
    core::QuestionCore
end

function long_text_question(; kwargs...)
    return LongTextQuestion(QuestionCore(; kwargs...))
end

mutable struct HugeTextQuestion <: AbstractTextQuestion
    core::QuestionCore
end

function huge_text_question(; kwargs...)
    return HugeTextQuestion(QuestionCore(; kwargs...))
end

mutable struct MultipleShortTextQuestion <: AbstractTextQuestion
    core::QuestionCore
    subquestions::Vector{SubQuestion}
end

function multiple_short_text_question(; subquestions, kwargs...)
    return MultipleShortTextQuestion(
        QuestionCore(; kwargs...),
        subquestions
    )
end

function multiple_short_text_question(children::Function; kwargs...)
    return MultipleShortTextQuestion(
        QuestionCore(; kwargs...),
        tovector(children())
    )
end

# multiple choice questions
abstract type AbstractSingleChoiceQuestion <: AbstractQuestion end

# possible types:
#   - 5 point choice
#   - List (Dropdown)
#   - List (Radio)
#   - List with comment
#   - Image Select List (Radio)
#   - Bootstrap Button

struct SingleChoiceQuestion <: AbstractSingleChoiceQuestion
    core::QuestionCore
    subquestions::Vector{SubQuestion}
    type::String
    other::Bool
end

function five_point_choice_question(; other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        SubQuestion[],
        "five-point-choice",
        other
    )
end

function dropdown_list_question(; subquestions, other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        subquestions,
        "dropdown",
        other
    )
end

function dropdown_list_question(children::Function; other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        tovector(children()),
        "dropdown",
        other
    )
end

function radio_list_question(; subquestions, other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        subquestions,
        "radio",
        other
    )
end

function radio_list_question(children::Function; other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        tovector(children()),
        "radio",
        other
    )
end

