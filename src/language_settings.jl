const DEFAULT_LANGUAGE = Ref("en")

function set_default_language!(lang::String)
    @info "LimeSurvey default language set to '$(lang)'."
    DEFAULT_LANGUAGE[] = lang
    return nothing
end

default_language() = DEFAULT_LANGUAGE[]

struct LanguageSetting
    language::String
    title::String
    help::Union{Nothing,String}
    description::Union{Nothing,String}
    default::Union{Nothing,String}
end

function language_setting(language, title; help=nothing, description=nothing, default=nothing)
    return LanguageSetting(language, title, help, description, default)
end

struct LanguageSettings
    settings::Vector{LanguageSetting}
    same_default::Bool
end

function language_settings(settings::VectorOrElement{LanguageSetting}; same_default=false)
    return LanguageSettings(tovector(settings), same_default)
end

function language_settings(language, title; same_default=false, kwargs...)
    return language_settings(language_setting(language, title; kwargs...); same_default)
end

function find_language_setting(language::String, component::AbstractSurveyComponent)
    language_id = findfirst(x -> x.language == language, component.language_settings.settings)
    isnothing(language_id) && error("Invalid language")
    return component.language_settings.settings[language_id]
end
