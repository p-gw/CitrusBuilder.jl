@testset "Survey components" begin
    @testset "Accessor functions" begin
        struct TestComponent <: LimeSurveyBuilder.AbstractSurveyComponent
            id::Int
            language_settings::Vector{LimeSurveyBuilder.LanguageSetting}
        end

        component = TestComponent(1, [
            language_setting("de", "Titel", description="Eine Beschreibung", help="Hilfetext"),
            language_setting("en", "title")
        ])

        @test id(component) == 1
        @test languages(component) == ["de", "en"]
        @test default_language(component) == "de"

        @test title(component, "de") == "Titel"
        @test help(component, "de") == help(component) == "Hilfetext"
        @test has_help(component, "de") == has_help(component) == true
        @test description(component, "de") == description(component) == "Eine Beschreibung"
        @test has_description(component, "de") == has_description(component) == true

        @test title(component, "en") == "title"
        @test help(component, "en") === nothing
        @test has_help(component, "en") == false
        @test description(component, "en") === nothing
        @test has_description(component, "en") == false
    end
end
