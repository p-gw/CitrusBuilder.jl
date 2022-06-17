@testset "Response Scale Constructors" begin
    @testset "response options" begin
        option = response_option("a1", "response option")
        @test id(option) == option.id == "a1"
        @test title(option) == "response option"
        @test languages(option) == ["en"]
        @test default_language(option) == "en"
    end

    @testset "response scales" begin
        n = 5

        scale = response_scale() do
            (response_option("a$i", "option $i") for i in 1:n)
        end

        @test length(scale.options) == n

        for i in eachindex(scale.options)
            @test id(scale.options[i]) == "a$i"
            @test title(scale.options[i]) == "option $i"
        end
    end
end
