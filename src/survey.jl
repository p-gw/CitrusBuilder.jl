struct Survey <: AbstractSurveyComponent
    id::Int
    language_settings::LanguageSettings
    children::Vector{QuestionGroup}
end

function survey(id, title::String; children=QuestionGroup[])
    settings = language_settings(default_language(), title)
    return Survey(id, settings, children)
end

function survey(children::Function, id, title::String; kwargs...)
    return survey(id, title; children=tovector(children()))
end

function survey(id, language_settings::LanguageSettings; children=QuestionGroup[])
    return Survey(id, language_settings, children)
end

function survey(children::Function, id, language_settings::LanguageSettings)
    return survey(id, language_settings, children=tovector(children()))
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
