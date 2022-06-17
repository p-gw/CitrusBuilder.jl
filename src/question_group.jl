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
