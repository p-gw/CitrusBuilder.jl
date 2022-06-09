using Dates
using LimeSurveyBuilder
using Random
using Test

@testset "LimeSurveyBuilder.jl" begin
    include("utils.jl")
    include("subquestion.jl")
    # include("survey_component.jl")
    # include("survey.jl")
    include("question.jl")
    include("question_group.jl")
end
