"""
    QuestionGroup <: AbstractSurveyComponent

A type representing a question group within a LimeSurvey

# Fields
- `id::Int`: An integer-valued ID for the question group
- `language_settings::LanguageSettings`: The language settings for the question group
- `children::Vector{Question}`: A vector of questions as child elements of the question group
"""
struct QuestionGroup <: AbstractSurveyComponent
    id::Int
    language_settings::LanguageSettings
    children::Vector{Question}
end

function question_group(id, title::String; description=nothing, children=Question[])
    settings = language_settings(default_language(), title; description)
    return QuestionGroup(id, settings, children)
end

function question_group(children::Function, id, title::String; description=nothing)
    question_group(id, title; description, children=tovector(children()))
end

function question_group(id, language_settings::LanguageSettings; children=Question[])
    return QuestionGroup(id, language_settings, children)
end

function question_group(children::Function, id, language_settings::LanguageSettings)
    return question_group(id, language_settings, children=tovector(children()))
end
