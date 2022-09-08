@testset "Language settings" begin
    @testset "Global language settings" begin
        @test default_language() == "en"
        @test default_language() == CitrusBuilder.DEFAULT_LANGUAGE[]

        set_default_language!("de")
        @test default_language() == "de"
        @test default_language() == CitrusBuilder.DEFAULT_LANGUAGE[]

        # reset
        set_default_language!("en")
    end

    @testset "language_setting" begin
        ls = language_setting("en", "title")
        @test ls.language == "en"
        @test ls.title == "title"
        @test isnothing(ls.help)
        @test isnothing(ls.description)
        @test isnothing(ls.default)

        ls = language_setting("", "", help="help", description="desc", default="a")
        @test ls.help == "help"
        @test ls.description == "desc"
        @test ls.default == "a"
    end

    @testset "language_settings" begin
        ls = language_settings([
            language_setting("de", "Titel"),
            language_setting("en", "title")
        ])

        @test length(ls.settings) == 2
        @test ls.settings[1].title == "Titel"
        @test ls.settings[2].title == "title"
        @test ls.settings[1].language == "de"
        @test ls.settings[2].language == "en"
        @test ls.same_default == false

        ls = language_settings("de", "Titel", same_default=true)
        @test ls.same_default == true
        @test length(ls.settings) == 1
        @test first(ls.settings).title == "Titel"
        @test first(ls.settings).language == "de"
    end

    @testset "find_language_setting" begin
        s = survey(100000, language_settings([
            language_setting("de", "Titel"),
            language_setting("en", "title")
        ]))

        setting_de = CitrusBuilder.find_language_setting("de", s)
        setting_en = CitrusBuilder.find_language_setting("en", s)
        @test setting_de.language == "de"
        @test setting_de.title == "Titel"
        @test setting_en.language == "en"
        @test setting_en.title == "title"
        @test_throws ErrorException CitrusBuilder.find_language_setting("asd", s)
    end
end
