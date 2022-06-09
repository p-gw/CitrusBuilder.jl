const QUESTION_FIELDS = ["qid", "parent_qid", "sid", "gid", "type", "title", "question", "preg", "help", "other", "mandatory", "question_order", "language", "scale_id", "same_default", "relevance", "modulename"]

"""
    addfields!(n, fields)

Add a `<fields>` attributes to an XML Node.
"""
function addfields!(n::EzXML.Node, fields::Vector{String})
    field_node = addelement!(n, "fields")
    for field in fields
        addelement!(field_node, "fieldname", field)
    end
    return field_node
end

function addrow!(n::EzXML.Node)
    row_node = addsinglenode!(n, "rows")
    row = addelement!(row_node, "row")
    return row
end

"""
    addsinglenode!(n, name)

Add an XML node with `name` to another XML node only if it does not already exist.
Returns the new node or first existing matched node.
"""
function addsinglenode!(n::EzXML.Node, name::AbstractString)
    children = nodes(n)
    children_names = getproperty.(children, :name)

    if !(name in children_names)
        node = addelement!(n, name)
    else
        node_id = findfirst(x -> x == name, children_names)
        node = children[node_id]
    end
    return node
end

"""
    addnode!(n, element, node)

Add a node within a element of the parent node.
Used for CData nodes.
"""
function addnode!(n::EzXML.Node, element::AbstractString, node::EzXML.Node)
    el = addelement!(n, element)
    link!(el, node)
    return node
end

function addcdatanode!(n::EzXML.Node, element::AbstractString, data::AbstractString)
    addnode!(n, element, CDataNode(data))
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

function add_header!(root, survey::Survey)
    addelement!(root, "LimeSurveyDocType", "Survey")
    add_languages!(root, survey)
    return nothing
end

function add_languages!(root, survey::Survey)
    language_node = addsinglenode!(root, "languages")
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

function add_survey!(root, survey::Survey)
    surveys_node = addsinglenode!(root, "surveys")
    survey_node = addrow!(surveys_node)
    addcdatanode!(survey_node, "sid", string(survey.id))
    addcdatanode!(survey_node, "language", survey.language)

    iterator = SurveyIterator(survey.id)

    for (group_order, group) in enumerate(survey.children)
        iterator.group_id = group_order
        iterator.order = group_order
        add_question_group!(root, group, iterator)
    end

    return nothing
end

function add_question_group!(root, group::QuestionGroup, iterator::SurveyIterator)
    groups_node = addsinglenode!(root, "groups")
    group_node = addrow!(groups_node)

    addcdatanode!(group_node, "gid", string(iterator.group_id))
    addcdatanode!(group_node, "sid", string(iterator.survey_id))
    addcdatanode!(group_node, "group_name", group.title)
    addcdatanode!(group_node, "group_order", string(iterator.order))
    addcdatanode!(group_node, "description", group.description)
    addcdatanode!(group_node, "language", group.language)

    for (question_order, question) in enumerate(group.children)
        iterator.counter += 1
        iterator.question_id = iterator.counter
        iterator.order = question_order
        add_question!(root, question, iterator)
    end

    return nothing
end

function add_question!(root, question::Question, iterator::SurveyIterator)
    questions_node = addsinglenode!(root, "questions")
    question_node = addrow!(questions_node)

    addcdatanode!(question_node, "qid", string(iterator.question_id))
    addcdatanode!(question_node, "gid", string(iterator.group_id))
    addcdatanode!(question_node, "sid", string(iterator.survey_id))
    addcdatanode!(question_node, "type", question.type)
    addcdatanode!(question_node, "title", string(question.id))
    addcdatanode!(question_node, "question", question.question)
    isnothing(question.help) || addcdatanode!(question_node, "help", question.help)
    addcdatanode!(question_node, "other", question.other ? "Y" : "N")
    addcdatanode!(question_node, "mandatory", question.mandatory ? "Y" : "N")
    addcdatanode!(question_node, "question_order", string(iterator.order))
    addcdatanode!(question_node, "language", question.language)
    addcdatanode!(question_node, "relevance", question.relevance)

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

function add_subquestion!(root, subquestion::SubQuestion, iterator::SurveyIterator)
    subquestions_node = addsinglenode!(root, "subquestions")
    subquestion_node = addrow!(subquestions_node)

    addcdatanode!(subquestion_node, "parent_qid", string(iterator.question_id))
    addcdatanode!(subquestion_node, "qid", string(iterator.counter))
    addcdatanode!(subquestion_node, "sid", string(iterator.survey_id))
    addcdatanode!(subquestion_node, "gid", string(iterator.group_id))
    addcdatanode!(subquestion_node, "type", subquestion.type)
    addcdatanode!(subquestion_node, "title", subquestion.id)
    addcdatanode!(subquestion_node, "question", subquestion.question)
    addcdatanode!(subquestion_node, "question_order", string(iterator.order))
    addcdatanode!(subquestion_node, "language", subquestion.language)
    # scale_id
    # same_default
    addcdatanode!(subquestion_node, "relevance", sq.relevance)

    return nothing
end

function add_response_option!(root, option::ResponseOption, iterator::SurveyIterator)
    add_answer!(root, option, iterator)

    if is_default(option)
        add_response_option!(root, option, i)
    end

    return nothing
end

function add_answer!(root, option::ResponseOption, iterator::SurveyIterator)
    answers_node = addsinglenode!(root, "answers")
    answer_node = addrow!(answers_node)

    addcdatanode!(answer_node, "qid", string(iterator.question_id))
    addcdatanode!(answer_node, "code", option.id)
    addcdatanode!(answer_node, "answer", option.option)
    addcdatanode!(answer_node, "sortorder", string(iterator.order))
    # assessment value
    addcdatanode!(answer_node, "language", option.language)
    addcdatanode!(answer_node, "scale_id", string(option.scale_id))
    return nothing
end

function add_default_value!(root, option::ResponseOption, iterator::SurveyIterator)
    defaults_node = addsinglenode!(root, "defaultvalues")
    default_node = addrow!(defaults_node)

    addcdatanode!(default_node, "qid", string(iterator.question_id))
    addcdatanode!(default_node, "scale_id", string(option.scale_id))
    addcdatanode!(default_node, "sqid", string(iterator.subquestion_id))
    addcdatanode!(default_node, "language", option.language)
    # specialtype
    addcdatanode!(default_node, "defaultvalue", option.id)

    return nothing
end

function add_language_settings!(root, survey::Survey)
    settings_node = addsinglenode!(root, "surveys_languagesettings")

    for language in languages(survey)
        setting_node = addrow!(settings_node)
        addcdatanode!(setting_node, "surveyls_survey_id", string(survey.id))
        addcdatanode!(setting_node, "surveyls_language", language)
        addcdatanode!(setting_node, "surveyls_title", title(survey, language))
    end

    return nothing
end
