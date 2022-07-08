# Creating custom question types

Sometimes it can be useful to create a custom question type if a certain type of question is used several times.

As an example take a `dropdown_list_question`, which requires the participants to make a comment only if a certain response option is chosen. A custom question type can simply be created by defining a custom function that provides the desired output. In this case we want to return a `Tuple` of questions consisting of one `dropdown_list_question` for selecting the response option and one `short_text_question` that is dynamically shown or hidden dependent on the response given.

!!! note
    Dynamically showing question makes use of LimeSurveys [relevance equations](https://manual.limesurvey.org/ExpressionScript_-_Presentation). Relevance equations for questions can be set using the `relevance` keyword argument.


```@example custom_types
using LimeSurveyBuilder  # hide

function dropdown_with_comment(id, title, options, show_comment)
    dropdown = dropdown_list_question("$(id)", title, options)
    comment = short_text_question("$(id)comment", "Please enter your comment here.", relevance="{$(id)}==$(show_comment)")
    return (dropdown, comment)
end;
```

We can now use this new question type to query for the survey participants favourite food and making them comment on their choice only if their favourite food item is pizza.

```@example custom_types
food_options = response_scale([
    response_option("p", "Pizza"),
    response_option("b", "Burger"),
    response_option("s", "Sushi")
])

food_survey = survey(100000, "A survey on food") do
    question_group(1, "") do
        dropdown_with_comment("favorite", "What's your favourite food?", food_options, "p")
    end
end
```