# Getting Started
Welcome to the LimeSurveyBuilder *Getting Started* section! 
LimeSurveyBuilder is a Julia package that allows you to construct LimeSurveys within Julia export their XML structure.
The exported `.lss` files can then be imported into a running LimeSurvey instance.

Surveys can be imported by using

1. LimeSurveys [import functionality](https://manual.limesurvey.org/Surveys_-_introduction#Import_a_survey), or 
2. the [RemoteControl 2 API](https://manual.limesurvey.org/RemoteControl_2_API).

If you are interested in calling the LimeSurvey RemoteControl 2 API from Julia, you can take a look at [LimeSurveyAPI.jl](https://github.com/p-gw/LimeSurveyAPI.jl).

## Installation
At the current stage LimeSurveyBuilder is under development and is not registered in the Julia General repository. 
In order to install the package you have to install it from GitHub.

To install the package open a Julia REPL and execute the following commands, which will install LimeSurveyBuilder from the `main` branch of the GitHub repository.

```julia
using Pkg
Pkg.add(url="https://github.com/p-gw/LimeSurveyBuilder.jl", rev="main")
```

!!! note
    Please note that LimeSurveyBuilder.jl is currently under active development. 
    Therefore the provided API is subject to change. 
    Keep this in mind if you wish to use LimeSurveyBuilder in your project.

## Now what?
Now that you have installed LimeSurveyBuilder you can start building your surveys!

Just call 

```@example getting-started
using LimeSurveyBuilder
```

from the Julia REPL. 
You can now define your survey structure by calling the [`survey`](@ref) function. 
In this simple example we construct an empty survey with the survey id `123456` and the title *"Getting started with LimeSurveyBuilder"*. 

```@example getting-started
my_survey = survey(123456, "Getting started with LimeSurveyBuilder")
```

We can then construct question groups and questions and [`append!`](@ref) them to the survey.

```@example getting-started
group1 = question_group(1, "first question group")
append!(my_survey, group1)

question1 = short_text_question("q1", "My first question")
append!(group1, question1)

my_survey
```

For a more detailed introduction to survey construction you can start by working through the tutorial on [constructing a basic survey](tutorials/basic.md). 
This should give you the basic toolset to create your own surveys as fast as possible. 

Once you are familiar with the basic syntax, you can continue depending on how you want to use this package. Either, 

- Expand the basic survey structure by adding other [question types](question_types.md) to your survey,
- Learn how to create [multi-language surveys](tutorials/multi_language.md),
- Learn how to [dynamically generate surveys from data](tutorials/from_data.md), or 
- Learn how to create [custom question types](tutorials/custom_question_types.md).

