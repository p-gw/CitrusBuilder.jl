@testset "Question Constructors" begin
    @testset "Text questions" begin
        settings = language_settings([
            language_setting("de", "Titel", help="Hilfetext"),
            language_setting("en", "title", help="help text")
        ])

        # simple text questions
        question_type = [
            (short_text_question, "S"),
            (long_text_question, "T"),
            (huge_text_question, "U")
        ]

        for (question_type, ls_type) in question_type
            q = question_type("id1", "title")
            @test type(q) == q.type == ls_type
            @test id(q) == q.id == "id1"
            @test is_mandatory(q) == q.mandatory == false
            @test has_other(q) == q.other == false
            @test has_subquestions(q) == false
            @test has_response_options(q) == false
            @test default_language(q) == "en"
            @test languages(q) == ["en"]
            @test title(q) == "title"
            @test title(q, "en") == "title"
            @test_throws ErrorException title(q, "de")


            q = short_text_question("id2", settings, mandatory=true)
            @test type(q) == "S"
            @test id(q) == "id2"
            @test is_mandatory(q) == true
            @test has_subquestions(q) == false
            @test has_response_options(q) == false
            @test default_language(q) == "de"
            @test languages(q) == ["de", "en"]
            @test title(q) == "Titel"
            @test title(q, "de") == "Titel"
            @test title(q, "en") == "title"
            @test help(q) == "Hilfetext"
            @test help(q, "de") == "Hilfetext"
            @test help(q, "en") == "help text"
        end

        # multiple short text question
        q = multiple_short_text_question("id3", "multiple short texts"; subquestions=[subquestion("sq1", "subquestion title")])
        @test type(q) == "Q"
        @test id(q) == "id3"
        @test title(q) == "multiple short texts"
        @test help(q) === nothing
        @test_throws ErrorException title(q, "de")
        @test length(q.subquestions) == 1
        @test title(first(q.subquestions)) == "subquestion title"
        @test has_subquestions(q) == true
        @test has_response_options(q) == false

        q = multiple_short_text_question("id4", "mst2"; help="answer 3 subquestions") do
            subquestion("sq1", "title 1"),
            subquestion("sq2", "title 2"),
            subquestion("sq3", "title 3")
        end

        @test help(q) == "answer 3 subquestions"
        @test has_subquestions(q) == true
        @test length(q.subquestions) == 3
        for (i, sq) in enumerate(q.subquestions)
            @test id(sq) == "sq$i"
            @test title(sq) == "title $i"
        end

        q = multiple_short_text_question("id5", settings; subquestions=[subquestion("sq1", "title 1")])
        @test has_subquestions(q) == true
        @test length(q.subquestions) == 1
        @test languages(q) == ["de", "en"]
    end

    @testset "Single Choice Questions" begin
        @testset "five_point_choice_question" begin
            q = five_point_choice_question("q1", "question", help="rate from 1 to 5")
            @test type(q) == "5"
            @test id(q) == "q1"
            @test title(q) == "question"
            @test help(q) == "rate from 1 to 5"
            @test_throws ErrorException title(q, "de")
            @test has_subquestions(q) == false
            @test has_response_options(q) == false

            q = five_point_choice_question("q2", language_settings([
                language_setting("de", "Frage"),
                language_setting("en", "question", help="some help")
            ]))

            @test type(q) == "5"
            @test id(q) == "q2"
            @test title(q) == title(q, "de") == "Frage"
            @test title(q, "en") == "question"
            @test has_help(q) == has_help(q, "de") == false
            @test has_help(q, "en") == true
        end

        @testset "dropdown_list_question" begin
            scale = response_scale([
                response_option("a1", "first option"),
                response_option("a2", "second option")
            ])

            q = dropdown_list_question("q1", "dropdown question", scale)
            @test type(q) == "!"
            @test id(q) == "q1"
            @test title(q) == "dropdown question"
            @test length(q.options) == 1

            q = dropdown_list_question("q2", language_settings([
                    language_setting("de", "Auswahlliste"),
                    language_setting("en", "dropdown list")
                ]), scale)

            @test type(q) == "!"
            @test id(q) == "q2"
            @test title(q) == title(q, "de") == "Auswahlliste"
            @test title(q, "en") == "dropdown list"
        end

        @testset "radio_list_question" begin
            scale = response_scale([
                response_option("a1", "first option"),
                response_option("a2", "second option")
            ])

            q = radio_list_question("q1", "radio", scale)
            @test type(q) == "L"
            @test id(q) == "q1"
            @test title(q) == "radio"

            q = radio_list_question("q2", "radio", scale; comment=true, help="help")
            @test type(q) == "O"
            @test help(q) == "help"

            q = radio_list_question("q3", language_settings("de", "Titel"), scale)
            @test title(q) == title(q, "de") == "Titel"
        end
    end

    @testset "Multiple choice questions" begin
        @testset "multiple_choice_question" begin
            q = multiple_choice_question("q1", "mcq") do
                subquestion("", "")
            end
            @test type(q) == "M"
            @test id(q) == "q1"
            @test title(q) == "mcq"
            @test has_subquestions(q) == true
            @test length(q.subquestions) == 1
            @test has_response_options(q) == false

            q = multiple_choice_question("q2", "mcq", comments=true, help="help") do
                subquestion("", ""),
                subquestion("", "")
            end

            @test type(q) == "P"
            @test id(q) == "q2"
            @test has_subquestions(q) == true
            @test length(q.subquestions) == 2
            @test has_help(q) == true
            @test help(q) == "help"

            q = multiple_choice_question("q3", language_settings([
                    language_setting("en", "title"),
                    language_setting("de", "Titel", help="Hilfetext")
                ]), subquestions=[subquestion("", "")])

            @test languages(q) == ["en", "de"]
            @test default_language(q) == "en"
            @test has_subquestions(q) == true
            @test length(q.subquestions) == 1
            @test title(q) == "title"
            @test title(q, "de") == "Titel"
            @test has_help(q) == false
            @test has_help(q, "de") == true
            @test isnothing(help(q))
            @test help(q, "de") == "Hilfetext"
        end
    end
    @testset "Array questions" begin
        @testset "fixed scale types" begin
            question_types = [
                (array_five_point_choice_question, "A"),
                (array_ten_point_choice_question, "B"),
                (array_yes_no_question, "C"),
                (array_increase_decrease_question, "E")
            ]

            for (f, question_type) in question_types
                q = f("q1", language_settings("de", ""), subquestions=[
                    subquestion("sq1", ""),
                    subquestion("sq2", "")
                ])

                @test id(q) == "q1"
                @test type(q) == question_type
                @test has_subquestions(q) == true
                @test has_response_options(q) == false
                @test length(q.subquestions) == 2

                q = f("q2", "", subquestions=[subquestion("sq1", "")])
                @test id(q) == "q2"
                @test type(q) == question_type
                @test has_subquestions(q) == true
                @test has_response_options(q) == false
                @test length(q.subquestions) == 1

                q = f("q3", language_settings("en", "")) do
                    (subquestion("sq$i", "subquestion $i") for i in 1:4)
                end
                @test id(q) == "q3"
                @test type(q) == question_type
                @test has_subquestions(q) == true
                @test length(q.subquestions) == 4

                q = f("q4", "", mandatory=true) do
                    (subquestion("sq$i", "subquestion $i") for i in 1:4)
                end
                @test id(q) == "q4"
                @test type(q) == question_type
                @test has_subquestions(q) == true
                @test length(q.subquestions) == 4
                @test is_mandatory(q) == true
            end
        end

        @testset "custom scale types" begin
            # question type inference
            valid_types = [
                ("default", "F"),
                ("text", ";"),
                ("dropdown", ":"),
                ("dual", "1"),
                ("bycolumn", "H")
            ]

            for (type, lstype) in valid_types
                @test LimeSurveyBuilder.array_question_type(type) == lstype
            end
            @test_throws ErrorException LimeSurveyBuilder.array_question_type("unknown")
            @test_throws ErrorException LimeSurveyBuilder.array_question_type(1)

            # single scale array questions
            scale = response_scale([
                response_option("o1", "option 1"),
                response_option("o2", "option 2"),
                response_option("o3", "option 3")
            ])

            make_subquestions(n) = (subquestion("sq$i", "subquestion $i") for i in 1:n)

            q = array_question("q1", "title", scale) do
                make_subquestions(3)
            end
            @test type(q) == "F"
            @test title(q) == "title"
            @test has_response_options(q) == true
            @test has_subquestions(q) == true
            @test length(q.subquestions) == 3
            @test length(q.options) == 1

            q = array_question("q2", "title", scale; type="default") do
                make_subquestions(2)
            end
            @test type(q) == "F"

            @test_throws ErrorException array_question("q3", "title", [scale, scale]) do
                make_subquestions(5)
            end

            q = array_question("q4", "", scale; type="bycolumn") do
                make_subquestions(1)
            end
            @test type(q) == "H"

            q = array_question("q5", "", [scale, scale], type="dual") do
                make_subquestions(10)
            end
            @test type(q) == "1"
            @test length(q.options) == 2

            @test_throws ErrorException array_question("q6", "", scale, type="dual") do
                make_subquestions(1)
            end
        end
    end
end