module LimeSurveyBuilder

using Base: @kwdef

export survey, question_group
export subquestion
export short_text_question, long_text_question, huge_text_question, multiple_short_text_question
export five_point_choice_question, dropdown_list_question, radio_list_question
export code, question

include("SurveyStructure.jl")
include("QuestionTypes.jl")

end
