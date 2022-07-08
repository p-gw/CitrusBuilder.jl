function add_unique_node!(parent::EzXML.Node, name::AbstractString)
    children = nodes(parent)
    children_names = getproperty.(children, :name)

    if !(name in children_names)
        node = addelement!(parent, name)
    else
        node_id = findfirst(x -> x == name, children_names)
        node = children[node_id]
    end
    return node
end

function add_cdata_node!(parent::EzXML.Node, element::AbstractString, data)
    element_node = add_node!(parent, element, CDataNode(string(data)))
    return element_node
end

function add_node!(parent::EzXML.Node, element::AbstractString, node::EzXML.Node)
    el = addelement!(parent, element)
    link!(el, node)
    return node
end

function add_row_node!(parent::EzXML.Node)
    row_node = add_unique_node!(parent, "rows")
    row = addelement!(row_node, "row")
    return row
end

"""
    xml(survey::Survey)

Construct an XML document from a `Survey` object.

# Examples
```julia-repl
julia> s = survey(100000, "my survey")
julia> xml(s)
```
"""
function xml(survey::Survey)
    doc = create_document!()
    docroot = root(doc)
    add_header!(docroot, survey)
    add_survey!(docroot, survey)
    add_language_settings!(docroot, survey)
    return doc
end

function create_document!()
    document = XMLDocument("1.0")
    setroot!(document, ElementNode("document"))
    return document
end

function add_header!(root::EzXML.Node, survey::Survey)
    addelement!(root, "LimeSurveyDocType", "Survey")
    add_languages!(root, survey)
    return nothing
end

function add_languages!(root::EzXML.Node, survey::Survey)
    languages_node = add_unique_node!(root, "languages")
    for language in languages(survey)
        addelement!(languages_node, "language", language)
    end
    return languages_node
end

mutable struct SurveyIterator
    survey_id::Int
    group_id::Int
    question_id::Int
    subquestion_id::Int
    scale_id::Int
    counter::Int
    order::Int
end

SurveyIterator(survey_id) = SurveyIterator(survey_id, 0, 0, 0, 0, 0, 0)

function add_survey!(root::EzXML.Node, survey::Survey)
    surveys_node = add_unique_node!(root, "surveys")

    for language in languages(survey)
        survey_node = add_row_node!(surveys_node)
        add_cdata_node!(survey_node, "sid", survey.id)
        add_cdata_node!(survey_node, "language", language)
    end

    iterator = SurveyIterator(survey.id)

    for (group_order, group) in enumerate(children(survey))
        iterator.group_id = group_order
        iterator.order = group_order
        add_question_group!(root, group, iterator)
    end

    return surveys_node
end

function add_question_group!(root::EzXML.Node, group::QuestionGroup, iterator::SurveyIterator)
    groups_node = add_unique_node!(root, "groups")

    for language in languages(group)
        group_node = add_row_node!(groups_node)
        add_cdata_node!(group_node, "gid", iterator.group_id)
        add_cdata_node!(group_node, "sid", iterator.survey_id)
        add_cdata_node!(group_node, "group_order", iterator.order)
        add_cdata_node!(group_node, "group_name", title(group, language))
        add_cdata_node!(group_node, "language", language)

        if has_description(group, language)
            add_cdata_node!(group_node, "description", description(group, language))
        end
    end

    for (question_order, question) in enumerate(group.children)
        iterator.counter += 1
        iterator.question_id = iterator.counter
        iterator.order = question_order
        add_question!(root, question, iterator)
    end

    return nothing
end

function add_question!(root::EzXML.Node, question::Question, iterator::SurveyIterator)
    questions_node = add_unique_node!(root, "questions")

    for language in languages(question)
        question_node = add_row_node!(questions_node)
        add_cdata_node!(question_node, "qid", iterator.question_id)
        add_cdata_node!(question_node, "gid", iterator.group_id)
        add_cdata_node!(question_node, "sid", iterator.survey_id)
        add_cdata_node!(question_node, "type", question.type)
        add_cdata_node!(question_node, "title", question.id)
        add_cdata_node!(question_node, "question", title(question, language))
        add_cdata_node!(question_node, "other", has_other(question) ? "Y" : "N")
        add_cdata_node!(question_node, "mandatory", is_mandatory(question) ? "Y" : "N")
        add_cdata_node!(question_node, "question_order", iterator.order)
        add_cdata_node!(question_node, "language", language)
        add_cdata_node!(question_node, "scale_id", iterator.scale_id)
        add_cdata_node!(question_node, "same_default", same_default(question) ? "1" : "0")
        add_cdata_node!(question_node, "relevance", question.relevance)

        if has_help(question, language)
            add_cdata_node!(question_node, "help", help(question, language))
        end
    end

    if has_default(question)
        add_default_value!(root, question, iterator)
    end

    for (subquestion_order, subquestion) in enumerate(question.subquestions)
        iterator.counter += 1
        iterator.order = subquestion_order
        iterator.subquestion_id = iterator.counter
        add_subquestion!(root, subquestion, iterator)
    end

    for (scale_id, scale) in enumerate(question.options)
        # LimeSurveys scale_id starts at 0
        iterator.scale_id = scale_id - 1
        add_response_scale!(root, scale, iterator)
    end

    return nothing
