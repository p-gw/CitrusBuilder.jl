"""
    SubQuestion

# Fields
- `id::String`: An alphanumeric question id. Must start with a letter.
- `question::String`: The subquestion title.
- `type::String`: The LimeSurvey qusetion type
- `relevance::String`: A LimeSurvey Expression Script
"""
struct SubQuestion <: AbstractQuestion
    id::String
    type::String
    relevance::String
    language_settings::Vector{LanguageSetting}
    # TODO: validate id
end

"""
    subquestion(; id, title, relevance = "1")

Construct a subquestion using the default survey language.
"""
function subquestion(id::String, title::String; relevance="1")
    setting = language_setting(DEFAULT_LANGUAGE[], title)
    return SubQuestion(id, "T", relevance, tovector(setting))
end

"""
    subquestion(; id, language_settings, relevance = "1")

Construct a multi-language subquestion.
"""
function subquestion(id::String, language_settings::Vector{LanguageSetting}; relevance="1")
    return SubQuestion(id, "T", relevance, language_settings)
end

type(q::SubQuestion) = q.type
relevance(q::SubQuestion) = q.relevance
