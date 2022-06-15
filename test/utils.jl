@testset "Utility functions" begin
    @testset "Global settings" begin
        @test default_language() == "en"
        @test default_language() == LimeSurveyBuilder.DEFAULT_LANGUAGE[]

        set_default_language!("de")
        @test default_language() == "de"
        @test default_language() == LimeSurveyBuilder.DEFAULT_LANGUAGE[]

        # reset
        set_default_language!("en")
    end

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

    @testset "tovector" begin
        # single child
        inputs = ['a', 1, "string", question_group(1, ""), short_text_question("q1", "")]

        for input in inputs
            res = LimeSurveyBuilder.tovector(input)
            @test res isa Vector
            @test eltype(res) == typeof(input)
            @test length(res) == 1
        end

        # Vector of children
        children = [1, 2, 3, 4]
        res = LimeSurveyBuilder.tovector(children)
        @test res == children

        # Tuple
        children = ("a", "b", "c", "d")
        res = LimeSurveyBuilder.tovector(children)
        @test res isa Vector
        @test length(res) == length(children)
        @test eltype(res) == String
        @test res == ["a", "b", "c", "d"]

        # Generator
        n = 5
        children = (randstring(10) for _ in 1:n)
        res = LimeSurveyBuilder.tovector(children)
        @test res isa Vector
        @test length(res) == n
        @test eltype(res) == String
    end

    @testset "find_language_setting" begin
        s = survey(100000, [
            language_setting("de", "Titel"),
            language_setting("en", "title")
        ])

        setting_de = LimeSurveyBuilder.find_language_setting("de", s)
        setting_en = LimeSurveyBuilder.find_language_setting("en", s)
        @test setting_de.language == "de"
        @test setting_de.title == "Titel"
        @test setting_en.language == "en"
        @test setting_en.title == "title"
        @test_throws ErrorException LimeSurveyBuilder.find_language_setting("asd", s)
    end
end
