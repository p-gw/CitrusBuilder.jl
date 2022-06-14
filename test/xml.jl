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

        s = survey(100000, [
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ])

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

        s = survey(100000, [
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ])

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
        s = survey(100001, [
            language_setting("en", "title"),
            language_setting("de", "Titel")
        ])

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

        # TODO: with question groups
    end
end
