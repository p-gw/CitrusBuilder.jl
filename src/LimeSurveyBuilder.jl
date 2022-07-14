module LimeSurveyBuilder

using Base: @kwdef
using Base: prepend!
using Base: insert!
using Base: append!
import Base: write
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

# global settings
export default_language
export set_default_language!

# AbstractSurveyComponent
export id
export languages
export title
export relevance
export type
export help
export description
export default

export has_help
export has_description
export same_default
export has_default

# language settings
export language_setting
export language_settings

# response options
export response_option
export response_scale
export is_default
export default

# subquestions
export subquestion

# question
export is_mandatory
export has_other
export has_subquestions
export has_response_options
export has_attributes
export attributes

export short_text_question
export long_text_question
export huge_text_question
export multiple_short_text_question
export five_point_choice_question
export dropdown_list_question
export radio_list_question
export multiple_choice_question
export array_five_point_choice_question
export array_ten_point_choice_question
export array_yes_no_question
export array_increase_decrease_question
export array_question
export date_select
export file_upload
export gender_select
export language_switch
export numerical_input
export multiple_numerical_input
export ranking
export text_display
export yes_no_question
export equation

# xml
export xml

include("survey_component.jl")
include("utils.jl")
include("language_settings.jl")
include("response_scale.jl")
include("subquestion.jl")
include("question.jl")
include("question_group.jl")
include("survey.jl")
include("xml.jl")

end
