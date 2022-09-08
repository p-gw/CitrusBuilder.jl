using Dates
using CitrusBuilder
using Random
using Test
using EzXML

@testset "CitrusBuilder.jl" begin
    include("language_settings.jl")
    include("utils.jl")
    include("subquestion.jl")
    include("survey_component.jl")
    include("survey.jl")
    include("question.jl")
    include("question_group.jl")
    include("response_scale.jl")
    include("xml.jl")
end
