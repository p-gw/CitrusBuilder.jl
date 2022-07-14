```@meta
CurrentModule = LimeSurveyBuilder
```

# Functions

## Index
```@index
Pages = ["functions.md"]
```

## Constructors
### Survey
```@docs
survey
```

### QuestionGroup
```@docs
question_group
```

### Question
LimeSurveyBuilder.jl provides convencience constructors for all question types described in the [LimeSurvey Manual](https://manual.limesurvey.org/Question_types).

#### Text Questions
```@docs
short_text_question
long_text_question
huge_text_question
multiple_short_text_question
```

#### Single Choice Questions
```@docs
five_point_choice_question
dropdown_list_question
radio_list_question
```

#### Multiple Choice Questions
```@docs
multiple_choice_question
```

#### Array Questions
```@docs
array_five_point_choice_question
array_ten_point_choice_question
array_yes_no_question
array_increase_decrease_question
array_question
```
#### Mask Questions
```@docs
date_select
file_upload
gender_select
language_switch
numerical_input
multiple_numerical_input
ranking
text_display
yes_no_question
equation
```

### SubQuestion
```@docs
subquestion
```

## Accessors
### Question
```@docs
is_mandatory
has_other
has_subquestions
has_response_options
has_attributes
attributes
```

## IO
```@docs
write
```