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
    language_settings::LanguageSettings
    subquestions::Vector{SubQuestion} = SubQuestion[]
    options::Vector{ResponseScale} = ResponseScale[]
    function Question(id, type, mandatory, other, relevance, language_settings, subquestions, options)
        validate(id) || error("Question codes must start with a letter and may only contain alphanumeric characters.")
        return new(id, type, mandatory, other, relevance, language_settings, subquestions, options)
    end
end

is_mandatory(question::Question) = question.mandatory
has_other(question::Question) = question.other
has_subquestions(question::Question) = length(question.subquestions) > 0
has_response_options(question::Question) = length(question.options) > 0

# text questions
function short_text_question(id, language_settings::LanguageSettings; kwargs...)
    return Question(;
        id,
        type="S",
        language_settings=language_settings,
        kwargs...
    )
end

function short_text_question(id, title::String; help=nothing, default=nothing, kwargs...)
    settings = language_settings(default_language(), title; help, default)
    return short_text_question(id, settings; kwargs...)
end

function long_text_question(id, language_settings::LanguageSettings; kwargs...)
    return Question(;
        id,
        type="T",
        language_settings=language_settings,
        kwargs...
    )
end

function long_text_question(id, title::String; help=nothing, default=nothing, kwargs...)
    settings = language_settings(default_language(), title; help, default)
    return long_text_question(id, settings; kwargs...)
end

function huge_text_question(id, language_settings::LanguageSettings; kwargs...)
    return Question(;
        id,
        type="U",
        language_settings=language_settings,
        kwargs...
    )
end

function huge_text_question(id, title::String; help=nothing, default=nothing, kwargs...)
    settings = language_settings(default_language(), title; help, default)
    return huge_text_question(id, settings; kwargs...)
end

function multiple_short_text_question(id, language_settings::LanguageSettings; subquestions, kwargs...)
    return Question(;
        id,
        type="Q",
        language_settings=language_settings,
        subquestions=tovector(subquestions),
        kwargs...
    )
end

function multiple_short_text_question(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return multiple_short_text_question(id, settings; subquestions, kwargs...)
end

function multiple_short_text_question(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return multiple_short_text_question(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function multiple_short_text_question(children::Function, id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return multiple_short_text_question(id, settings; subquestions=tovector(children()), kwargs...)
end

# single choice questions
function five_point_choice_question(id, language_settings::LanguageSettings; kwargs...)
    return Question(;
        id,
        type="5",
        language_settings=language_settings,
        kwargs...
    )
end

function five_point_choice_question(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return five_point_choice_question(id, settings; kwargs...)
end

function dropdown_list_question(id, language_settings::LanguageSettings, options::ResponseScale; kwargs...)
    return Question(;
        id,
        type="!",
        language_settings=language_settings,
        options=tovector(options),
        kwargs...
    )
end

function dropdown_list_question(id, title::String, options::ResponseScale; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return dropdown_list_question(id, settings, options; kwargs...)
end

function radio_list_question(id, language_settings::LanguageSettings, options::ResponseScale; comment=false, kwargs...)
    return Question(;
        id,
        type=comment ? "O" : "L",
        language_settings=language_settings,
        options=tovector(options),
        kwargs...
    )
end

function radio_list_question(id, title::String, options::ResponseScale; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return radio_list_question(id, settings, options; kwargs...)
end

# multiple choice questions
function multiple_choice_question(id, language_settings::LanguageSettings; subquestions, comments=false, kwargs...)
    return Question(;
        id,
        type=comments ? "P" : "M",
        language_settings=language_settings,
        subquestions=tovector(subquestions),
        kwargs...
    )
end

function multiple_choice_question(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return multiple_choice_question(id, settings; subquestions, kwargs...)
end

function multiple_choice_question(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return multiple_choice_question(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function multiple_choice_question(children::Function, id, title::String; kwargs...)
    return multiple_choice_question(id, title; subquestions=tovector(children()), kwargs...)
end
