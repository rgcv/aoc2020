#!/usr/bin/env julia

const forest = readlines(joinpath(@__DIR__, "input.txt"))

treecount(forest, dx = 3, dy = 1) =
    let w = length(forest[1]),
        h = length(forest)
        count(enumerate(dy + 1:dy:h)) do (i, j)
            forest[j][mod1(dx * i + 1, w)] == '#'
        end
    end

# part 1
println(treecount(forest))

# part 2
treecount.([forest],
           [1 3 5 7 1],
           [1 1 1 1 2]) |> prod |> println
