"""
    Question

# Fields
- `id::String`: An alphanumeric question id. Must start with a letter.
- `question::String`: The question title
- `help::String`: Help text provided to users
- `mandatory::Bool`: Determines if the question is mandatory
- `other::Bool`: Determines if the questions as *other* category
- `relevance::String`: A LimeSurvey Expression Script
"""
@kwdef struct Question <: AbstractQuestion
    id::String
    type::String
    mandatory::Bool = false
    other::Bool = false
    relevance::String = "1"
    language_settings::Vector{LanguageSetting}
    subquestions::Vector{SubQuestion} = SubQuestion[]
    options::Vector{ResponseOption} = ResponseOption[]
    function Question(id, type, mandatory, other, relevance, language_settings, subquestions, options)
        validate(id) || error("Question codes must start with a letter and may only contain alphanumeric characters.")
        return new(id, type, mandatory, other, relevance, language_settings, subquestions, options)
    end
end

is_mandatory(question::Question) = question.mandatory
has_other(question::Question) = question.other

# text questions
function short_text_question(id, title::String; help=nothing, kwargs...)
    setting = language_setting(default_language(), title; help)
    return Question(; id, type="S", language_settings=[setting], kwargs...)
end

function short_text_question(id, language_settings::Vector{LanguageSetting}; kwargs...)
    return Question(; id, type="S", language_settings, kwargs...)
end

function long_text_question(id, title::String; help=nothing, kwargs...)
    setting = language_setting(default_language(), title; help)
    return Question(; id, type="T", language_settings=[setting], kwargs...)
end

function long_text_question(id, language_settings::Vector{LanguageSetting}; kwargs...)
    return Question(; id, type="T", language_settings, kwargs...)
end

function huge_text_question(id, title::String; help=nothing, kwargs...)
    setting = language_setting(default_language(), title; help)
    return Question(; id, type="U", language_settings=[setting], kwargs...)
end

function huge_text_question(id, language_settings::Vector{LanguageSetting}; kwargs...)
    return Question(; id, type="U", language_settings, kwargs...)
end

function multiple_short_text_question(id, title::String; subquestions, help=nothing, kwargs...)
    setting = language_setting(default_language(), title; help)
    return Question(; id, type="Q", language_settings=[setting], subquestions, kwargs...)
end

function multiple_short_text_question(children::Function, id, title::String; help=nothing, kwargs...)
    setting = language_setting(default_language(), title; help)
    return Question(; id, type="Q", language_settings=[setting], subquestions=tovector(children()), kwargs...)
end

function multiple_short_text_question(id, language_settings::Vector{LanguageSetting}; subquestions, kwargs...)
    return Question(; id, type="Q", language_settings, subquestions, kwargs...)
end

# single choice questions
five_point_choice_question(; kwargs...) = Question(; type="5", kwargs...)

function dropdown_list_question(; options, kwargs...)
    return Question(; type="!", options, kwargs...)
end

function dropdown_list_question(children::Function; kwargs...)
    return Question(; type="!", options=tovector(children()), kwargs...)
end

function radio_list_question(; options, comment=false, kwargs...)
    question_type = comment ? "O" : "L"
    return Question(; type=question_type, options, kwargs...)
end

function radio_list_question(children::Function; comment=false, kwargs...)
    return radio_list_question(; options=tovector(children()), comment, kwargs...)
end

# multiple choice questions
function multiple_choice_question(; options, comments=false, kwargs...)
    question_type = comments ? "P" : "M"
    return Question(; type=question_type, options, kwargs...)
end

# array questions
function array_question(; subquestions, options, bycolumn=false, type="default", kwargs...)
    if (type != "default" && bycolumn)
        error("columnwise array question can only be of type 'default'")
    end

    if (type == "default" && !bycolumn)
        question_type = "F"
    elseif (type == "default" && bycolumn)
        question_type = "H"
    elseif (type == "dropdown")
        question_type = ":"
    elseif (type == "text")
        question_type = ";"
    else
        error("unknown question type")
    end

    return Question(; type=question_type, subquestions, options, kwargs...)
end

function array_question(children::Function; options, bycolumn=false, type="default", kwargs...)
    return array_question(; subquestions=tovector(children()), options, bycolumn, type, kwargs...)
end

function array_five_point_choice_question(; subquestions, kwargs...)
    return Question(; type="A", subquestions, kwargs...)
end

function array_five_point_choice_question(children::Function; kwargs...)
    return array_five_point_choice_question(; subquestions=tovector(children()), kwargs...)
end

function array_ten_point_choice_question(; subquestions, kwargs...)
    return Question(; type="B", subquestions, kwargs...)
end

function array_ten_point_choice_question(children::Function; kwargs...)
    return array_ten_point_choice_question(; subquestions=tovector(children()), kwargs...)
end

# yes/no/uncertain
# increase/same/decrease
#



# # mask questions
# abstract type AbstractMaskQuestion <: AbstractQuestion end

# struct DateSelect <: AbstractMaskQuestion
#     core::QuestionCore
#     minimum
#     maximum
#     type::String
#     month_style::String
# end

# function date_select(; minimum=nothing, maximum=nothing, type="default", month_style="default", kwargs...)
#     return DateSelect(
#         QuestionCore(; kwargs...),
#         minimum,
#         maximum,
#         type,
#         month_style
#     )
# end

