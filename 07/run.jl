#!/usr/env/bin julia

parsebags(filename) =
    let bagmap = Dict{String,Array{Pair{String,Int}}}()
        for line ∈ eachline(filename)
            root = match(r"(.*?) bags contain", line).captures[1]
            start = SubString(line, last(findlast("contain ", line)))
            children = match.(r"(\d+) (.*?) bags?[,.]?$", split(start, ","))
            foreach(children) do child
                get!(bagmap, root, [])
                if !isnothing(child)
                    count, name = child.captures
                    push!(bagmap[root], string(name) => parse(Int, count)) 
                end
            end
        end
        bagmap
    end

dfs(graph, root, visited = []) =
    let total = 0
        root ∈ visited || push!(visited, root)
        foreach(graph[root]) do (child, count)
            _, nc = dfs(graph, child, visited)
            total += count * (nc + 1)
        end
        visited, total
    end
dfs(graph) = root -> dfs(graph, root)

alldfs(graph) = map(dfs(graph), [keys(graph)...])

if abspath(PROGRAM_FILE) == @__FILE__
    filename = joinpath(@__DIR__, "input.txt")
    # part 1
    println(count(path -> "shiny gold" ∈ path[2:end],
                first.(alldfs(parsebags(filename)))))
    # part 2
    println(last(dfs(parsebags(filename), "shiny gold")))
end
