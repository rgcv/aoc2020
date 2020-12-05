#!/usr/bin/env julia

const map = readlines(joinpath(@__DIR__, "input.txt"))

treecount(map, dx = 3, dy = 1) =
    let w = length(map[1]),
        h = length(map)
        count(enumerate(dy + 1:dy:h)) do (i, j)
            map[j][mod1(dx * i + 1, w)] == '#'
        end
    end

# part 1
println(treecount(map))

# part 2
treecount.([map],
           [1 3 5 7 1],
           [1 1 1 1 2]) |> prod |> println
