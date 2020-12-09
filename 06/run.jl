#!/usr/bin/env julia

countanswers(op, groups) = mapreduce(length, +, op(g...) for g ∈ groups)

if !isinteractive()
    filename = joinpath(@__DIR__, "input.txt")
    groups = split.(split(read(filename, String), "\n\n"))
    # part 1
    println(countanswers(union, groups))
    # part 2
    println(countanswers(intersect, groups))
end
