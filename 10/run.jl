#!/usr/bin/env julia

joltprod(jolts) =
    let diffs = [jolts[i + 1] - jolts[i] for i ∈ 1:length(jolts) - 1]
        count(==(1), diffs) * count(==(3), diffs)
    end

graphfromjolts(jolts) =
    let rjs = reverse(jolts),
        l = length(rjs),
        G = IdDict{Int,Array{Int}}()
        for (i, u) ∈ enumerate(rjs)
            get!(G, u, Int[])
            for v ∈ @view rjs[i + 1:l]
                v + 3 ≥ u || continue
                push!(G[u], v)
            end
        end
        G
    end

countpaths(G, u, v, paths = IdDict{Int,Int}()) =
    u == v ? 1 :
    begin
        if get!(paths, u, 0) == 0
            for t ∈ G[u]
                paths[u] += countpaths(G, t, v, paths)
            end
        end
        paths[u]
    end

if abspath(PROGRAM_FILE) == @__FILE__
    jolts = sort!(parse.(Int, eachline(joinpath(@__DIR__, "input.txt"))))
    push!(pushfirst!(jolts, 0), jolts[end] + 3)
    # part 1
    println(joltprod(jolts))
    # part 2
    countpaths(graphfromjolts(jolts), jolts[end], jolts[1])
end
