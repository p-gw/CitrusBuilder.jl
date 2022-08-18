struct QuestionAttribute
    attribute::String
    language::Union{Nothing,String}
    value
end

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
    attributes::Vector{QuestionAttribute} = QuestionAttribute[]
    language_settings::LanguageSettings
    subquestions::Vector{SubQuestion} = SubQuestion[]
    options::Vector{ResponseScale} = ResponseScale[]
    function Question(id, type, mandatory, other, relevance, attributes, language_settings, subquestions, options)
        validate(id) || error("Question codes must start with a letter and may only contain alphanumeric characters.")
        return new(id, type, mandatory, other, relevance, attributes, language_settings, subquestions, options)
    end
end

is_mandatory(question::Question) = question.mandatory
has_other(question::Question) = question.other
has_subquestions(question::Question) = length(question.subquestions) > 0
has_response_options(question::Question) = length(question.options) > 0
has_attributes(question::Question) = length(question.attributes) > 0
attributes(question::Question) = question.attributes

function add_attribute!(question::Question, attribute::QuestionAttribute)
    push!(question.attributes, attribute)
    return nothing
end

function add_attribute!(question::Question, kv::Pair{String,T}) where {T}
    key, value = collect(kv)

    if isnothing(value)
        return nothing
    end

    attribute = QuestionAttribute(key, nothing, value)
    add_attribute!(question, attribute)
end

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

# array questions
function array_five_point_choice_question(id, language_settings::LanguageSettings; subquestions, kwargs...)
    return Question(;
        id,
        language_settings,
        type="A",
        subquestions=tovector(subquestions),
        kwargs...
    )
end

