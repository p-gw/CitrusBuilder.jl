@testset "Question Group Constructors" begin
    @test_throws MethodError question_group("g1", "title")
    @test_throws ArgumentError question_group(-1, "title")
    @test_throws ArgumentError question_group(0, "title")

    g = question_group(1, "", description="")
    @test id(g) == 1
    @test title(g) == ""
    @test title(g, "en") == ""
    @test_throws ErrorException title(g, "de")
    @test description(g) == ""
    @test description(g, "en") == ""
    @test_throws ErrorException description(g, "de")
    @test children(g) == CitrusBuilder.Question[]

    g = question_group(1, "", description="") do
        short_text_question("q1", "title")
    end
    @test length(g.children) == 1

    n = rand(1:10)
    g = question_group(1, "", description="") do
        (short_text_question("q$i", "title $i") for i in 1:n)
    end
    @test length(children(g)) == n

    # check if order is preserved
    for (i, q) in enumerate(children(g))
        @test id(q) == "q$i"
        @test title(q) == "title $i"
    end
end
