struct ResponseOption <: AbstractSurveyComponent
    id::String
    language_settings::Vector{LanguageSetting}
    default::Bool
end

is_default(option::ResponseOption) = option.default

function response_option(id, title::String; default=false)
    setting = language_setting(default_language(), title)
    return ResponseOption(id, [setting], default)
end

struct ResponseScale <: AbstractSurveyComponent
    options::Vector{ResponseOption}
end

response_scale(options::Vector{ResponseOption}) = ResponseScale(options)
response_scale(options::Function) = ResponseScale(tovector(options()))
