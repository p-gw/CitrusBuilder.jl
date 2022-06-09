
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
