# LimeSurveyBuilder.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://p-gw.github.io/LimeSurveyBuilder.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://p-gw.github.io/LimeSurveyBuilder.jl/dev)
[![Build Status](https://github.com/p-gw/LimeSurveyBuilder.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/p-gw/LimeSurveyBuilder.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/p-gw/LimeSurveyBuilder.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/p-gw/LimeSurveyBuilder.jl)

This Julia package provides utilities to construct surveys that can be uploaded to a running [LimeSurvey](https://www.limesurvey.org/) server. 

## Getting started
A minimal survey must contain a survey id and a title.

```julia
my_survey = survey(100000, "my survey title")
```
```
Survey with 0 groups and 0 questions.
my survey title (id: 100000)
```

To add question groups and questions to a survey the `do ... end` syntax can be used. Note that LimeSurvey requires that questions must be nested within question groups. 

If we want to create a basic survey asking for the name (using a short text question) and gender of the survey participants (using a dropdown select) we can use the following constructor,

```julia
gender_options = response_scale([
    response_option("f", "female"),
    response_option("m", "male")
])

basic_survey = survey(123456, "A basic survey") do
    question_group(1, "Basic participant information") do
        short_text_question("name", "Please state your full name.", mandatory=true),
        dropdown_list_question("gender", "Please select a gender.", gender_options, other=true, mandatory=true)
    end
end
```

which will yield 

```
Survey with 1 group and 2 questions.
A basic survey (id: 123456)
└── Basic participant information (id: 1)
    ├── Please state your full name. (id: name)
    └── Please select a gender. (id: gender)
```

To export your survey simply call `write`,

```
write("my_basic_survey.lss", basic_survey)
```

The resulting xml file can be imported on the server using the [LimeSurvey import function](https://manual.limesurvey.org/Surveys_-_introduction#Import_a_survey).

## Question types
`LimeSurveyBuilder.jl` aims to implement all LimeSurvey question types. Currently the following question types are available

- `short_text_question`
- `long_text_question`
- `huge_text_question`
- `multiple_short_text_question`
- `five_point_choice_question`
- `dropdown_list_question`
- `radio_list_question`
- `multiple_choice_question`
