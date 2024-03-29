# Getting Started
Welcome to the CitrusBuilder *Getting Started* section! 
CitrusBuilder is a Julia package that allows you to construct LimeSurveys within Julia export their XML structure.
The exported `.lss` files can then be imported into a running LimeSurvey instance.

Surveys can be imported by using

1. LimeSurveys [import functionality](https://manual.limesurvey.org/Surveys_-_introduction#Import_a_survey), or 
2. the [RemoteControl 2 API](https://manual.limesurvey.org/RemoteControl_2_API).

If you are interested in calling the LimeSurvey RemoteControl 2 API from Julia, you can take a look at [CitrusAPI.jl](https://github.com/p-gw/CitrusAPI.jl).

## Installation
### Release version
To install CitrusBuilder from the official Julia package registry simply call 

```julia
pkg> add CitrusBuilder
```

### Development version
If you require unreleased features or want to develop CitrusBuilder you can install the most recent version from GitHub.

To install the package execute the following commands, which will install CitrusBuilder from the `main` branch of the GitHub repository.

```julia
using Pkg
Pkg.add(url="https://github.com/p-gw/CitrusBuilder.jl", rev="main")
```

!!! note
    Please note that CitrusBuilder.jl is currently under active development. 
    Therefore the provided API is subject to change. 
    Keep this in mind if you wish to use CitrusBuilder in your project.

## Now what?
Now that you have installed CitrusBuilder you can start building your surveys!

Just call 

```@example getting-started
using CitrusBuilder
```

from the Julia REPL. 
You can now define your survey structure by calling the [`survey`](@ref) function. 
In this simple example we construct an empty survey with the survey id `123456` and the title *"Getting started with CitrusBuilder"*. 

```@example getting-started
my_survey = survey(123456, "Getting started with CitrusBuilder")
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

- Expand the basic survey structure by adding other [question types](lib/functions.md#Question) to your survey,
- Learn how to create [multi-language surveys](tutorials/multi_language.md),
- Learn how to [dynamically generate surveys from data](tutorials/from_data.md), or 
- Learn how to create [custom question types](tutorials/custom_question_types.md).

