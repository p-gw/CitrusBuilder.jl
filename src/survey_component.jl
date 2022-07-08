"""
    AbstractSurveyComponent

An abstract type that represents a component within a LimeSurvey survey.
"""
abstract type AbstractSurveyComponent end

"""
    id(component::AbstractSurveyComponent)

Return the `id` of a survey component.

# Examples
```julia-repl
julia> q = short_text_question("q1", "title")
julia> id(q)
"q1"
```
"""
id(component::AbstractSurveyComponent) = component.id

"""
    languages(component::AbstractSurveyComponent)

Return a vector of languages of a survey component.

# Examples
For components with a single language

```julia-repl
julia> s = survey(100000, "survey title")
julia> languages(s)
["en"]
```

For multi-language components
```julia-repl
julia> q = short_text_question("q1", language_settings([
    language_setting("en", "title"),
    language_setting("de", "Titel")
]))
julia> languages(q)
["en", "de"]
```
"""
languages(component::AbstractSurveyComponent) = getfield.(component.language_settings.settings, :language)

"""
    default_language(component::AbstractSurveyComponent)

Return the default language of a survey component.
The default language is defined as the first language of the component.

# Examples
```julia-repl
julia> g = question_group(1, "group title")
julia> default_language(g)
"en"
```

!!! note
    The default language of a survey component is not necessarily equal to the global
    default language set by [`set_default_language!`](@ref).

```julia-repl
julia> default_language()
"en"
julia> g = question_group(1, language_settings([
    language_setting("de", "Gruppentitel"),
    language_settings("en", "group title")
]))
julia> default_language(g)
"de"
```
"""
default_language(component::AbstractSurveyComponent) = first(component.language_settings.settings).language

"""
    same_default(component::AbstractSurveyComponent)

Return if the survey component uses the same default value for all languages.

# Examples
```julia-repl
julia> q = short_text_question("q1", "title", default="some default value")
julia> same_default(q)
false
```

```julia-repl
julia> q = short_text_question("q1", language_settings([
    language_setting("en", "title", default="some default value"),
    language_setting("de", "Titel")
], same_default=true))
julia> same_default(q)
true
```
"""
same_default(component::AbstractSurveyComponent) = component.language_settings.same_default

"""
    default(component::AbstractSurveyComponent, language::String)

Return the default value of a survey component.
If `language` is provided the default value for the default language of the component is returned.

# Examples
```julia-repl
julia> q = short_text_question("q1", language_settings([
    language_setting("en", "title", default="placeholder"),
    language_setting("de", "Titel", default="Platzhalter")
]))
julia> default(q)
"placeholder"
julia> default(q, "en")
"placeholder"
julia> default(q, "de")
"Platzhalter"
```
"""
function default(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.default
end

"""
    has_default(component::AbstractSurveyComponent, language::String)

Return whether or not a survey component has a default value for a given language.
If `language` is not provided the default value for the default language of the component is returned.

# Examples
```julia-repl
julia> q = short_text_question("q1", "title")
julia> has_default(q)
false
```

```julia-repl
julia> q = short_text_question("q2", "title", default="placeholder")
julia> has_default(q)
true
```
"""
function has_default(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return !isnothing(setting.default)
end

"""
    title(component::AbstractSurveyComponent, language::String)

Return the title of the a survey component for a given language.
If `language` is not provided the title for the default language of the component is returned.

# Examples
```julia-repl
julia> g = question_group(1, "my title")
julia> title(g)
"my title"
```

```julia-repl
julia> g = question_group(1, language_settings([
    language_setting("en", "my title"),
    language_setting("de", "Mein Titel")
]))
julia> title(g, "en")
"my title"
julia> title(g, "de")
"Mein Titel"
```
"""
function title(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.title
end

"""
    help(component::AbstractSurveyComponent, language::String)

Return the help string of a survey component for a given language.
If `language` is not provided the help for the default language of the component is returned.

# Examples
```julia-repl
julia> q = short_text_question("q1", "my question", help="some help")
julia> help(q)
"some help"
```
"""
function help(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.help
end

"""
    has_help(component::AbstractSurveyComponent, language::String)

Return whether or not the survey component has a `help` string for a given language.
If `language` is not provided the value for the default language of the component is returned.

# Examples
```julia-repl
julia> q = short_text_question("q1", "title")
julia> has_help(q)
false

julia> q = short_text_question("q2", "title", help="some help")
julia> has_help(q)
true
```
"""
function has_help(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return !isnothing(setting.help)
end

"""
    description(component::AbstractSurveyComponent, language::String)

Returns the description of a survey component for a given language.
If `language` is not provided the description for the default language of the component is returned.

# Examples
```julia-repl
julia> q = short_text_question("q1", "title", description="answer this question")
julia> description(q)
"answer this question"

julia> q = short_text_question("q2", language_settings([
    language_setting("en", "some description"),
    language_setting("de", "Eine Beschreibung")
]))
julia> description(q)
"some description"

julia> description(q, "de")
"Eine Beschreibung"
```
"""
function description(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.description
end

"""
    has_description(component::AbstractSurveyComponent, language::String)

Returns whether or not the survey component has a description for a given `language`.
If `language` is not provided the value for the default language of the component is returned.

# Examples
```julia-repl
julia> q = short_text_question("q1", "title")
julia> has_description(q)
false

julia> q = short_text_question("q2", "title", description="some description")
julia> has_description(q)
true
```
"""
function has_description(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return !isnothing(setting.description)
end

children(x::AbstractSurveyComponent) = x.children

"""
    prepend!(component::AbstractSurveyComponent, item)

Insert one or multiple items to the beginning of `component`'s children.
Returns the prepended `item`.

# Examples
```julia-repl
julia> s = survey(100000, "my survey")
julia> prepend!(s, question_group(1, "first question group"))
```

```julia-repl
julia> g = question_group(1, "a question group")
julia> qs = [
    gender_select("q1", "A gender select"),
    short_text_question("q2", "Please state your full name.")
]
julia> prepend!(g, qs)
```
"""
function Base.prepend!(component::AbstractSurveyComponent, item)
    prepend!(children(component), tovector(item))
    return item
end

"""
    append!(component::AbstractSurveyComponent, item)

Insert one or multiple items to the end of `component`'s children.
Returns the appended `item`.

# Examples
```julia-repl
julia> s = survey(100000, "my survey")
julia> append!(s, question_group(1, "a question group"))
```

```julia-repl
julia> s = survey(100000, "my survey")
julia> append!(s, [
    question_group(1, "first question group"),
    question_group(2, "second question group")
])
```
"""
function Base.append!(component::AbstractSurveyComponent, item)
    append!(children(component), tovector(item))
    return item
end

"""
    insert!(component::AbstractSurveyComponent, index::Integer, item)

Insert one or multiple items into `component`'s children at the given `index`.
Returns the appended `item`.

# Examples
```julia-repl
julia> s = survey(100000, "my survey") do
    question_group(1, "first question group"),
    question_group(2, "second question group")
end
julia> insert!(s, 2, question_group(3, "between first and second question group"))
julia> s
Survey with 3 groups and 0 questions.
my survey (id: 100000)
├── first question group (id: 1)
├── between first and second question group (id: 3)
└── second question group (id: 2)
```
"""
function Base.insert!(component::AbstractSurveyComponent, index::Integer, item)
    insert!(children(component), index, item)
    return item
end

"""
    AbstractQuestion <: AbstractSurveyComponent

An abstract type representing a question within a LimeSurvey.

"""
abstract type AbstractQuestion <: AbstractSurveyComponent end

type(q::AbstractQuestion) = q.type
