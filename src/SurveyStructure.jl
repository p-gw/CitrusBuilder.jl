abstract type AbstractSurveyComponent end
abstract type AbstractQuestion <: AbstractSurveyComponent end

id(x::AbstractSurveyComponent) = x.id
children(x::AbstractSurveyComponent) = x.children

id(x::AbstractQuestion) = x.core.code
code(x::AbstractQuestion) = x.core.code
question(x::AbstractQuestion) = x.core.question

@kwdef mutable struct QuestionCore
    code::AbstractString
    question::AbstractString = ""
    help::AbstractString = ""
    function QuestionCore(code, question, help)
        validate(code) || error("Question codes must start with a letter and may only contain alphanumeric characters.")
        return new(code, question, help)
    end
end

isnumber(c::AbstractChar) = !isnothing(tryparse(Int, string(c)))
isalphanumeric(c::AbstractChar) = isletter(c) || isnumber(c)
validate(code::AbstractString) = isletter(first(code)) && all(isalphanumeric, code)

@kwdef mutable struct QuestionGroup <: AbstractSurveyComponent
    id::Integer
    # text elements
    title::AbstractString
    description::AbstractString = ""
    children::Vector{AbstractQuestion} = AbstractQuestion[]
end

question_group(; kwargs...) = QuestionGroup(; kwargs...)
question_group(children::Function; kwargs...) = QuestionGroup(; kwargs..., children=tovector(children()))


function tovector(child::T)::Vector{T} where {T<:AbstractSurveyComponent}
    return [child]
end

function tovector(children)::Vector{<:AbstractSurveyComponent}
    return [child for child in children]
end

tovector(::Nothing) = return AbstractQuestion[]

@kwdef mutable struct Survey
    # general settings
    id::Integer
    # text elements
    title::AbstractString
    description::AbstractString = ""
    # children
    children::Vector{QuestionGroup} = QuestionGroup[]
end

survey(; kwargs...) = Survey(; kwargs...)
survey(children; kwargs...) = Survey(; kwargs..., children=tovector(children()))

prefix(i, n) = i == n ? "└──" : "├──"

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
            println(io, "    $p $(question(q)) (code: $(code(q)))")

            if q isa ArrayQuestion
                for (k, sq) in enumerate(q.subquestions)
                    p = prefix(k, length(q.subquestions))
                    println(io, "        $p $(sq.subquestion) (code: $(sq.code))")
                end
            end
        end
    end
end



function Base.prepend!(c::Union{Survey,QuestionGroup}, item)
    prepend!(c.children, tovector(item))
    return item
end

function Base.append!(c::Union{Survey,QuestionGroup}, item)
    append!(c.children, tovector(item))
    return item
end

function Base.insert!(c::Union{Survey,QuestionGroup}, i::Integer, item)
    insert!(c.children, i, item)
    return item
end
