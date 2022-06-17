using Dates
using LimeSurveyBuilder
using Random
using Test
using EzXML

@testset "LimeSurveyBuilder.jl" begin
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
