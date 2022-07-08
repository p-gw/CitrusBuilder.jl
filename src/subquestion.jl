"""
    SubQuestion

A type representing subquestions of a LimeSurvey question.

# Fields
- `id::String`: An alphanumeric question id. Must start with a letter.
- `question::String`: The subquestion title.
- `type::String`: The LimeSurvey qusetion type
- `relevance::String`: A LimeSurvey Expression Script
"""
struct SubQuestion <: AbstractQuestion
    id::String
    type::String
    relevance::String
    language_settings::LanguageSettings
    scale_id::Int
    # TODO: validate id
end

"""
    subquestion(; id, language_settings, relevance = "1")

Construct a multi-language subquestion.
"""
function subquestion(id::String, language_settings::LanguageSettings; relevance="1", scale_id=0)
    return SubQuestion(id, "T", relevance, language_settings, scale_id)
end

"""
    subquestion(; id, title, relevance = "1")

Construct a subquestion using the default survey language.
"""
function subquestion(id::String, title::String; default=nothing, checked=false, relevance="1", scale_id=0)
    if checked
        isnothing(default) || throw(ArgumentError("Arguments 'default' and 'checked' are incompatible"))
        default = "Y"
    end

    settings = language_settings(default_language(), title; default)
    return subquestion(id, settings; relevance, scale_id)
end

type(q::SubQuestion) = q.type
relevance(q::SubQuestion) = q.relevance
