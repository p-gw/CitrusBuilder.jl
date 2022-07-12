# Constructing basic surveys

LimeSurveyBuilder.jl offers two different modes of survey building. Both modes of construction are suitable for different use cases. To create simple surveys the survey structure can be created at once by using the `do ... end` syntax. All survey components that have child elements, e.g. [`survey`](@ref), [`question_group`](@ref) or [`multiple_short_text_question`](@ref), do allow for this method of construction.


Let's imagine we want to create a simple survey for an introductory statistics class where we want to gather data on the *age* (in years), *gender*, and *height* (in cm) of the students. 

In order to accomplish this, we need to construct a survey with 
1. A [`gender_select`](@ref), 
2. A [`numerical_input`](@ref) for the participants age,
3. A [`numerical_input`](@ref) for the participants height

!!! note 
    LimeSurvey requires that questions are nested within a question group. In order to construct a valid survey we must respect this restriction even if no question grouping is needed.

```@example
using LimeSurveyBuilder # hide

statistics_survey = survey(100000, "Statistics 101 survey") do
    question_group(1, "") do  # this is a dummy question group, no title needed
        gender_select("gender", "Please select your gender."),
        numerical_input("age", "Please state your age in years.", minimum=18, integer_only=true),
        numerical_input("height", "Please state your height in centimeters.", minimum=0, maximum=250, integer_only=true)
    end
end
```

For the [`numerical_input`](@ref) questions we also imposed several restrictions provided by LimeSurvey: 

1. *age* must be at least 18 and can only have integer values,
2. *height* must be a non-negative integer with a maximum height of 250cm.

Now that the survey is complete, it can be exported to an `.lss` file.

```julia
write("statistics_101.lss", statistics_survey)
```

## Alternative approach
An alternative to the basic survey construction outlined in the previous section is to build the survey iteratively. LimeSurveyBuilder.jl overloads the Julia Base functions [`append!`](@ref), [`insert!`](@ref), and [`prepend!`](@ref). These functions can be used to append, insert or prepend survey components to a survey respectively. 

Consider again the example from the previous section: A survey gathering data on the *age*, *gender*, and *height* of the survey participants. Using this approach we first must construct a survey,

```@example basic_bang
using LimeSurveyBuilder  # hide
statistics_survey = survey(100000, "Statistics 101 survey")
```

Now we can define and append the required question group to the survey, 

```@example basic_bang
g1 = question_group(1, "")
append!(statistics_survey, g1)

statistics_survey
```

Questions can then be appended to the question group `g1`. 

```@example basic_bang
append!(g1, gender_select("gender", "Please select your gender."))
append!(g1, numerical_input("age", "Please state your age in years.", minimum=18, integer_only=true))
append!(g1, numerical_input("height", "Please state your height in centimeters.", minimum=0, maximum=250, integer_only=true))

statistics_survey
```

Again, we can export the survey to an `.lss` file using [`write`](@ref).

```julia
write("statistics_101.lss", statistics_survey)
```
