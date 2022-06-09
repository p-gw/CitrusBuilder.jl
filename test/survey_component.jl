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
