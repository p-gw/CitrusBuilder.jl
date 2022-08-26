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

"""
    question_group(id, title::String; description, children)

Construct a single-language question group.
Both `description` and `children` are optional keyword arguments that can be omitted.

# Examples
```julia-repl
julia> g = question_group(1, "a question group")
```

```julia-repl
julia> g = question_group(1, "a question group"; description="A simple description")
```

```julia-repl
julia> questions = [short_text_question("q\$i", "question \$i") for i in 1:3]
julia> g = question_group(1, "a question group"; children=questions)
```
"""
function question_group(id, title::String; description=nothing, children=Question[])
    settings = language_settings(default_language(), title; description)
    return QuestionGroup(id, settings, children)
end

"""
    question_group(children::Function, id, title::String; description)

Construct a single-language question group using `do...end` syntax.
`description` is an optional keyword argument that can be omitted.

# Examples
```julia-repl
julia> g = question_group(1, "a question group") do
    short_text_question("q1", "first question")
end
```
"""
function question_group(children::Function, id, title::String; description=nothing)
    question_group(id, title; description, children=tovector(children()))
end

"""
    question_group(id, language_settings::LanguageSettings; children)

Construct a multi-language question group.
`children` is an optional keywird argument that can be omitted.

# Examples
```julia-repl
julia> g = question_group(1, language_settings([
    language_setting("de", "Eine Fragengruppe"),
    language_setting("en", "A question group")
]))
```
"""
function question_group(id, language_settings::LanguageSettings; children=Question[])
    return QuestionGroup(id, language_settings, children)
end

"""
    question_group(children::Function, id, language_settings::LanguageSettings)

Construct a multi-language question group using `do...end` syntax.

# Examples
```julia-repl
julia> g = question_group(1, language_settings([
    language_setting("de", "Eine Fragengruppe"),
    language_setting("en", "A question group")
])) do
    short_text_question("q1", language_settings([
        language_setting("de", "Eine Frage")
        language_setting("en", "A question")
    ]))
end
```
"""
function question_group(children::Function, id, language_settings::LanguageSettings)
    return question_group(id, language_settings, children=tovector(children()))
end
