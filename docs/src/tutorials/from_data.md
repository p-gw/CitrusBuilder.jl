# Constructing surveys programmatically

In this tutorial we will see how we can build surveys from an external data source. 
The iterative survey construction method in CitrusBuilder makes it easy to accomplish this task.

Consider for example that you have a csv file for each survey where each row defines a question in the survey. 
The questions might be default questions or more complex custom question types as described in the tutorial [Constructing custom question types](custom_question_types.md).

A sample csv file might look like this, 

```@example from-data
using CSV, DataFrames

data = CSV.read("sample.csv", DataFrame)
```

First, we need to match the *type* column of the data frame to a question type. 
In this example we define, 

- *text*: [`short_text_question`](@ref)
- *1-5*: [`five_point_choice_question`](@ref)

For convenience we can create a custom function that maps the string in the data frame to a [`CitrusBuilder.Question`](@ref)

```@example from-data
using CitrusBuilder

function question(type, args...; kwargs...)
    if type == "text"
        return short_text_question(args...; kwargs...)
    elseif type == "1-5"
        return five_point_choice_question(args...; kwargs...)
    else
        error("unknown question type")
    end
end
```

This function will return the required question type.
Now we can set up an empty survey,

```@example from-data
survey_from_data = survey(123456, "A survey from data")
```

and append an empty question group as required by LimeSurvey.

```@example from-data
g1 = append!(survey_from_data, question_group(1, ""))
```

All that is left to do is to append questions by iterating over each row in the data frame.

```@example from-data
for row in eachrow(data)
    q = question(row.type, "q" * string(row.position), string(row.title), mandatory=row.mandatory)
    append!(g1, q)
end

survey_from_data
```
