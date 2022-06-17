struct ResponseOption <: AbstractSurveyComponent
    id::String
    language_settings::LanguageSettings
end

function response_option(id, title::String)
    settings = language_settings(default_language(), title)
    return ResponseOption(id, settings)
end

function response_option(id, language_settings::LanguageSettings) end

struct ResponseScale <: AbstractSurveyComponent
    options::Vector{ResponseOption}
    language_settings::LanguageSettings
end

function response_scale(options::VectorOrElement{ResponseOption}; default=nothing, same_default=false)
    settings = language_settings(default_language(), ""; default, same_default)
    return ResponseScale(tovector(options), settings)
end

function response_scale(options::Function; kwargs...)
    return response_scale(tovector(options()); kwargs...)
end

function default(scale::ResponseScale, language::String=default_language())
    setting = find_language_setting(language, scale)
    isnothing(setting.default) && return nothing
    default_id = findfirst(x -> id(x) == setting.default, scale.options)
    default_value = scale.options[default_id].id
    return default_value
end
