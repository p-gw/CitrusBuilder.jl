"""
    ResponseOption
"""
@kwdef struct ResponseOption <: AbstractSurveyComponent
    id::String
    option::String
    default::Bool = false
    language::String = DEFAULT_LANGUAGE[]
    scale_id::Int = 0
end

isdefault(option::ResponseOption) = option.default

"""
    response_option(; code, option)

Construct a LimeSurvey Response Option.
"""
response_option(; kwargs...) = ResponseOption(; kwargs...)

struct ResponseScale
    header::AbstractString
    options::Vector{ResponseOption}
end

"""
    response_scale(; options::Vector{ResponseOption}, header::AbstractString)
    response_scale(children; header::AbstractString)

Construct a LimeSurvey Response Scale using one or multiple response options.

# Examples
```julia-repl
julia> options = [
    response_option(code="A1", option="1"),
    response_option(code="A2", option="2")
]
julia> response_scale(options=options, header="my response scale")

```
"""
response_scale(; options, header="") = ResponseScale(header, options)


"""
    response_scale(children; header::AbstractString)

Construct a LimeSurvey Response Scale using `do ... end` syntax for response options.

# Examples
```julia-repl
julia> response_scale(header="my response scale") do
    response_option(code="A1", option="1"),
    response_option(code="A2", option="2")
end
```
"""
function response_scale(options::Function; header="")
    return ResponseScale(header, tovector(options()))
end

"""
    point_scale(n::Integer)

Construct a `ResponseScale` ranging from `1` to `n`.

# Examples
julia> point_scale(3)
"""
function point_scale(n::Integer)
    options = [response_option(code="A$i", option="$i") for i in 1:n]
    scale = response_scale(options=options)
    return scale
end
