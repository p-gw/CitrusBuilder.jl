using LimeSurveyBuilder
using Documenter

DocMeta.setdocmeta!(LimeSurveyBuilder, :DocTestSetup, :(using LimeSurveyBuilder); recursive=true)

makedocs(;
    modules=[LimeSurveyBuilder],
    authors="Philipp Gewessler",
    repo="https://github.com/p-gw/LimeSurveyBuilder.jl/blob/{commit}{path}#{line}",
    sitename="LimeSurveyBuilder.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://p-gw.github.io/LimeSurveyBuilder.jl",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "Survey Components" => [
            "Survey" => "survey.md",
            # "Question Group" => "",
            "Question" => "question_types.md"
        ],
        "Tutorials" => [
            "Overview" => "tutorials/index.md",
            "Construct basic surveys" => "tutorials/basic.md",
            "Construct multi-language surveys" => "tutorials/multi_language.md",
            "Construct surveys programmatically" => "tutorials/from_data.md",
            "Creating custom question types" => "tutorials/custom_question_types.md"
        ]
    ]
)

# deploydocs(;
#     repo="github.com/p-gw/LimeSurveyBuilder.jl",
#     devbranch="main"
# )