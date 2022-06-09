@kwdef struct LanguageSettings
    language::String
    title::String
    description::Union{Nothing,String} = nothing
    welcome_text::Union{Nothing,String} = nothing
    end_text::Union{Nothing,String} = nothing
    url::Union{Nothing,String} = nothing
    url_description::Union{Nothing,String} = nothing
    decimal::Char = '.'
end

language_settings(; kwargs...) = LanguageSettings(; kwargs...)

@kwdef mutable struct Survey <: AbstractSurveyComponent
    id::Int
    language_settings::Vector{LanguageSettings}
    children::Vector{QuestionGroup} = QuestionGroup[]
end

function survey(; id::Int, title::String, children=QuestionGroup[], kwargs...)
    language = language_settings(; language=DEFAULT_LANGUAGE[], title, kwargs...)
    return Survey(; id, language_settings=[language], children)
end

survey(children; kwargs...) = survey(; kwargs..., children=tovector(children()))

function Base.show(io::IO, survey::Survey)
    groups = survey.children
    n_groups = length(groups)

    n_questions = length(groups) > 0 ? sum(length(group.children) for group in groups) : 0
    println(io, "Survey with $n_groups groups and $n_questions questions.")
    println(io, "$(title(survey)) (id: $(survey.id))")
    for (i, group) in enumerate(groups)
        p = prefix(i, n_groups)
        println(io, "$p $(group.title) (id: $(group.id))")

        for (j, question) in enumerate(group.children)
            p = prefix(j, length(group.children))
            println(io, "    $p $(question.question) (code: $(question.id)))")

            if question isa ArrayQuestion
                for (k, subquestion) in enumerate(question.subquestions)
                    p = prefix(k, length(question.subquestions))
                    println(io, "        $p $(subquestion.question) (code: $(subquestion.code))")
                end
            end
        end
    end
end
