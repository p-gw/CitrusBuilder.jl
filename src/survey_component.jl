abstract type AbstractSurveyComponent end

id(component::AbstractSurveyComponent) = component.id
languages(component::AbstractSurveyComponent) = getfield.(component.language_settings, :language)
default_language(component::AbstractSurveyComponent) = first(component.language_settings).language

function title(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.title
end

function help(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.help
end

function description(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.description
end

children(x::AbstractSurveyComponent) = x.children

function Base.prepend!(c::AbstractSurveyComponent, item)
    prepend!(children(c), tovector(item))
    return item
end

function Base.append!(c::AbstractSurveyComponent, item)
    append!(children(c), tovector(item))
    return item
end

function Base.insert!(c::AbstractSurveyComponent, i::Int, item)
    insert!(children(c), i, item)
    return item
end

abstract type AbstractQuestion <: AbstractSurveyComponent end

type(q::AbstractQuestion) = q.type
