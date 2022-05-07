using LimeSurveyBuilder
using Test

@testset "LimeSurveyBuilder.jl" begin
    @testset "Vector conversion" begin
        g = question_group(id=1, title="", description="")
        @test LimeSurveyBuilder.tovector(g) isa Vector{typeof(g)}
        @test length(LimeSurveyBuilder.tovector(g)) == 1

        n = rand(1:15)
        @test length(LimeSurveyBuilder.tovector(g for _ in 1:n)) == n

        q = LimeSurveyBuilder.Question(code="a1", question="", help="")
        @test LimeSurveyBuilder.tovector(q) isa Vector{typeof(q)}
        @test length(LimeSurveyBuilder.tovector(q)) == 1
        @test length(LimeSurveyBuilder.tovector(q for _ in 1:n)) == n
    end

    @testset "QuestionGroup Constructors" begin
        g = question_group(id=1, title="", description="")
        @test g.id == 1
        @test g.title == ""
        @test g.description == ""
        @test g.children == LimeSurveyBuilder.Question[]

        g = question_group(id=1, title="", description="") do
            LimeSurveyBuilder.Question(code="q1", question="", help="")
        end
        @test length(g.children) == 1

        n = rand(1:10)
        g = question_group(id=1, title="", description="") do
            (LimeSurveyBuilder.Question(code="q$i", question="", help="") for i in 1:n)
        end
        @test length(g.children) == n

        # check if order is preserved
        for i in 1:n
            @test g.children[i].code == "q$i"
        end
    end

    @testset "Survey Constructors" begin
        s = survey(id=123456, title="testsurvey")
        @test s.id == 123456
        @test s.title == "testsurvey"
        @test s.description == ""
        @test s.children == LimeSurveyBuilder.QuestionGroup[]

        # only question groups
        s = survey(id=123123, title="", description="") do
            LimeSurveyBuilder.QuestionGroup(id=1, title="", description="")
        end
        @test length(s.children) == 1

        n = rand(1:10)
        s = survey(id=123123, title="", description="") do
            (LimeSurveyBuilder.QuestionGroup(id=i, title="", description="") for i in 1:n)
        end
        @test length(s.children) == n

        # check if order is preserved
        for i in 1:n
            @test s.children[i].id == i
        end
    end
end
