
    #     @testset "Response Scale Construction" begin
    #         # response options
    #         option = response_option(code="a123", option="test option")
    #         @test option.code == "a123"
    #         @test option.option == "test option"

    #         # response scales
    #         n = 7

    #         scale = response_scale(header="testheader") do
    #             (response_option(code="a$i", option="option $i") for i in 1:n)
    #         end

    #         @test length(scale.options) == n
    #         @test scale.header == "testheader"

    #         # convenience functions
    #         n = 11
    #         @test point_scale(n).header == ""
    #         @test length(point_scale(n).options) == n
    #         for (i, option) in enumerate(point_scale(n).options)
    #             @test option.code == "A$i"
    #             @test option.option == "$i"
    #         end
    #     end
    # end
