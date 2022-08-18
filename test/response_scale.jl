@testset "Response Scale Constructors" begin
    @testset "response options" begin
        option = response_option("a1", "response option")
        @test id(option) == option.id == "a1"
        @test title(option) == "response option"
        @test languages(option) == ["en"]
        @test default_language(option) == "en"
    end

    @testset "response scales" begin
        options = (response_option("a$i", "option $i") for i in 1:5)

        scale = response_scale(collect(options))
        @test length(scale.options) == length(options)
        @test title(scale) == ""

        for i in eachindex(scale.options)
            @test id(scale.options[i]) == "a$i"
            @test title(scale.options[i]) == "option $i"
        end

        scale = response_scale("some title") do
            options
        end

        @test length(scale.options) == length(options)
        @test title(scale) == "some title"
    end
end
