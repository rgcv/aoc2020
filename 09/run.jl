#!/usr/bin/env julia

module day1
export findtwosum
include(joinpath(dirname(@__DIR__), "01/run.jl")) # findtwosum
end
using .day1

invalidnumber(ns, m = 25) =
    let this(i) =
           isnothing(findtwosum(ns[i], ns[i - m:i - 1])) ? ns[i] : this(i + 1)
        this(m + 1)
    end

findweakness(ns, n) =
    let i = findfirst(==(n), ns) - 1,
        this(i, j, total) =
            total == n ? sum(extrema(ns[i + 1:j])) :
            total >  n ? this(i, j - 1, total - ns[j]) :
                         this(i - 1, j, total + ns[i])
        this(i, i, 0)
    end

if abspath(PROGRAM_FILE) == @__FILE__
    ns = parse.(Int, eachline(joinpath(@__DIR__, "input.txt")))
    # part 1
    println(invalidnumber(ns))
    # part 2
    println(findweakness(ns, invalidnumber(ns)))
end
