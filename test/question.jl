
@testset "Question Constructors" begin
    @testset "Text questions" begin
        language_settings = [
            language_setting("de", "Titel", help="Hilfetext"),
            language_setting("en", "title", help="help text")
        ]

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
            @test default_language(q) == "en"
            @test languages(q) == ["en"]
            @test title(q) == "title"
            @test title(q, "en") == "title"
            @test_throws ErrorException title(q, "de")


            q = short_text_question("id2", language_settings, mandatory=true)
            @test type(q) == "S"
            @test id(q) == "id2"
            @test is_mandatory(q) == true
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

        q = multiple_short_text_question("id4", "mst2"; help="answer 3 subquestions") do
            subquestion("sq1", "title 1"),
            subquestion("sq2", "title 2"),
            subquestion("sq3", "title 3")
        end

        @test help(q) == "answer 3 subquestions"
        @test length(q.subquestions) == 3
        for (i, sq) in enumerate(q.subquestions)
            @test id(sq) == "sq$i"
            @test title(sq) == "title $i"
        end

        q = multiple_short_text_question("id5", language_settings; subquestions=[subquestion("sq1", "title 1")])
        @test length(q.subquestions) == 1
        @test languages(q) == ["de", "en"]
    end

    #     @testset "Mask Questions" begin
    #         @testset "Date Select" begin
    #             # check defaults
    #             ds = date_select(code="q1")
    #             @test isnothing(ds.minimum)
    #             @test isnothing(ds.maximum)
    #             @test ds.type == "default"
    #             @test ds.month_style == "default"

    #             ds = date_select(
    #                 code="q1",
    #                 minimum=Date(1900, 1, 1),
    #                 maximum=today(),
    #                 type="radio",
    #                 month_style="long"
    #             )
    #             @test ds.minimum == Date(1900, 1, 1)
    #             @test ds.maximum == today()
    #             @test ds.type == "radio"
    #             @test ds.month_style == "long"
    #         end
    #         @testset "File Upload" begin
    #             f = file_upload(code="q1")
    #             @test f.show_title == true
    #             @test f.show_comment == true
    #             @test f.max_filesize == 10240
    #             @test f.min_files == 0
    #             @test f.max_files == 1
    #             @test f.allowed_filetypes == ["png", "gif", "doc", "odt", "jpg", "pdf", "png"]

    #             f = file_upload(
    #                 code="q1",
    #                 show_title=false,
    #                 show_comment=false,
    #                 max_filesize=100,
    #                 min_files=10,
    #                 max_files=20,
    #                 allowed_filetypes="jpg"
    #             )
    #             @test f.show_title == false
    #             @test f.show_comment == false
    #             @test f.max_filesize == 100
    #             @test f.min_files == 10
    #             @test f.max_files == 20
    #             @test f.allowed_filetypes == "jpg"

    #             @test_throws ErrorException file_upload(code="q1", max_files=1, min_files=10)
    #             @test_throws ErrorException file_upload(code="q1", max_filesize=-10)
    #         end

    #         @testset "Gender Select" begin
    #             g = gender_select(code="q1")
    #             @test g.type == "button"

    #             g = gender_select(code="q1", type="radio")
    #             @test g.type == "radio"
    #         end

    #         @testset "Numerical Inputs" begin
    #             # # single
    #             n = numerical_input(code="q1")
    #             @test isnothing(n.minimum) == true
    #             @test isnothing(n.maximum) == true
    #             @test isnothing(n.maximum_chars) == true
    #             @test n.integer_only == false

    #             n = numerical_input(
    #                 code="q1",
    #                 minimum=0,
    #                 maximum=120,
    #                 maximum_chars=20,
    #                 integer_only=true
    #             )
    #             @test n.minimum == 0
    #             @test n.maximum == 120
    #             @test n.maximum_chars == 20
    #             @test n.integer_only == true

    #             @test_throws ErrorException numerical_input(code="q1", minimum=0.0, maximum=10.0, integer_only=true)
    #             @test_throws ErrorException numerical_input(code="q1", minimum=10, maximum=0)

    #             # multiple
    #             n = multiple_numerical_input(code="q1") do
    #                 subquestion(code="sq1", subquestion=""),
    #                 subquestion(code="sq2", subquestion="")
    #             end
    #             @test length(n.subquestions) == 2
    #             @test isnothing(n.minimum) == true
    #             @test isnothing(n.maximum) == true
    #             @test isnothing(n.maximum_chars) == true
    #             @test isnothing(n.minimum_sum) == true
    #             @test isnothing(n.maximum_sum) == true
    #             @test n.integer_only == false

    #             n = multiple_numerical_input(
    #                 code="q1",
    #                 minimum=0,
    #                 maximum=10,
    #                 maximum_chars=100,
    #                 minimum_sum=0,
    #                 maximum_sum=50,
    #                 integer_only=true
    #             ) do
    #                 subquestion(code="sq1", subquestion=""),
    #                 subquestion(code="sq2", subquestion=""),
    #                 subquestion(code="sq3", subquestion="")
    #             end
    #             @test length(n.subquestions) == 3
    #             @test n.minimum == 0
    #             @test n.maximum == 10
    #             @test n.maximum_chars == 100
    #             @test n.minimum_sum == 0
    #             @test n.maximum_sum == 50
    #             @test n.integer_only == true

    #             @test_throws ErrorException multiple_numerical_input(code="q1", minimum=10, maximum=0)
    #             @test_throws ErrorException multiple_numerical_input(code="q1", minimum_sum=10, maximum_sum=0)
    #             @test_throws ErrorException multiple_numerical_input(code="q1", minimum_sum=10.0, maximum_sum=0.0)
    #         end
    #     end
end
