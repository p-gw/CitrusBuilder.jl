using LimeSurveyBuilder
using Random
using Test

@testset "LimeSurveyBuilder.jl" begin
    @testset "Question Code Validation" begin
        # numeric inputs
        for x in string.(rand(1:999999, 10))
            @test LimeSurveyBuilder.isnumber(x[rand(1:length(x))]) == true
            @test LimeSurveyBuilder.isalphanumeric(x[rand(1:length(x))]) == true
            @test LimeSurveyBuilder.validate(x) == false
        end

        # letter input
        letters = vcat('a':'z', 'A':'Z')

        for _ in 1:10
            x = randstring(letters, 10)
            @test LimeSurveyBuilder.isnumber(x[rand(1:length(x))]) == false
            @test LimeSurveyBuilder.isalphanumeric(x[rand(1:length(x))]) == true
            @test LimeSurveyBuilder.validate(x) == true
        end

        # Leading number
        for _ in 1:10
            x = string(rand(1:9)) * randstring(12)
            @test LimeSurveyBuilder.validate(x) == false
        end

        # valid
        for _ in 1:10
            x = randstring(letters, 1) * randstring(11)
            @test LimeSurveyBuilder.validate(x) == true
        end

        # special characters
        @test LimeSurveyBuilder.validate("Adf?c_") == false
        @test LimeSurveyBuilder.validate(" a1") == false
    end

    @testset "Vector conversion" begin
        g = question_group(id=1, title="", description="")
        @test LimeSurveyBuilder.tovector(g) isa Vector{typeof(g)}
        @test length(LimeSurveyBuilder.tovector(g)) == 1

        n = rand(1:15)
        @test length(LimeSurveyBuilder.tovector(g for _ in 1:n)) == n

        q = short_text_question(code="q1")
        @test LimeSurveyBuilder.tovector(q) isa Vector{typeof(q)}
        @test length(LimeSurveyBuilder.tovector(q)) == 1
        @test length(LimeSurveyBuilder.tovector(q for _ in 1:n)) == n

        q2 = long_text_question(code="q2")
        @test LimeSurveyBuilder.tovector((q, q2)) isa Vector{LimeSurveyBuilder.AbstractTextQuestion}
    end

    @testset "QuestionGroup Constructors" begin
        g = question_group(id=1, title="", description="")
        @test g.id == 1
        @test g.title == ""
        @test g.description == ""
        @test g.children == LimeSurveyBuilder.AbstractQuestion[]

        g = question_group(id=1, title="", description="") do
            short_text_question(code="q1")
        end
        @test length(g.children) == 1

        n = rand(1:10)
        g = question_group(id=1, title="", description="") do
            (short_text_question(code="q$i") for i in 1:n)
        end
        @test length(g.children) == n

        # check if order is preserved
        for i in 1:n
            @test code(g.children[i]) == "q$i"
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
