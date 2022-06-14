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
end
