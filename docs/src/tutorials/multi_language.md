# Constructing multi-language surveys

In some cases [constructing basic surveys](basic.md) is insufficient and one is required to build multi-language surveys. Multi-language surveys can be created in CitrusBuilder.

As an example consider a continuation of the [Constructing basic surveys](basic.md) tutorial where we built a survey for a statistics 101 course. In this survey we asked for 

1. the gender, 
2. the age, and 
3. the height

of the survey participants.

In the following example our statistics 101 course is split into two groups: In the first group the course is held in German while in the second group the course is held in English. We still want to analyse the participants data together, so we create a single multi-language survey.

First, since the majority of our participants will be German-speaking we set the default language to German. 

```@example multi-language
using CitrusBuilder 

set_default_language!("de")
```

Then we can begin the survey construction following the previous tutorial. 
The difference is that instead of constructing our survey components using an `id` and a `title`, we now have to define titles for each language specifically. 
We can do this by providing [`language_settings`](@ref) instead of a simple title.

In addition to the three questions we also include a [`language_switch`](@ref) in the beginning of our survey. Our statistics survey constructor then looks like this: 

```@example multi-language
my_statistics_survey = survey(100000, language_settings([
    language_setting("de", "Statistik 101 Fragebogen"),
    language_setting("en", "Statistics 101 survey")
])) do
    question_group(1, "") do
        language_switch("language", language_settings([
            language_setting("de", "Bitte wähle eine Sprache aus."),
            language_setting("en", "Please select a language.")
        ])),
        gender_select("gender", language_settings([
            language_setting("de", "Bitte wähle dein Geschlecht aus."),
            language_setting("en", "Please select your gender.")
        ])),
        numerical_input("age", language_settings([
            language_setting("de", "Bitte gib dein Alter in Jahren an."),
            language_setting("en", "Please state your age in years.")
        ]), minimum=18, integer_only=true),
        numerical_input("height", language_settings([
            language_setting("de", "Bitte gib deine Größe in Zentimeter an."),
            language_setting("en", "Please state your height in centimeters.")
        ]), minimum=0, maximum=250, integer_only=true)
    end
end
```

Since we have to provide the localization for all survey languages, each component must contain at least a `title` for all languages. 

The completed survey can be exported to an `.lss` file using [`write`](@ref).

```julia
write("statistics_101_multi_language.lss", my_statistics_survey)
```

## Alternative approach
Just like in the [basic surveys](basic.md) tutorial we can make use of the alternative approach to survey construction. In this case we just have to substitute the single-language survey components with their multi-language equivalents. 

```@example multi-language_bang
using CitrusBuilder 

my_statistics_survey = survey(100000, language_settings([
    language_setting("de", "Statistik 101 Fragebogen"),
    language_setting("en", "Statistics 101 survey")
]))
```

After creating the survey, we can add the required question group

```@example multi-language_bang
g1 = question_group(1, "")
append!(my_statistics_survey, g1)

my_statistics_survey
```

Finally, the questions can be appended one by one.

```@example multi-language_bang
append!(g1, language_switch("language", language_settings([
    language_setting("de", "Bitte wähle eine Sprache aus."),
    language_setting("en", "Please select a language.")
])))

append!(g1, gender_select("gender", language_settings([
    language_setting("de", "Bitte wähle dein Geschlecht aus."),
    language_setting("en", "Please select your gender.")
])))
        
append!(g1, numerical_input("age", language_settings([
    language_setting("de", "Bitte gib dein Alter in Jahren an."),
    language_setting("en", "Please state your age in years.")
]), minimum=18, integer_only=true))

append!(g1, numerical_input("height", language_settings([
    language_setting("de", "Bitte gib deine Größe in Zentimeter an."),
    language_setting("en", "Please state your height in centimeters.")
]), minimum=0, maximum=250, integer_only=true))

my_statistics_survey
```

This approach will yield an identical survey. 
Again, to save the completed survey simply use [`write`](@ref).

```julia
write("statistics_101_multi_language.lss", my_statistics_survey)
```