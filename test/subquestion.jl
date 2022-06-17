@testset "Subquestion Constructors" begin
    sq = subquestion("id", "title")
    @test sq.id == "id"
    @test sq.type == "T"
    @test sq.relevance == "1"
    @test first(sq.language_settings.settings).language == default_language()
    @test first(sq.language_settings.settings).title == "title"
    @test id(sq) == sq.id
    @test type(sq) == sq.type
    @test relevance(sq) == sq.relevance
    @test languages(sq) == [default_language()]
    @test default_language(sq) == default_language()
    @test title(sq) == first(sq.language_settings.settings).title
    @test title(sq, default_language()) == first(sq.language_settings.settings).title
    @test_throws ErrorException title(sq, "invalidlang")

    settings = language_settings([
        language_setting("en", "title"),
        language_setting("de", "Titel")
    ])

    sq = subquestion("id", settings)
    @test id(sq) == sq.id == "id"
    @test type(sq) == sq.type == "T"
    @test relevance(sq) == sq.relevance == "1"
    @test default_language(sq) == "en"
    @test languages(sq) == ["en", "de"]
    @test title(sq) == "title"
    @test title(sq, "en") == "title"
    @test title(sq, "de") == "Titel"

    sq = subquestion("id", "", checked=true)
    @test default(sq) == "Y"
    sq = subquestion("", "", checked=false)
    @test isnothing(default(sq))

    @test_throws ArgumentError subquestion("", "", checked=true, default="default")
end
