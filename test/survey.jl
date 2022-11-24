@testset "Survey Constructors" begin
    @testset "survey id validation" begin
        @test survey(rand(100000:999999), "valid survey") isa CitrusBuilder.Survey
        @test_throws ArgumentError survey(1, "invalid survey")
        @test_throws ArgumentError survey(1_000_000, "invalid survey")
    end

    @testset "empty surveys" begin
        s = survey(100000, "empty survey")
        @test s.id == 100000
        @test languages(s) == ["en"]
        @test default_language(s) == "en"
        @test s.children == CitrusBuilder.QuestionGroup[]

        settings = language_settings([
            language_setting("en", "survey title"),
            language_setting("de", "Umfragetitel")
        ])

        s = survey(100001, settings)
        @test s.id == 100001
        @test languages(s) == ["en", "de"]
        @test default_language(s) == "en"
        @test s.children == CitrusBuilder.QuestionGroup[]
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

        settings = language_settings([
            language_setting("de", "Umfragetitel")
        ])

        s = survey(100003, settings) do
            question_group(1, "qg1")
        end

        @test default_language(s) == "de"
        @test languages(s) == ["de"]
        @test length(s.children) == 1
        @test id(first(s.children)) == 1
        @test title(first(s.children)) == "qg1"

    end

    @testset "bang! function construction" begin
        s = survey(100004, "title")

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

    @testset "show()" begin
        s = survey(123456, "survey title")
        show_str = sprint(show, s)
        split_show_str = split(show_str, "\n")
        @test split_show_str[1] == "Survey with 0 groups and 0 questions."
        @test split_show_str[2] == "survey title (id: 123456)"

        s = survey(111111, "survey title") do
            question_group(1, "group 1"),
            question_group(2, "group 2")
        end
        show_str = sprint(show, s)
        split_show_str = split(show_str, "\n")

        @test split_show_str[1] == "Survey with 2 groups and 0 questions."
        @test split_show_str[2] == "survey title (id: 111111)"
        @test endswith(split_show_str[3], "group 1 (id: 1)")
        @test endswith(split_show_str[4], "group 2 (id: 2)")

        s = survey(100000, "survey title") do
            question_group(1, "group 1") do
                short_text_question("q1", "question 1")
            end
        end
        show_str = sprint(show, s)
        split_show_str = split(show_str, "\n")

        @test split_show_str[1] == "Survey with 1 group and 1 question."
        @test split_show_str[2] == "survey title (id: 100000)"
        @test endswith(split_show_str[3], "group 1 (id: 1)")
        @test endswith(split_show_str[4], "question 1 (id: q1)")
    end
end
