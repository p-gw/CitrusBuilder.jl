@kwdef mutable struct Survey <: AbstractSurveyComponent
    id::Int
    title::String
    description::String = ""
    languages::Vector{String} = ["en"]
    children::Vector{QuestionGroup} = QuestionGroup[]
end

survey(; kwargs...) = Survey(; kwargs...)
survey(children; kwargs...) = Survey(; kwargs..., children=tovector(children()))

title(s::Survey) = s.title
languages(s::Survey) = s.languages
language(s::Survey) = first(s.languages)

function Base.show(io::IO, s::Survey)
    groups = s.children
    n_groups = length(groups)

    n_questions = length(groups) > 0 ? sum(length(g.children) for g in groups) : 0
    println(io, "Survey with $n_groups groups and $n_questions questions.")
    println(io, "$(s.title) (id: $(s.id))")
    for (i, g) in enumerate(groups)
        p = prefix(i, n_groups)
        println(io, "$p $(g.title) (id: $(g.id))")

        for (j, q) in enumerate(g.children)
            p = prefix(j, length(g.children))
            println(io, "    $p $(question(q)) (code: $(id(q)))")

            if q isa ArrayQuestion
                for (k, sq) in enumerate(q.subquestions)
                    p = prefix(k, length(q.subquestions))
                    println(io, "        $p $(sq.subquestion) (code: $(sq.code))")
                end
            end
        end
    end
end
