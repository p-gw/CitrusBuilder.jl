isnumber(c::AbstractChar) = !isnothing(tryparse(Int, string(c)))
isalphanumeric(c::AbstractChar) = isletter(c) || isnumber(c)
validate(code::AbstractString) = isletter(first(code)) && all(isalphanumeric, code)

prefix(i, n) = i == n ? "└──" : "├──"
