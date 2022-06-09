    # @testset "Survey Constructors" begin
    #     s = survey(id=123456, title="testsurvey")
    #     @test s.id == 123456
    #     @test s.title == "testsurvey"
    #     @test s.description == ""
    #     @test s.children == LimeSurveyBuilder.QuestionGroup[]

    #     @testset "do ... end syntax" begin
    #         # only question groups
    #         s = survey(id=123123, title="", description="") do
    #             LimeSurveyBuilder.QuestionGroup(id=1, title="", description="")
    #         end
    #         @test length(s.children) == 1

    #         n = rand(1:10)
    #         s = survey(id=123123, title="", description="") do
    #             (LimeSurveyBuilder.QuestionGroup(id=i, title="", description="") for i in 1:n)
    #         end
    #         @test length(s.children) == n
    #         @test id.(s.children) == 1:n
    #     end

    #     @testset "bang! syntax" begin
    #         s = survey(id=10000, title="")

    #         # question groups
    #         g1 = append!(s, question_group(id=1, title="first group"))
    #         g2 = append!(s, question_group(id=2, title="second group"))
    #         g3 = append!(s, question_group(id=3, title="third group"))

    #         @test length(s.children) == 3
    #         @test id.(s.children) == 1:3

    #         g4 = prepend!(s, question_group(id=4, title="prepended group"))

    #         @test length(s.children) == 4
    #         @test id.(s.children) == [4, 1, 2, 3]

    #         g5 = insert!(s, 2, question_group(id=5, title="inserted group"))

    #         @test length(s.children) == 5
    #         @test id.(s.children) == [4, 5, 1, 2, 3]

    #         # questions
    #         @test length(children(g1)) == 0

    #         append!(g1, short_text_question(code="q1", question="first question"))
    #         append!(g1, short_text_question(code="q2", question="second question"))

    #         @test length(children(g1)) == 2
    #         @test id.(children(g1)) == ["q1", "q2"]

    #         insert!(g1, 2, short_text_question(code="q3", question="inserted question"))

    #         @test length(children(g1)) == 3
    #         @test id.(children(g1)) == ["q1", "q3", "q2"]

    #         prepend!(g1, short_text_question(code="q4", question="prepended question"))

    #         @test length(children(g1)) == 4
    #         @test id.(children(g1)) == ["q4", "q1", "q3", "q2"]

    #         # check that other groups are not changed
    #         for g in [g2, g3, g4, g5]
    #             @test length(children(g)) == 0
    #         end
    #     end
