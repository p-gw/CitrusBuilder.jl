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
    add_node!(parent, element, CDataNode(string(data)))
    return nothing
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
    language_node = add_unique_node!(root, "languages")
    for language in languages(survey)
        addelement!(language_node, "language", language)
    end
    return nothing
end

mutable struct SurveyIterator
    survey_id::Int
    group_id::Int
    question_id::Int
    subquestion_id::Int
    counter::Int
    order::Int
end

SurveyIterator(survey_id) = SurveyIterator(survey_id, 0, 0, 0, 0, 0)

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

    return nothing
end

function add_question_group!(root::EzXML.Node, group::QuestionGroup, iterator::SurveyIterator)
    groups_node = add_unique_node!(root, "groups")

    for language in languages(group)
        group_node = add_row_node!(groups_node)
        add_cdata_node!(group_node, "gid", iterator.group_id)
        add_cdata_node!(group_node, "sid", iterator.survey_id)
        add_cdata_node!(group_node, "group_order", iterator.order)
        add_cdata_node!(group_node, "group_name", title(group, language))
        add_cdata_node!(group_node, "description", description(group, language))
        add_cdata_node!(group_node, "language", language)
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
        add_cdata_node!(question_node, "help", help(question, language))
        add_cdata_node!(question_node, "other", has_other(question) ? "Y" : "N")
        add_cdata_node!(question_node, "mandatory", is_mandatory(question) ? "Y" : "N")
        add_cdata_node!(question_node, "question_order", iterator.order)
        add_cdata_node!(question_node, "language", language)
        add_cdata_node!(question_node, "relevance", question.relevance)
    end

    for (subquestion_order, subquestion) in enumerate(question.subquestions)
        iterator.counter += 1
        iterator.order = subquestion_order
        iterator.subquestion_id = iterator.counter
        add_subquestion!(root, subquestion, iterator)
    end

    for (option_order, option) in enumerate(question.options)
        iterator.order = option_order
        add_response_option!(root, option, iterator)
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
        # scale_id
        # same_default
    end

    return nothing
end

function add_response_option!(root::EzXML.Node, option::ResponseOption, iterator::SurveyIterator)
    add_answer!(root, option, iterator)
    is_default(option) && add_default_value!(root, option, iterator)
    return nothing
end

function add_answer!(root::EzXML.Node, option::ResponseOption, iterator::SurveyIterator)
    answers_node = add_unique_node!(root, "answers")
    answer_node = add_row_node!(answers_node)

    add_cdata_node!(answer_node, "qid", iterator.question_id)
    add_cdata_node!(answer_node, "code", option.id)
    add_cdata_node!(answer_node, "answer", option.option)
    add_cdata_node!(answer_node, "sortorder", iterator.order)
    # assessment value
    add_cdata_node!(answer_node, "language", option.language)
    add_cdata_node!(answer_node, "scale_id", option.scale_id)

    return nothing
end

function add_default_value!(root::EzXML.Node, option::ResponseOption, iterator::SurveyIterator)
    defaults_node = add_unique_node!(root, "defaultvalues")
    default_node = add_row_node!(defaults_node)

    add_cdata_node!(default_node, "qid", iterator.question_id)
    add_cdata_node!(default_node, "scale_id", option.scale_id)
    add_cdata_node!(default_node, "sqid", iterator.subquestion_id)
    add_cdata_node!(default_node, "language", option.language)
    add_cdata_node!(default_node, "defaultvalue", option.id)
    # specialtype

    return nothing
end

function add_language_settings!(root::EzXML.Node, survey::Survey)
    settings_node = add_unique_node!(root, "surveys_languagesettings")

    for language in languages(survey)
        setting_node = add_row_node!(settings_node)
        add_cdata_node!(setting_node, "surveyls_survey_id", survey.id)
        add_cdata_node!(setting_node, "surveyls_language", language)
        add_cdata_node!(setting_node, "surveyls_title", title(survey, language))
    end

    return nothing
end

function write(filename::AbstractString, survey::Survey)
    file_name = last(splitpath(filename))
    last(splitext(filename)) == ".lss" || @warn "File '$file_name' does not have .lss extension."
    write(filename, xml(survey))
end
