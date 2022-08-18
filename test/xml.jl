@testset "XML exports" begin
    @testset "create_document!" begin
        doc = LimeSurveyBuilder.create_document!()
        @test doc isa EzXML.Document
        @test version(doc) == "1.0"
        @test hasroot(doc) == true
        @test nodetype(root(doc)) == EzXML.ELEMENT_NODE
        @test nodename(root(doc)) == "document"
    end

    @testset "add_unique_node!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        testnode = LimeSurveyBuilder.add_unique_node!(docroot, "testnode")

        @test countnodes(docroot) == 1
        @test nodetype(testnode) == EzXML.ELEMENT_NODE
        @test nodename(testnode) == "testnode"

        testnode_duplicate = LimeSurveyBuilder.add_unique_node!(docroot, "testnode")
        @test countnodes(docroot) == 1
        @test testnode == testnode_duplicate
    end

    @testset "add_node!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        element_node = LimeSurveyBuilder.add_node!(docroot, "testnode", CDataNode("data"))
        @test countnodes(docroot) == 1
        @test iscdata(element_node) == true

        testnode = first(nodes(docroot))
        @test iselement(testnode) == true
        @test countnodes(testnode) == 1
        @test nodename(testnode) == "testnode"
        @test nodecontent(testnode) == "data"
        @test first(nodes(testnode)) == element_node

        @test iscdata(element_node) == true
        @test nodecontent(element_node) == "data"

        # no uniqueness constraint
        n = 3
        for i in 1:n
            LimeSurveyBuilder.add_node!(docroot, "node_$i", CDataNode("$i"))
        end

        @test countnodes(docroot) == n + 1
    end

    @testset "add_row_node!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        n = 5
        for i in 1:n
            row_node = LimeSurveyBuilder.add_row_node!(docroot)
            @test nodename(row_node) == "row"
        end

        rows_node = first(nodes(docroot))
        @test nodename(rows_node) == "rows"
        @test countnodes(rows_node) == n

        # with preexisting 'rows' node
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        rows_node = LimeSurveyBuilder.add_unique_node!(docroot, "rows")

        for i in 1:n
            LimeSurveyBuilder.add_row_node!(docroot)
        end

        @test countnodes(rows_node) == n
    end

    @testset "add_cdata_node!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        inputs = ["test", 1, 1.0, 1 // 3]

        for (i, input) in enumerate(inputs)
            cdata_node = LimeSurveyBuilder.add_cdata_node!(docroot, "node_$i", input)
            @test nodename(parentnode(cdata_node)) == "node_$i"
            @test nodecontent(cdata_node) == string(input)
        end
    end

    @testset "add_languages!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        s = survey(100000, language_settings([
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ]))

        languages_node = LimeSurveyBuilder.add_languages!(docroot, s)
        @test nodename(languages_node) == "languages"
        @test countnodes(languages_node) == 2

        language_nodes = nodes(languages_node)
        @test nodecontent(language_nodes[1]) == "en"
        @test nodecontent(language_nodes[2]) == "de"
        @test nodename(language_nodes[1]) == "language"
    end

    @testset "add_header!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        s = survey(100000, language_settings([
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ]))

        LimeSurveyBuilder.add_header!(docroot, s)
        @test countnodes(docroot) == 2

        survey_type_node = first(nodes(docroot))
        @test nodename(survey_type_node) == "LimeSurveyDocType"
        @test nodecontent(survey_type_node) == "Survey"

        languages_node = last(nodes(docroot))
        @test countnodes(languages_node) == 2
    end

    @testset "SurveyIterator" begin
        iterator = LimeSurveyBuilder.SurveyIterator(123456)
        @test iterator.survey_id == 123456
        @test iterator.group_id == 0
        @test iterator.question_id == 0
        @test iterator.subquestion_id == 0
        @test iterator.order == 0
        @test iterator.scale_id == 0
    end

    @testset "add_survey!" begin
        s = survey(100000, "testsurvey 1")

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        LimeSurveyBuilder.add_survey!(docroot, s)

        @test countnodes(docroot) == 1
        surveys_node = first(nodes(docroot))

        @test nodename(surveys_node) == "surveys"
        @test countnodes(surveys_node) == 1

        rows_node = first(nodes(surveys_node))
        @test nodename(rows_node) == "rows"
        @test countnodes(rows_node) == 1

        row_node = first(nodes(rows_node))
        @test nodename(row_node) == "row"

        survey_data = nodes(row_node)
        @test nodename(survey_data[1]) == "sid"
        @test nodecontent(survey_data[1]) == "100000"
        @test nodename(survey_data[2]) == "language"
        @test nodecontent(survey_data[2]) == "en"

        # with language settings
        s = survey(100001, language_settings([
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ]))

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        LimeSurveyBuilder.add_survey!(docroot, s)

        @test countnodes(docroot) == 1
        surveys_node = first(nodes(docroot))

        @test nodename(surveys_node) == "surveys"
        @test countnodes(surveys_node) == 1

        rows_node = first(nodes(surveys_node))
        @test nodename(rows_node) == "rows"
        @test countnodes(rows_node) == 2

        for (i, row) in enumerate(nodes(rows_node))
            language = i == 1 ? "en" : "de"
            settings = nodes(row)
            @test nodename(settings[1]) == "sid"
            @test nodecontent(settings[1]) == "100001"

            @test nodename(settings[2]) == "language"
            @test nodecontent(settings[2]) == language
        end

        # with question groups
        n_groups = 4
        s = survey(100002, "survey title") do
            (question_group(i, "group $i") for i in 1:n_groups)
        end

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        LimeSurveyBuilder.add_survey!(docroot, s)


        @test nodename.(nodes(docroot)) == ["surveys", "groups"]
        surveys_node, groups_node = nodes(docroot)

        @test countnodes(groups_node) == 1

        rows_node = first(nodes(groups_node))
        @test nodename(rows_node) == "rows"
        @test countnodes(rows_node) == n_groups

        for (i, row) in enumerate(nodes(rows_node))
            @test nodename(row) == "row"
            @test nodename.(nodes(row)) == ["gid", "sid", "group_order", "group_name", "language"]
            @test nodecontent.(nodes(row)) == ["$i", "100002", "$i", "group $i", "en"]
        end
    end

    @testset "add_question_group!" begin
        # without questions
        group = question_group(100, "group title")
        iterator = LimeSurveyBuilder.SurveyIterator(1, 2, 3, 4, 5, 6, 7)

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        LimeSurveyBuilder.add_question_group!(docroot, group, iterator)

        @test iterator.survey_id == 1
        @test iterator.group_id == 2
        @test iterator.question_id == 3
        @test iterator.subquestion_id == 4
        @test iterator.scale_id == 5
        @test iterator.counter == 6
        @test iterator.order == 7

        @test countnodes(docroot) == 1
        groups_node = first(nodes(docroot))
        @test nodename(groups_node) == "groups"
        @test countnodes(groups_node) == 1

        rows_node = first(nodes(groups_node))
        row_node = first(nodes(rows_node))
        @test nodename.(nodes(row_node)) == ["gid", "sid", "group_order", "group_name", "language"]
        @test nodecontent.(nodes(row_node)) == ["$(iterator.group_id)", "$(iterator.survey_id)", "$(iterator.order)", "group title", "en"]

        # with description
        group = question_group(101, "second group", description="some description")
        LimeSurveyBuilder.add_question_group!(docroot, group, iterator)

        row_node = last(nodes(rows_node))
        @test nodename.(nodes(row_node)) == ["gid", "sid", "group_order", "group_name", "language", "description"]
        @test nodecontent.(nodes(row_node)) == ["$(iterator.group_id)", "$(iterator.survey_id)", "$(iterator.order)", "second group", "en", "some description"]

        # with questions
        n = 5
        group = question_group(1, "title") do
            (short_text_question("q$i", "question $i") for i in 1:n)
        end

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        iterator = LimeSurveyBuilder.SurveyIterator(1, 1, 1, 1, 1, 1, 1)
        LimeSurveyBuilder.add_question_group!(docroot, group, iterator)

        @test iterator.survey_id == 1
        @test iterator.group_id == 1
        @test iterator.question_id == n + 1
        @test iterator.subquestion_id == 1
        @test iterator.scale_id == 1
        @test iterator.counter == n + 1
        @test iterator.order == n

        questions_node = last(nodes(docroot))
        rows_node = first(nodes(questions_node))
        row_nodes = nodes(rows_node)

        for (i, row) in enumerate(row_nodes)
            row_data = nodes(row)
            @test nodename(row_data[1]) == "qid"
            @test nodecontent(row_data[1]) == string(i + 1)

            @test nodename(row_data[9]) == "question_order"
            @test nodecontent(row_data[9]) == string(i)
        end
    end

    @testset "add_question!" begin end

    @testset "add_question_attribute!" begin
        attribute = LimeSurveyBuilder.QuestionAttribute("key", nothing, "value")
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        iterator = LimeSurveyBuilder.SurveyIterator(0)

        LimeSurveyBuilder.add_question_attribute!(docroot, attribute, iterator)
        @test countnodes(docroot) == 1

        attributes_node = first(nodes(docroot))
        @test nodename(attributes_node) == "question_attributes"
        @test countnodes(attributes_node) == 1

        rows_node = first(nodes(attributes_node))
        row_node = first(nodes(rows_node))
        row_data = nodes(row_node)

        @test nodename.(row_data) == ["qid", "attribute", "value"]
        @test nodecontent.(row_data) == ["0", "key", "value"]

        attribute = LimeSurveyBuilder.QuestionAttribute("a2", "de", "v2")
        LimeSurveyBuilder.add_question_attribute!(docroot, attribute, iterator)
        @test countnodes(rows_node) == 2

        row_node = nodes(rows_node)[2]
        row_data = nodes(row_node)

        @test nodename.(row_data) == ["qid", "attribute", "value", "language"]
        @test nodecontent.(row_data) == ["0", "a2", "v2", "de"]
    end

    @testset "add_subquestion!" begin
        sq = subquestion("sq", "subquestion")
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        iterator = LimeSurveyBuilder.SurveyIterator(0)

        LimeSurveyBuilder.add_subquestion!(docroot, sq, iterator)
        @test countnodes(docroot) == 1

        subquestions_node = first(nodes(docroot))
        @test nodename(subquestions_node) == "subquestions"
        @test countnodes(subquestions_node) == 1

        rows_node = first(nodes(subquestions_node))
        row_node = first(nodes(rows_node))
        row_data = nodes(row_node)

        @test nodename.(row_data) == ["parent_qid", "qid", "sid", "gid", "type", "title", "question", "question_order", "language", "relevance", "scale_id", "same_default"]
        @test nodecontent.(row_data) == ["0", "0", "0", "0", "T", "sq", "subquestion", "0", "en", "1", "0", "0"]

        sq = subquestion("sq2", "subquestion 2", scale_id=1)
        LimeSurveyBuilder.add_subquestion!(docroot, sq, iterator)
        @test countnodes(rows_node) == 2

        row_node = nodes(rows_node)[2]
        @test nodecontent(nodes(row_node)[11]) == "1" # scale_id
    end

    @testset "add_response_scale!" begin
        scale = response_scale(default="o2") do
            response_option("o1", "option 1"),
            response_option("o2", "option 2"),
            response_option("o3", "option 3")
        end

        iterator = LimeSurveyBuilder.SurveyIterator(0)

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        LimeSurveyBuilder.add_response_scale!(docroot, scale, iterator)
        @test countnodes(docroot) == 2
        @test nodename.(nodes(docroot)) == ["answers", "defaultvalues"]

        answers_node = first(nodes(docroot))
        answer_nodes = nodes(first(nodes(answers_node)))
        @test length(answer_nodes) == 3

        for (i, row) in enumerate(answer_nodes)
            answer_data = nodes(row)
            @test nodecontent(answer_data[4]) == "$i"
        end

        defaults_node = last(nodes(docroot))
        default_nodes = nodes(first(nodes(defaults_node)))
        @test length(default_nodes) == 1

        # no defaultvalues node without default
        scale = response_scale() do
            response_option("o1", "option 1")
        end

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        LimeSurveyBuilder.add_response_scale!(docroot, scale, iterator)

        @test nodename.(nodes(docroot)) == ["answers"]
    end

    @testset "add_answer!" begin
        option = response_option("o1", "option 1")
        iterator = LimeSurveyBuilder.SurveyIterator(1, 2, 3, 4, 5, 6, 7)

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        LimeSurveyBuilder.add_answer!(docroot, option, iterator)
        @test countnodes(docroot) == 1

        answers_node = first(nodes(docroot))
        @test nodename(answers_node) == "answers"

        rows_node = first(nodes(answers_node))
        @test countnodes(rows_node) == 1

        answer_node = first(nodes(rows_node))
        @test nodename(answer_node) == "row"

        answer_data = nodes(answer_node)
        @test nodename.(answer_data) == ["qid", "code", "answer", "sortorder", "language", "scale_id"]
        @test nodecontent.(answer_data) == ["$(iterator.question_id)", "o1", "option 1", "$(iterator.order)", "en", "$(iterator.scale_id)"]
    end

    @testset "add_default_value!" begin
        # question
        q = short_text_question("q1", language_settings([
            language_setting("en", "", default="some default"),
            language_setting("de", "")
        ]))

        iterator = LimeSurveyBuilder.SurveyIterator(1, 2, 3, 4, 5, 6, 7)

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        defaults_node = LimeSurveyBuilder.add_default_value!(docroot, q, iterator)

        @test nodename(defaults_node) == "defaultvalues"
        @test countnodes(defaults_node) == 1

        rows_node = first(nodes(defaults_node))
        @test countnodes(rows_node) == 1

        row_node = first(nodes(rows_node))
        row_data = nodes(row_node)
        @test nodename.(row_data) == ["qid", "scale_id", "sqid", "language", "defaultvalue"]
        @test nodecontent.(row_data) == string.([iterator.question_id, iterator.scale_id, iterator.subquestion_id, "en", "some default"])

        # subquestion
        # response scale
        scale = response_scale(default="o3") do
            (response_option("o$i", "option $i") for i in 1:3)
        end

        iterator = LimeSurveyBuilder.SurveyIterator(0)
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        defaults_node = LimeSurveyBuilder.add_default_value!(docroot, scale, iterator)
        @test nodename(first(nodes(docroot))) == "defaultvalues"

        rows_node = first(nodes(defaults_node))
        row_node = first(nodes(rows_node))
        row_data = nodes(row_node)

        @test nodename.(row_data) == ["qid", "scale_id", "sqid", "language", "defaultvalue"]
        @test nodecontent.(row_data) == string.([iterator.question_id, iterator.scale_id, iterator.subquestion_id, "en", "o3"])
    end

    @testset "add_language_settings!" begin
        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)

        s = survey(100000, "title")
        LimeSurveyBuilder.add_language_settings!(docroot, s)

        @test countnodes(docroot) == 1

        settings_node = first(nodes(docroot))
        @test nodename(settings_node) == "surveys_languagesettings"

        rows_node = first(nodes(settings_node))
        row_node = first(nodes(rows_node))
        @test nodename.(nodes(row_node)) == ["surveyls_survey_id", "surveyls_language", "surveyls_title"]
        @test nodecontent.(nodes(row_node)) == ["100000", "en", "title"]

        s = survey(100001, language_settings([
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ]))

        doc = LimeSurveyBuilder.create_document!()
        docroot = root(doc)
        LimeSurveyBuilder.add_language_settings!(docroot, s)
        settings_node = first(nodes(docroot))
        rows_node = first(nodes(settings_node))
        @test countnodes(rows_node) == 2
        rows = nodes(rows_node)

        @test nodecontent.(nodes(rows[1])) == ["100001", "en", "title"]
        @test nodecontent.(nodes(rows[2])) == ["100001", "de", "Titel"]
    end

    @testset "xml" begin end
    @testset "write" begin end
end
