abstract type AbstractSurveyComponent end

id(component::AbstractSurveyComponent) = component.id
languages(component::AbstractSurveyComponent) = getfield.(component.language_settings.settings, :language)
default_language(component::AbstractSurveyComponent) = first(component.language_settings.settings).language
same_default(component::AbstractSurveyComponent) = component.language_settings.same_default

function default(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.default
end

function has_default(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return !isnothing(setting.default)
end

function title(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.title
end

function help(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.help
end

function has_help(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return !isnothing(setting.help)
end

function description(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return setting.description
end

function has_description(component::AbstractSurveyComponent, language::String=default_language(component))
    setting = find_language_setting(language, component)
    return !isnothing(setting.description)
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
