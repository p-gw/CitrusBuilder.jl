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

# mask questions
abstract type AbstractMaskQuestion <: AbstractQuestion end

struct DateSelect <: AbstractMaskQuestion
    core::QuestionCore
    minimum
    maximum
    type::String
    month_style::String
end

function date_select(; minimum=nothing, maximum=nothing, type="default", month_style="default", kwargs...)
    return DateSelect(
        QuestionCore(; kwargs...),
        minimum,
        maximum,
        type,
        month_style
    )
end

struct FileUpload <: AbstractMaskQuestion
    core::QuestionCore
    show_title::Bool
    show_comment::Bool
    max_filesize::Integer
    min_files::Integer
    max_files::Integer
    allowed_filetypes::Union{AbstractString,Vector{<:AbstractString}}
    function FileUpload(core, show_title, show_comment, max_filesize, min_files, max_files, allowed_filetypes)
        min_files <= max_files || error("Maximum number of files must be greater than minimum number of files.")
        max_filesize >= 0 || error("Maximum filesize must be non-negative.")
        new(core, show_title, show_comment, max_filesize, min_files, max_files, allowed_filetypes)
    end
end

function file_upload(; show_title=true, show_comment=true, max_filesize=10240, min_files=0, max_files=1, allowed_filetypes=["png", "gif", "doc", "odt", "jpg", "pdf", "png"], kwargs...)
    return FileUpload(
        QuestionCore(; kwargs...),
        show_title,
        show_comment,
        max_filesize,
        min_files,
        max_files,
        allowed_filetypes
    )
end

struct GenderSelect <: AbstractMaskQuestion
    core::QuestionCore
    type::String
end

function gender_select(; type="button", kwargs...)
    return GenderSelect(
        QuestionCore(; kwargs...),
        type
    )
end

struct LanguageSwitch <: AbstractMaskQuestion
    core::QuestionCore
end

language_switch(; kwargs...) = LanguageSwitch(QuestionCore(; kwargs...))

struct NumericalInput <: AbstractMaskQuestion
    core::QuestionCore
    minimum::Union{Nothing,<:Real}
    maximum::Union{Nothing,<:Real}
    maximum_chars::Union{Nothing,Integer}
    integer_only::Bool
    function NumericalInput(core, minimum, maximum, maximum_chars, integer_only)
        if integer_only
            isnothing(minimum) || minimum isa Integer || error("Input is integer only, but minimum is not an integer.")
            isnothing(maximum) || maximum isa Integer || error("Input is integer only, but maximum is not an integer.")
        end
        if !(isnothing(minimum) || isnothing(maximum))
            minimum < maximum || error("Maximum value is not greater than minimum value.")
        end
        new(core, minimum, maximum, maximum_chars, integer_only)
    end
end

function numerical_input(; minimum=nothing, maximum=nothing, maximum_chars=nothing, integer_only=false, kwargs...)
    return NumericalInput(
        QuestionCore(; kwargs...),
        minimum,
        maximum,
        maximum_chars,
        integer_only
    )
end

struct MultipleNumericalInput <: AbstractMaskQuestion
    core::QuestionCore
    subquestions::Vector{SubQuestion}
    minimum::Union{Nothing,<:Real}
    maximum::Union{Nothing,<:Real}
    maximum_chars::Union{Nothing,Integer}
    minimum_sum::Union{Nothing,<:Real}
    maximum_sum::Union{Nothing,<:Real}
    integer_only::Bool
    function MultipleNumericalInput(core, subquestions, minimum, maximum, maximum_chars, minimum_sum, maximum_sum, integer_only)
        if integer_only
            isnothing(minimum) || minimum isa Integer || error("Input is integer only, but minimum is not an integer.")
            isnothing(maximum) || maximum isa Integer || error("Input is integer only, but maximum is not an integer.")
            isnothing(minimum_sum) || minimum_sum isa Integer || error("Input is integer only, but minimum sum is not an integer.")
            isnothing(maximum_sum) || maximum_sum isa Integer || error("Input is integer only, but maximum sum is not an integer.")
        end
        if !isnothing(minimum) && !isnothing(maximum)
            minimum < maximum || error("Maximum value is not greater than minimum value.")
        end
        if !isnothing(minimum_sum) && !isnothing(maximum_sum)
            minimum_sum < maximum_sum || error("Maximum sum is not greater than minimum sum.")
        end
        return new(core, subquestions, minimum, maximum, maximum_chars, minimum_sum, maximum_sum, integer_only)
    end
end

function multiple_numerical_input(; subquestions=SubQuestion[], minimum=nothing, maximum=nothing, maximum_chars=nothing, minimum_sum=nothing, maximum_sum=nothing, integer_only=false, kwargs...)
    return MultipleNumericalInput(
        QuestionCore(; kwargs...),
        subquestions,
        minimum,
        maximum,
        maximum_chars,
        minimum_sum,
        maximum_sum,
        integer_only
    )
end

function multiple_numerical_input(children::Function; minimum=nothing, maximum=nothing, maximum_chars=nothing, minimum_sum=nothing, maximum_sum=nothing, integer_only=false, kwargs...)
    return MultipleNumericalInput(
        QuestionCore(; kwargs...),
        tovector(children()),
        minimum,
        maximum,
        maximum_chars,
        minimum_sum,
        maximum_sum,
        integer_only
    )
end

struct RankingQuestion <: AbstractMaskQuestion end

struct AdvancedRankingQuestion <: AbstractMaskQuestion end

struct TextDisplay <: AbstractMaskQuestion end

struct YesNoQuestion <: AbstractMaskQuestion end

struct Equation <: AbstractMaskQuestion end


