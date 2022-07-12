# Getting Started
Welcome to the LimeSurveyBuilder.jl getting started section! 
LimeSurveyBuilder.jl is a Julia package that allows you to construct LimeSurveys within Julia export their XML structure.
The exported `.lss` files can then be imported into a running LimeSurvey instance.

Surveys can be imported by using

1. the provided [import functionality](https://manual.limesurvey.org/Surveys_-_introduction#Import_a_survey), or 
2. the [RemoteControl 2 API](https://manual.limesurvey.org/RemoteControl_2_API).

If you are interested in calling the LimeSurvey API from Julia, you can take a look at [LimeSurveyAPI.jl](https://github.com/p-gw/LimeSurveyAPI.jl).

## Installation
At the current stage of development LimeSurveyBuilder.jl is not registered in the Julia General repository. 
In order to install the package you have to install it from GitHub.

To install the package open a Julia REPL and execute the following commands, that will install LimeSurveyBuilder.jl from the `main` branch of the GitHub repository.

```julia
using Pkg
Pkg.add(url="https://github.com/p-gw/LimeSurveyBuilder.jl", rev="main")
```

!!! note
    Please note that LimeSurveyBuilder.jl is currently under active development. 
    Therefore the provided API is subject to change. 
    Keep this in mind if you wish to use LimeSurveyBuilder.jl in your project.

## Now what?
Now that you have installed LimeSurveyBuilder.jl you can start building your surveys!

Just call 

```julia
using LimeSurveyBuilder
```

in the Julia REPL.

To create your first survey using this package I suggest to start with the tutorial on [constructing a basic survey](tutorials/basic.md). 
This should give you the basic toolset to create your own surveys as fast as possible. 

Once you are familiar with the basic syntax, you can continue depending on how you want to use this package. Either, 

- Expand the basic survey structure by adding other [question types](question_types.md) to your survey,
- Learn how to create [multi-language surveys](tutorials/multi_language.md),
- Learn how to [dynamically generate surveys from data](tutorials/from_data.md), or 
- Learn how to create [custom question types](tutorials/custom_question_types.md).