function array_five_point_choice_question(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return array_five_point_choice_question(id, settings; subquestions, kwargs...)
end

function array_five_point_choice_question(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return array_five_point_choice_question(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function array_five_point_choice_question(children::Function, id, title::String; kwargs...)
    return array_five_point_choice_question(id, title; subquestions=tovector(children()), kwargs...)
end

function array_ten_point_choice_question(id, language_settings::LanguageSettings; subquestions, kwargs...)
    return Question(;
        id,
        language_settings,
        type="B",
        subquestions=tovector(subquestions),
        kwargs...
    )
end

function array_ten_point_choice_question(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return array_ten_point_choice_question(id, settings; subquestions, kwargs...)
end

function array_ten_point_choice_question(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return array_ten_point_choice_question(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function array_ten_point_choice_question(children::Function, id, title::String; kwargs...)
    return array_ten_point_choice_question(id, title; subquestions=tovector(children()), kwargs...)
end

function array_yes_no_question(id, language_settings::LanguageSettings; subquestions, kwargs...)
    return Question(;
        id,
        language_settings,
        type="C",
        subquestions=tovector(subquestions),
        kwargs...
    )
end

function array_yes_no_question(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return array_yes_no_question(id, settings; subquestions, kwargs...)
end

function array_yes_no_question(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return array_yes_no_question(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function array_yes_no_question(children::Function, id, title::String; kwargs...)
    return array_yes_no_question(id, title; subquestions=tovector(children()), kwargs...)
end

function array_increase_decrease_question(id, language_settings::LanguageSettings; subquestions, kwargs...)
    return Question(;
        id,
        language_settings,
        type="E",
        subquestions=tovector(subquestions),
        kwargs...
    )
end

function array_increase_decrease_question(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return array_increase_decrease_question(id, settings; subquestions, kwargs...)
end

function array_increase_decrease_question(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return array_increase_decrease_question(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function array_increase_decrease_question(children::Function, id, title::String; kwargs...)
    return array_increase_decrease_question(id, title; subquestions=tovector(children()), kwargs...)
end

function array_question_type(type)
    if type == "default"
        ls_type = "F"
    elseif type == "text"
        ls_type = ";"
    elseif type == "dropdown"
        ls_type = ":"
    elseif type == "dual"
        ls_type = "1"
    elseif type == "bycolumn"
        ls_type = "H"
    else
        error("Unknown array question type")
    end
    return ls_type
end

function array_question(id, language_settings::LanguageSettings, options::VectorOrElement{ResponseScale}; subquestions, type="default", kwargs...)
    options_vec = tovector(options)
    n_scales = length(options_vec)

    question_type = array_question_type(type)

    if type == "dual" && n_scales != 2
        error("Dual scale array questions must have 2 response scales")
    end

    if type != "dual" && n_scales != 1
        error("Single scale array questions must have 1 response scale")
    end

    question = Question(;
        id,
        language_settings,
        type=question_type,
        subquestions=tovector(subquestions),
        options=options_vec,
        kwargs...
    )

    # scale headers are only defined for dual-scale array questions
    if type == "dual"
        for (i, scale) in enumerate(options_vec)
            for lang in languages(scale)
                attribute_name = "dualscale_header" * ["A", "B"][i]
                attribute = QuestionAttribute(attribute_name, lang, title(scale, lang))
                add_attribute!(question, attribute)
            end
        end
    end

    return question
end

function array_question(id, title::String, options::VectorOrElement{ResponseScale}; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return array_question(id, settings, options; kwargs...)
end

function array_question(children::Function, id, language_settings::LanguageSettings, options; kwargs...)
    return array_question(id, language_settings, options; subquestions=tovector(children()), kwargs...)
end

function array_question(children::Function, id, title::String, options; kwargs...)
    return array_question(id, title, options; subquestions=tovector(children()), kwargs...)
end

# mask questions
function date_select(id, language_settings::LanguageSettings; minimum=nothing, maximum=nothing, kwargs...)
    question = Question(;
        id,
        language_settings,
        type="D",
        kwargs...
    )

    add_attribute!(question, "date_min" => minimum)
    add_attribute!(question, "date_max" => maximum)

    return question
end

function date_select(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return date_select(id, settings; kwargs...)
end

function file_upload(id, language_settings::LanguageSettings; kwargs...)
    return Question(; id, language_settings, type="|", kwargs...)
end

function file_upload(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return file_upload(id, settings; kwargs...)
end

function gender_select(id, language_settings::LanguageSettings; kwargs...)
    return Question(; id, language_settings, type="G", kwargs...)
end

function gender_select(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return gender_select(id, settings; kwargs...)
end

function language_switch(id, language_settings::LanguageSettings; kwargs...)
    return Question(; id, type="I", language_settings, kwargs...)
end

function language_switch(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return language_switch(id, settings; kwargs...)
end

function numerical_input(id, language_settings::LanguageSettings; minimum=nothing, maximum=nothing, integer_only=false, kwargs...)
    question = Question(; id, language_settings, type="N", kwargs...)
    add_attribute!(question, "min_num_value_n" => minimum)
    add_attribute!(question, "max_num_value_n" => maximum)
    if integer_only
        add_attribute!(question, "num_value_int_only" => "1")
    end
    return question
end

function numerical_input(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return numerical_input(id, settings; kwargs...)
end

function multiple_numerical_input(id, language_settings::LanguageSettings; subquestions, kwargs...)
    return Question(; id, language_settings, subquestions=tovector(subquestions), type="K", kwargs...)
end

function multiple_numerical_input(id, title::String; subquestions, help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return multiple_numerical_input(id, settings; subquestions, kwargs...)
end

function multiple_numerical_input(children::Function, id, language_settings::LanguageSettings; kwargs...)
    return multiple_numerical_input(id, language_settings; subquestions=tovector(children()), kwargs...)
end

function multiple_numerical_input(children::Function, id, title::String; kwargs...)
    return multiple_numerical_input(id, title; subquestions=tovector(children()), kwargs...)
end

function ranking(id, language_settings::LanguageSettings, options::ResponseScale; kwargs...)
    return Question(; id, language_settings, type="R", options=tovector(options), kwargs...)
end

function ranking(id, title::String, options::ResponseScale; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return ranking(id, settings, options; kwargs...)
end

function text_display(id, language_settings::LanguageSettings; kwargs...)
    return Question(; id, language_settings, type="X", kwargs...)
end

function text_display(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return text_display(id, settings; kwargs...)
end

function yes_no_question(id, language_settings::LanguageSettings; kwargs...)
    return Question(; id, language_settings, type="Y", kwargs...)
end

function yes_no_question(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return yes_no_question(id, settings; kwargs...)
end

function equation(id, language_settings::LanguageSettings; kwargs...)
    return Question(; id, language_settings, type="*", kwargs...)
end

function equation(id, title::String; help=nothing, kwargs...)
    settings = language_settings(default_language(), title; help)
    return equation(id, settings; kwargs...)
end
