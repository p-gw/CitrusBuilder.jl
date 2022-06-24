const DEFAULT_LANGUAGE = Ref("en")

"""
    default_language()

Get the currently set LimeSurvey default language (default: "en").
If no explicit language is provided when constructing `Survey`, `QuestionGroup` or `Question`
the survey components will inherit the default language.

# See also
To set the default language use [`set_default_language!`](@ref)
"""
default_language() = DEFAULT_LANGUAGE[]

"""
    set_default_language!(lang::String)

Set `DEFAULT_LANGUAGE` of LimeSurvey.

# Examples
```julia
set_default_language!("de")
[ Info: LimeSurvey default language set to 'de'.
```

# See also
To get the current value of `DEFAULT_LANGUAGE` see [`default_language`](@ref)
"""
function set_default_language!(lang::String)
    @info "LimeSurvey default language set to '$(lang)'."
    DEFAULT_LANGUAGE[] = lang
    return nothing
end

struct LanguageSetting
    language::String
    title::String
    help::Union{Nothing,String}
    description::Union{Nothing,String}
    default::Union{Nothing,String}
end

struct LanguageSettings
    settings::Vector{LanguageSetting}
    same_default::Bool
end

"""
    language_settings(settings; same_default=false)
    language_settings(language, title; same_default=false, kwargs...)

Construct `LanguageSettings` for a survey component.
Settings for single can either be provided as `settings::Vector{LanguageSetting}` (see also
[`language_setting`](@ref)) or a combination of `language` and `title`.

If multiple languages are provided and `same_default=true` then the `default` value of the
default language is inherited by all other languages.

# Examples
Simple construction of language settings for a single language:
```julia
language_settings("de", "Ein Titel")
```

If multiple languages are needed, construct settings using a vector of [`language_setting`](@ref)
```julia
language_settings([
    language_setting("en", "A title"),
    language_setting("de", "Ein Titel")
])
```

To inherit the `default` value of the default language, `same_default` can be used
```julia
language_settings([
    language_setting("en", "title", default="placeholder value"),
    language_setting("de", "Titel")
], same_default=true)
```
"""
function language_settings(settings::VectorOrElement{LanguageSetting}; same_default=false)
    return LanguageSettings(tovector(settings), same_default)
end

function language_settings(language, title; same_default=false, kwargs...)
    return language_settings(language_setting(language, title; kwargs...); same_default)
end

function language_setting(language, title; help=nothing, description=nothing, default=nothing)
    return LanguageSetting(language, title, help, description, default)
end

function find_language_setting(language::String, component::AbstractSurveyComponent)
    language_id = findfirst(x -> x.language == language, component.language_settings.settings)
    isnothing(language_id) && error("Invalid language")
    return component.language_settings.settings[language_id]
end
