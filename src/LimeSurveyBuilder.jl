module LimeSurveyBuilder

using Base: @kwdef
using Base: prepend!
using Base: insert!
using Base: append!
using EzXML

export survey, question_group
export subquestion
export response_option, response_scale, point_scale
export short_text_question, long_text_question, huge_text_question, multiple_short_text_question
export single_choice_question, five_point_choice_question, dropdown_list_question, radio_list_question
export multiple_choice_question
export array_five_point_choice_question, array_ten_point_choice_question, array_question
export date_select, file_upload, gender_select, language_switch, numerical_input, multiple_numerical_input
export id, children, code, question
export xml
export type

const DEFAULT_LANGUAGE = Ref("en")

function set_default_language!(lang::String)
    @info "LimeSurvey default language set to '$(lang)'."
    DEFAULT_LANGUAGE[] = lang
    return nothing
end

include("utils.jl")
include("survey_component.jl")
include("response_scale.jl")
include("subquestion.jl")
include("question.jl")
include("question_group.jl")
include("survey.jl")
include("xml.jl")

end
