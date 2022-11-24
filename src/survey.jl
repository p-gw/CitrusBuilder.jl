"""
    Survey <: AbstractSurveyComponent

A type to represent a LimeSurvey.

# Fields
- `id::Int`: A valid LimeSurvey survey id
- `language_settings::LanguageSettings`: The surveys language settings
- `children::Vector{QuestionGroup}`: A vector of question groups
- `settings::Dict{String,Any}`: Additional survey settings
"""
struct Survey <: AbstractSurveyComponent
    id::Int
    language_settings::LanguageSettings
    children::Vector{QuestionGroup}
    settings::Dict{String,Any}
    function Survey(id, language_setting, children, settings)
        isvalid_survey_id(id) || throw(ArgumentError("Survey id must be between 100000 and 999999"))
        new(id, language_setting, children, settings)
    end
end

isvalid_survey_id(id::Int) = 100_000 <= id <= 999_999

settings(survey::Survey) = survey.settings

"""
    survey(id, title::String; children, settings)

Construct a single-language [`Survey`](@ref).
`children` is an optional keyword argument and can be omitted.

# Examples
## Survey without children
```julia-repl
julia> s = survey(100000, "my survey")
Survey with 0 groups and 0 questions.
my survey (id: 100000)

```

## survey with children
```julia-repl
julia> s = survey(100000, "my survey", children = [
    question_group(1, "first question group"),
    question_group(2, "second question group")
])
Survey with 2 groups and 0 questions.
my survey (id: 100000)
├── first question group (id: 1)
└── second question group (id: 2)
```
"""
function survey(id, title::String; children=QuestionGroup[], settings=Dict{String,Any}())
    lsettings = language_settings(default_language(), title)
    return Survey(id, lsettings, children, settings)
end

"""
    survey(children::Function, id, title::String; settings)

Construct a single-language [`Survey`](@ref) using `do ... end` syntax.

# Examples
```julia-repl
julia> s = survey(100000, "my survey") do
    question_group(1, "first question group"),
    question_group(2, "second question group")
end
Survey with 2 groups and 0 questions.
my survey (id: 100000)
├── first question group (id: 1)
└── second question group (id: 2)

```
"""
function survey(children::Function, id, title::String; settings=Dict{String,Any}())
    return survey(id, title; children=tovector(children()), settings)
end

"""
    survey(id, language_settings::LanguageSettings; children, settings)

Construct a multi-language [`Survey`](@ref).
`children` is an optional keyword argument and can be omitted.

# Examples
## Survey without children
```julia-repl
julia> s = survey(100000, language_settings([
    language_setting("en", "A multi-language survey"),
    language_setting("de", "Eine mehrsprachige Umfrage")
]))
Survey with 0 groups and 0 questions.
A multi-language survey (id: 100000)
```

## Survey with children
```julia-repl
julia> s = survey(100000, language_settings([
    language_setting("en", "A multi-language survey"),
    language_setting("de", "Eine mehrsprachige Umfrage")
]), children = [question_group(1, language_settings([
    language_setting("en", "first question group"),
    language_setting("de", "Erste Fragengruppe")
]))])
Survey with 1 group and 0 questions.
A multi-language survey (id: 100000)
└── first question group (id: 1)
```
"""
function survey(id, language_settings::LanguageSettings; children=QuestionGroup[], settings=Dict{String,Any}())
    return Survey(id, language_settings, children, settings)
end

"""
    survey(children::Function, id, language_settings::LanguageSettings; settings)

Construct a multi-language [`Survey`](@ref) using `do ... end` syntax.

# Examples
```julia-repl
julia> s = survey(100000, language_settings([
    language_setting("en", "A multi-language survey"),
    language_setting("de", "Eine mehrsprachige Umfrage")
])) do
    question_group(1, language_settings([
        language_setting("en", "first question group"),
        language_setting("de", "Erste Fragengruppe")
    ]))
end
Survey with 1 group and 0 questions.
A multi-language survey (id: 100000)
└── first question group (id: 1)

```
"""
function survey(children::Function, id, language_settings::LanguageSettings; settings=Dict{String,Any}())
    return survey(id, language_settings; children=tovector(children()), settings)
end

function Base.show(io::IO, survey::Survey)
    groups = survey.children

    n_groups = length(groups)
    n_questions = length(groups) > 0 ? sum(length(group.children) for group in groups) : 0

    group_str = n_groups == 1 ? "group" : "groups"
    question_str = n_questions == 1 ? "question" : "questions"

    println(io, "Survey with $n_groups $group_str and $n_questions $question_str.")
    println(io, "$(title(survey)) (id: $(survey.id))")

    for (i, group) in enumerate(groups)
        p = prefix(i, n_groups)
        println(io, "$p $(title(group)) (id: $(group.id))")

        for (j, question) in enumerate(group.children)
            p = prefix(j, length(group.children))
            println(io, "    $p $(title(question)) (id: $(question.id))")
        end
    end
end
