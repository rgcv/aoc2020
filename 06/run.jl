#!/usr/bin/env julia

const filename = joinpath(@__DIR__, "input.txt")
const groups = split.(split(read(filename, String), "\n\n"))

countanswers(op::Function, groups) = mapreduce(length, +, op(g...) for g ∈ groups)

println(countanswers(union, groups)) # part 1
println(countanswers(intersect, groups)) # part 2
