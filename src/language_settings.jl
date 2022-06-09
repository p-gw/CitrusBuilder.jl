struct LanguageSetting
    language::String
    title::String
    help::Union{Nothing,String}
    description::Union{Nothing,String}
end

function language_setting(language, title; help=nothing, description=nothing)
    return LanguageSetting(language, title, help, description)
end
