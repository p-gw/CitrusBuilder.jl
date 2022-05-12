# subquestions / response options
@kwdef struct SubQuestion <: AbstractQuestion
    code::AbstractString
    subquestion::AbstractString
end

"""
    subquestion(; code, subquestion)

Construct a LimeSurvey Subquestion.
"""
subquestion(; kwargs...) = SubQuestion(; kwargs...)

struct ResponseOption <: AbstractQuestion
    code::AbstractString
    option::AbstractString
end

"""
    response_option(; code, option)

Construct a LimeSurvey Response Option.
"""
response_option(; code, option) = ResponseOption(code, option)

struct ResponseScale
    header::AbstractString
    options::Vector{ResponseOption}
end

"""
    response_scale(; options::Vector{ResponseOption}, header::AbstractString)
    response_scale(children; header::AbstractString)

Construct a LimeSurvey Response Scale using one or multiple response options.

# Examples
```julia-repl
julia> options = [
    response_option(code="A1", option="1"),
    response_option(code="A2", option="2")
]
julia> response_scale(options=options, header="my response scale")

```
"""
response_scale(; options, header="") = ResponseScale(header, options)


"""
    response_scale(children; header::AbstractString)

Construct a LimeSurvey Response Scale using `do ... end` syntax for response options.

# Examples
```julia-repl
julia> response_scale(header="my response scale") do
    response_option(code="A1", option="1"),
    response_option(code="A2", option="2")
end
```
"""
function response_scale(options::Function; header="")
    return ResponseScale(header, tovector(options()))
end

"""
    point_scale(n::Integer)

Construct a `ResponseScale` ranging from `1` to `n`.

# Examples
julia> point_scale(3)
"""
function point_scale(n::Integer)
    options = [response_option(code="A$i", option="$i") for i in 1:n]
    scale = response_scale(options=options)
    return scale
end

# text questions
abstract type AbstractTextQuestion <: AbstractQuestion end

struct TextQuestion <: AbstractTextQuestion
    core::QuestionCore
    type::String
end

function short_text_question(; kwargs...)
    return TextQuestion(QuestionCore(; kwargs...), "short")
end

function long_text_question(; kwargs...)
    return TextQuestion(QuestionCore(; kwargs...), "long")
end

function huge_text_question(; kwargs...)
    return TextQuestion(QuestionCore(; kwargs...), "huge")
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
    options::ResponseScale
    type::String
    other::Bool
end

function five_point_choice_question(; other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        point_scale(5),
        "radio",
        other
    )
end

function single_choice_question(; options, type="radio", other=false, kwargs...)
    return SingleChoiceQuestion(
        QuestionCore(; kwargs...),
        options,
        type,
        other
    )
end

function dropdown_list_question(; kwargs...)
    return single_choice_question(; type="dropdown", kwargs...)
end

function radio_list_question(; kwargs...)
    return single_choice_question(; type="radio", kwargs...)
end

# function radio_list_question(children::Function; other=false, kwargs...)
#     return SingleChoiceQuestion(
#         QuestionCore(; kwargs...),
#         tovector(children()),
#         "radio",
#         other
#     )
# end

# multiple choice questions
struct MultipleChoiceQuestion <: AbstractQuestion
    core::QuestionCore
    options::ResponseScale
    comments::Bool
    other::Bool
end

function multiple_choice_question(; options, comments=false, other=false, kwargs...)
    return MultipleChoiceQuestion(
        QuestionCore(; kwargs...),
        options,
        comments,
        other
    )
end

# array questions
# 5 point
# 10 point
# yesnouncertain
# increasesamedecrease
# by column
# dual scale
struct ArrayQuestion <: AbstractQuestion
    core::QuestionCore
    subquestions::Vector{SubQuestion}
    scales::Union{ResponseScale,NTuple{2,ResponseScale}}
    type::String
end

function array_question(; subquestions, options, type="radio", kwargs...)
    return ArrayQuestion(
        QuestionCore(; kwargs...),
        subquestions,
        options,
        type
    )
end

function array_five_point_choice_question(; subquestions, kwargs...)
    return ArrayQuestion(
        QuestionCore(; kwargs...),
        subquestions,
        point_scale(5),
        "radio"
    )
end

function array_five_point_choice_question(children::Function; kwargs...)
    return ArrayQuestion(
        QuestionCore(; kwargs...),
        tovector(children()),
        point_scale(5),
        "radio"
    )
end

function array_ten_point_choice_question(; subquestions, kwargs...)
    return ArrayQuestion(
        QuestionCore(; kwargs...),
        subquestions,
        point_scale(10),
        "radio"
    )
end

function array_ten_point_choice_question(children::Function; kwargs...)
    return ArrayQuestion(
        QuestionCore(; kwargs...),
        tovector(children()),
        point_scale(10),
        "radio"
    )
end
