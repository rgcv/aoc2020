#!/usr/bin/env julia

const input_path = joinpath(@__DIR__, "input.txt")
const groups = split.(split(read(input_path, String), "\n\n"))

# part 1
println(mapreduce(length, +, union(g...) for g ∈ groups))

# part 2
println(mapreduce(length, +, intersect(g...) for g ∈ groups))
