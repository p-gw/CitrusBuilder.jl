isnumber(c::AbstractChar) = !isnothing(tryparse(Int, string(c)))
isalphanumeric(c::AbstractChar) = isletter(c) || isnumber(c)
validate(code::AbstractString) = isletter(first(code)) && all(isalphanumeric, code)

prefix(i, n) = i == n ? "└──" : "├──"

function tovector(child::T)::Vector{T} where {T}
    return T[child]
end

function tovector(children::Vector{T})::Vector{T} where {T}
    return T[child for child in children]
end

function tovector(children::Tuple{Vararg{T}})::Vector{T} where {T}
    return T[child for child in children]
end

function tovector(children::Base.Generator)
    return collect(children)
end

tovector(::Nothing) = return []

function find_language_setting(language::String, component::AbstractSurveyComponent)
    language_id = findfirst(x -> x.language == language, component.language_settings)
    isnothing(language_id) && error("Invalid language")
    return component.language_settings[language_id]
end
