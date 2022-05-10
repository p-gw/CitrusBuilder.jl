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
        @test LimeSurveyBuilder.tovector((q, q2)) isa Vector{LimeSurveyBuilder.TextQuestion}
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

        @testset "do ... end syntax" begin
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
            @test id.(s.children) == 1:n
        end

        @testset "bang! syntax" begin
            s = survey(id=10000, title="")

            # question groups
            g1 = append!(s, question_group(id=1, title="first group"))
            g2 = append!(s, question_group(id=2, title="second group"))
            g3 = append!(s, question_group(id=3, title="third group"))

            @test length(s.children) == 3
            @test id.(s.children) == 1:3

            g4 = prepend!(s, question_group(id=4, title="prepended group"))

            @test length(s.children) == 4
            @test id.(s.children) == [4, 1, 2, 3]

            g5 = insert!(s, 2, question_group(id=5, title="inserted group"))

            @test length(s.children) == 5
            @test id.(s.children) == [4, 5, 1, 2, 3]

            # questions
            @test length(children(g1)) == 0

            append!(g1, short_text_question(code="q1", question="first question"))
            append!(g1, short_text_question(code="q2", question="second question"))

            @test length(children(g1)) == 2
            @test id.(children(g1)) == ["q1", "q2"]

            insert!(g1, 2, short_text_question(code="q3", question="inserted question"))

            @test length(children(g1)) == 3
            @test id.(children(g1)) == ["q1", "q3", "q2"]

            prepend!(g1, short_text_question(code="q4", question="prepended question"))

            @test length(children(g1)) == 4
            @test id.(children(g1)) == ["q4", "q1", "q3", "q2"]

            # check that other groups are not changed
            for g in [g2, g3, g4, g5]
                @test length(children(g)) == 0
            end
        end

        @testset "Response Scale Construction" begin
            # response options
            option = response_option(code="a123", option="test option")
            @test option.code == "a123"
            @test option.option == "test option"

            # response scales
            n = 7

            scale = response_scale(header="testheader") do
                (response_option(code="a$i", option="option $i") for i in 1:n)
            end

            @test length(scale.options) == n
            @test scale.header == "testheader"

            # convenience functions
            n = 11
            @test point_scale(n).header == ""
            @test length(point_scale(n).options) == n
            for (i, option) in enumerate(point_scale(n).options)
                @test option.code == "A$i"
                @test option.option == "$i"
            end
        end
    end
end