# struct FileUpload <: AbstractMaskQuestion
#     core::QuestionCore
#     show_title::Bool
#     show_comment::Bool
#     max_filesize::Integer
#     min_files::Integer
#     max_files::Integer
#     allowed_filetypes::Union{AbstractString,Vector{<:AbstractString}}
#     function FileUpload(core, show_title, show_comment, max_filesize, min_files, max_files, allowed_filetypes)
#         min_files <= max_files || error("Maximum number of files must be greater than minimum number of files.")
#         max_filesize >= 0 || error("Maximum filesize must be non-negative.")
#         new(core, show_title, show_comment, max_filesize, min_files, max_files, allowed_filetypes)
#     end
# end

# function file_upload(; show_title=true, show_comment=true, max_filesize=10240, min_files=0, max_files=1, allowed_filetypes=["png", "gif", "doc", "odt", "jpg", "pdf", "png"], kwargs...)
#     return FileUpload(
#         QuestionCore(; kwargs...),
#         show_title,
#         show_comment,
#         max_filesize,
#         min_files,
#         max_files,
#         allowed_filetypes
#     )
# end

# struct GenderSelect <: AbstractMaskQuestion
#     core::QuestionCore
#     type::String
# end

# function gender_select(; type="button", kwargs...)
#     return GenderSelect(
#         QuestionCore(; kwargs...),
#         type
#     )
# end

# struct LanguageSwitch <: AbstractMaskQuestion
#     core::QuestionCore
# end

# language_switch(; kwargs...) = LanguageSwitch(QuestionCore(; kwargs...))

# struct NumericalInput <: AbstractMaskQuestion
#     core::QuestionCore
#     minimum::Union{Nothing,<:Real}
#     maximum::Union{Nothing,<:Real}
#     maximum_chars::Union{Nothing,Integer}
#     integer_only::Bool
#     function NumericalInput(core, minimum, maximum, maximum_chars, integer_only)
#         if integer_only
#             isnothing(minimum) || minimum isa Integer || error("Input is integer only, but minimum is not an integer.")
#             isnothing(maximum) || maximum isa Integer || error("Input is integer only, but maximum is not an integer.")
#         end
#         if !(isnothing(minimum) || isnothing(maximum))
#             minimum < maximum || error("Maximum value is not greater than minimum value.")
#         end
#         new(core, minimum, maximum, maximum_chars, integer_only)
#     end
# end

# function numerical_input(; minimum=nothing, maximum=nothing, maximum_chars=nothing, integer_only=false, kwargs...)
#     return NumericalInput(
#         QuestionCore(; kwargs...),
#         minimum,
#         maximum,
#         maximum_chars,
#         integer_only
#     )
# end

# struct MultipleNumericalInput <: AbstractMaskQuestion
#     core::QuestionCore
#     subquestions::Vector{SubQuestion}
#     minimum::Union{Nothing,<:Real}
#     maximum::Union{Nothing,<:Real}
#     maximum_chars::Union{Nothing,Integer}
#     minimum_sum::Union{Nothing,<:Real}
#     maximum_sum::Union{Nothing,<:Real}
#     integer_only::Bool
#     function MultipleNumericalInput(core, subquestions, minimum, maximum, maximum_chars, minimum_sum, maximum_sum, integer_only)
#         if integer_only
#             isnothing(minimum) || minimum isa Integer || error("Input is integer only, but minimum is not an integer.")
#             isnothing(maximum) || maximum isa Integer || error("Input is integer only, but maximum is not an integer.")
#             isnothing(minimum_sum) || minimum_sum isa Integer || error("Input is integer only, but minimum sum is not an integer.")
#             isnothing(maximum_sum) || maximum_sum isa Integer || error("Input is integer only, but maximum sum is not an integer.")
#         end
#         if !isnothing(minimum) && !isnothing(maximum)
#             minimum < maximum || error("Maximum value is not greater than minimum value.")
#         end
#         if !isnothing(minimum_sum) && !isnothing(maximum_sum)
#             minimum_sum < maximum_sum || error("Maximum sum is not greater than minimum sum.")
#         end
#         return new(core, subquestions, minimum, maximum, maximum_chars, minimum_sum, maximum_sum, integer_only)
#     end
# end

# function multiple_numerical_input(; subquestions=SubQuestion[], minimum=nothing, maximum=nothing, maximum_chars=nothing, minimum_sum=nothing, maximum_sum=nothing, integer_only=false, kwargs...)
#     return MultipleNumericalInput(
#         QuestionCore(; kwargs...),
#         subquestions,
#         minimum,
#         maximum,
#         maximum_chars,
#         minimum_sum,
#         maximum_sum,
#         integer_only
#     )
# end

# function multiple_numerical_input(children::Function; minimum=nothing, maximum=nothing, maximum_chars=nothing, minimum_sum=nothing, maximum_sum=nothing, integer_only=false, kwargs...)
#     return MultipleNumericalInput(
#         QuestionCore(; kwargs...),
#         tovector(children()),
#         minimum,
#         maximum,
#         maximum_chars,
#         minimum_sum,
#         maximum_sum,
#         integer_only
#     )
# end

# struct RankingQuestion <: AbstractMaskQuestion end

# struct AdvancedRankingQuestion <: AbstractMaskQuestion end

# struct TextDisplay <: AbstractMaskQuestion end

# struct YesNoQuestion <: AbstractMaskQuestion end

# struct Equation <: AbstractMaskQuestion end


