struct Survey <: AbstractSurveyComponent
    id::Int
    language_settings::Vector{LanguageSetting}
    children::Vector{QuestionGroup}
end

function survey(id, title::String; children=QuestionGroup[])
    language = language_setting(default_language(), title)
    return Survey(id, [language], children)
end

function survey(children::Function, id, title::String; kwargs...)
    return survey(id, title; children=tovector(children()))
end

function survey(id, language_settings::Vector{LanguageSetting}; children=QuestionGroup[])
    return Survey(id, language_settings, children)
end

function survey(children::Function, id, language_settings::Vector{LanguageSetting})
    return survey(id, language_settings, children=tovector(children()))
end

function Base.show(io::IO, survey::Survey)
    groups = survey.children
    n_groups = length(groups)

    n_questions = length(groups) > 0 ? sum(length(group.children) for group in groups) : 0
    println(io, "Survey with $n_groups groups and $n_questions questions.")
    println(io, "$(title(survey)) (id: $(survey.id))")
    for (i, group) in enumerate(groups)
        p = prefix(i, n_groups)
        println(io, "$p $(title(group)) (id: $(group.id))")

        for (j, question) in enumerate(group.children)
            p = prefix(j, length(group.children))
            println(io, "    $p $(title(question)) (code: $(question.id)))")

            # if question isa ArrayQuestion
            #     for (k, subquestion) in enumerate(question.subquestions)
            #         p = prefix(k, length(question.subquestions))
            #         println(io, "        $p $(subquestion.question) (code: $(subquestion.code))")
            #     end
            # end
        end
    end
end
