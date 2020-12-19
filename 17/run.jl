#!/usr/bin/env julia

import Base.Iterators: product

parseinput(filename) =
    let mgrid = mapfoldl(line->[line...] .== '#', hcat, eachline(filename))
        rows, cols = size(mgrid)
        IdDict((j, i, 0) => mgrid[i, j] for i ∈ 1:rows for j ∈ 1:cols)
    end

neighbors(grid, pos) =
    (npos => get(grid, npos, false)
     for npos ∈ product(map(x->x-1:x+1, pos)...)
     if npos ≠ pos)

update(grid) =
    let tgrid = copy(grid)
        for (pos, _) ∈ grid, (npos, state) ∈ neighbors(grid, pos)
            tgrid[npos] = state
        end
        newgrid = copy(tgrid)
        for (pos, state) ∈ tgrid
            active = count(last, neighbors(tgrid, pos))
            newgrid[pos] = state ? 2 ≤ active ≤ 3 : active == 3
        end
        newgrid
    end

exhaust(grid, n = 6) = n == 0 ? grid : exhaust(update(grid), n - 1)
augment(grid, x = 0) = IdDict((pos..., x) => state for (pos, state) ∈ grid)

if abspath(PROGRAM_FILE) == @__FILE__
    grid = parseinput(joinpath(@__DIR__, "input.txt"))
    println(count(last, exhaust(grid)))
    println(count(last, exhaust(augment(grid))))
end
