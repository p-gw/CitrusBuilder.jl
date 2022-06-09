struct QuestionGroup <: AbstractSurveyComponent
    id::Int
    language_settings::Vector{LanguageSetting}
    children::Vector{Question}
end

function question_group(id, title::String; description=nothing, children=Question[])
    setting = language_setting(default_language(), title; description)
    return QuestionGroup(id, [setting], children)
end

function question_group(children::Function, id, title::String; description=nothing)
    question_group(id, title; description, children=tovector(children()))
end

function question_group(id, language_settings::Vector{LanguageSetting}; children=Question[])
    return QuestionGroup(id, language_settings, children)
end

function question_group(children::Function, id, language_settings::Vector{LanguageSetting})
    return question_group(id, language_settings, children=tovector(children()))
end
