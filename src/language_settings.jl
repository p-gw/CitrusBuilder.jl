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

"""
    LanguageSetting

A type representing the settings of a survey component for a single language.

# Fields
- `language::String`: The definition of the locale
- `title::title`: The title of the survey component in the language
- `help::Union{Nothing, String}`: The help text of the survey component in the language
- `description::Union{Nothing, String}`: The description of the survey component in the language
- `default::Union{Nothing, String}`: The default value of the survey component in the language
"""
struct LanguageSetting
    language::String
    title::String
    help::Union{Nothing,String}
    description::Union{Nothing,String}
    default::Union{Nothing,String}
end

"""
    LanguageSettings

A type representing a collection of single [`LanguageSetting`](@ref).

# Fields
- `settings::Vector{LanguageSetting}`: A collection of language settings.
- `same_default::Bool`: An indicator whether or not the same default value is used for all languages.
"""
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

"""
    language_setting(language, title; kwargs...)

Construct a `LanguageSetting` for a survey component.

# Arguments
- `language`: A language code. For a list of all available languages see https://translate.limesurvey.org/languages/
- `title`: The title of the survey component

# Keyword arguments
- `description`: A description of the survey component
- `help`: A help text that is displayed for the survey component (questions only)
- `default`: The default value of the survey component (questions only)

# Examples
```julia
language_setting("en", "title")
language_setting("en", "question title", help="some help for survey participants")
```
"""
function language_setting(language, title; help=nothing, description=nothing, default=nothing)
    return LanguageSetting(language, title, help, description, default)
end

function find_language_setting(language::String, component::AbstractSurveyComponent)
    language_id = findfirst(x -> x.language == language, component.language_settings.settings)
    isnothing(language_id) && error("Invalid language")
    return component.language_settings.settings[language_id]
end