end

function add_subquestion!(root::EzXML.Node, subquestion::SubQuestion, iterator::SurveyIterator)
    subquestions_node = add_unique_node!(root, "subquestions")

    for language in languages(subquestion)
        subquestion_node = add_row_node!(subquestions_node)
        add_cdata_node!(subquestion_node, "parent_qid", iterator.question_id)
        add_cdata_node!(subquestion_node, "qid", iterator.counter)
        add_cdata_node!(subquestion_node, "sid", iterator.survey_id)
        add_cdata_node!(subquestion_node, "gid", iterator.group_id)
        add_cdata_node!(subquestion_node, "type", subquestion.type)
        add_cdata_node!(subquestion_node, "title", subquestion.id)
        add_cdata_node!(subquestion_node, "question", title(subquestion, language))
        add_cdata_node!(subquestion_node, "question_order", iterator.order)
        add_cdata_node!(subquestion_node, "language", language)
        add_cdata_node!(subquestion_node, "relevance", subquestion.relevance)
        add_cdata_node!(subquestion_node, "scale_id", subquestion.scale_id)
        add_cdata_node!(subquestion_node, "same_default", same_default(subquestion) ? "1" : "0")
    end

    if has_default(subquestion)
        add_default_value!(root, subquestion, iterator)
    end

    return nothing
end

function add_response_scale!(root::EzXML.Node, scale::ResponseScale, iterator::SurveyIterator)
    for (option_order, option) in enumerate(scale.options)
        iterator.order = option_order
        add_answer!(root, option, iterator)
    end

    if has_default(scale)
        add_default_value!(root, scale, iterator)
    end

    return nothing
end

function add_answer!(root::EzXML.Node, option::ResponseOption, iterator::SurveyIterator)
    answers_node = add_unique_node!(root, "answers")

    for language in languages(option)
        answer_node = add_row_node!(answers_node)
        add_cdata_node!(answer_node, "qid", iterator.question_id)
        add_cdata_node!(answer_node, "code", option.id)
        add_cdata_node!(answer_node, "answer", title(option, language))
        add_cdata_node!(answer_node, "sortorder", iterator.order)
        add_cdata_node!(answer_node, "language", language)
        add_cdata_node!(answer_node, "scale_id", iterator.scale_id)
        # assessment value
    end

    return nothing
end

function add_default_value!(root::EzXML.Node, component::AbstractSurveyComponent, iterator::SurveyIterator)
    defaults_node = add_unique_node!(root, "defaultvalues")

    for language in languages(component)
        if has_default(component, language)
            default_node = add_row_node!(defaults_node)
            add_cdata_node!(default_node, "qid", iterator.question_id)
            add_cdata_node!(default_node, "scale_id", iterator.scale_id)
            add_cdata_node!(default_node, "sqid", iterator.subquestion_id)
            add_cdata_node!(default_node, "language", language)
            add_cdata_node!(default_node, "defaultvalue", default(component, language))
        end
    end

    return defaults_node
end

function add_language_settings!(root::EzXML.Node, survey::Survey)
    settings_node = add_unique_node!(root, "surveys_languagesettings")

    for language in languages(survey)
        setting_node = add_row_node!(settings_node)
        add_cdata_node!(setting_node, "surveyls_survey_id", survey.id)
        add_cdata_node!(setting_node, "surveyls_language", language)
        add_cdata_node!(setting_node, "surveyls_title", title(survey, language))
    end

    return settings_node
end

"""
    write(filename::AbstractString, survey::Survey)

Write the XML structure of `survey` to a file.
Make sure that the `filename` extension is `.lss` for the import in LimeSurvey.

# Examples
```julia-repl
julia> s = survey(100000, "my survey")
julia> write("mysurvey.lss", s)
```
"""
function write(filename::AbstractString, survey::Survey)
    file_name = last(splitpath(filename))
    last(splitext(filename)) == ".lss" || @warn "File '$file_name' does not have .lss extension."
    write(filename, xml(survey))
end
