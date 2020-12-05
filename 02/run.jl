#!/usr/bin/env julia

struct Policy
    lo::Int
    hi::Int
    char::Char
end

const list = map(readlines(joinpath(@__DIR__, "input.txt"))) do line
    m = match(r"([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)", line)
    lo, hi = parse.(Int, m.captures[1:2])
    char = m.captures[3][1]
    Policy(lo, hi, char), m.captures[4]
end

# part 1
count(list) do (pol, pwd)
    count(==(pol.char), pwd) ∈ pol.lo:pol.hi
end |> println

# part 2
count(list) do (pol, pwd)
    (pwd[pol.lo] == pol.char) ⊻ (pwd[pol.hi] == pol.char)
end |> println
