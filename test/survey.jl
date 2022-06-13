@testset "Survey Constructors" begin
    @testset "empty surveys" begin
        s = survey(100000, "empty survey")
        @test s.id == 100000
        @test languages(s) == ["en"]
        @test default_language(s) == "en"
        @test s.children == LimeSurveyBuilder.QuestionGroup[]

        language_settings = [
            language_setting("en", "survey title"),
            language_setting("de", "Umfragetitel")
        ]
        s = survey(100001, language_settings)
        @test s.id == 100001
        @test languages(s) == ["en", "de"]
        @test default_language(s) == "en"
        @test s.children == LimeSurveyBuilder.QuestionGroup[]
    end

    @testset "do ... end construction" begin
        s = survey(100002, "title") do
            question_group(1, "qg1"),
            question_group(2, "qg2")
        end

        @test length(s.children) == 2
        for i in eachindex(s.children)
            @test id(s.children[i]) == i
            @test title(s.children[i]) == "qg$i"
        end
    end

    @testset "bang! function construction" begin
        s = survey(100003, "title")

        append!(s, question_group(2, "qg2"))
        append!(s, question_group(4, "qg4"))
        prepend!(s, question_group(1, "qg1"))
        insert!(s, 3, question_group(3, "qg3"))

        @test length(s.children) == 4
        for i in eachindex(s.children)
            @test id(s.children[i]) == i
            @test title(s.children[i]) == "qg$i"
        end
    end
end
