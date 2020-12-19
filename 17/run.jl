#!/usr/bin/env julia

import Base.Iterators: product

parseinput(filename) =
    let mgrid = map(line->map(==('#'), collect(line)), eachline(filename))
        rows, cols = length(mgrid), length(mgrid[1])
        IdDict((j, i, 0) => mgrid[i][j] for i ∈ 1:rows for j ∈ 1:cols)
    end

neighbors(grid::AbstractDict{T,<:Any}, t::T) where {N,T<:NTuple{N,Int}} =
    (k => get(grid, k, false) for k ∈ product(map(v->v-1:v+1, t)...) if k ≠ t)

augment(grid, x = 0) = IdDict((k..., x) => v for (k, v) ∈ grid)
update(grid) =
    let tgrid = copy(grid)
        for (k, v) ∈ grid, (k1, v1) ∈ neighbors(grid, k)
            tgrid[k1] = v1
        end
        newgrid = copy(tgrid)
        for (k, v) ∈ tgrid
            as = count(last, neighbors(tgrid, k))
            newgrid[k] = v ? 2 ≤ as ≤ 3 : as == 3
        end
        newgrid
    end

exhaust(grid, n = 6) = n == 0 ? grid : exhaust(update(grid), n - 1)

begin#if abspath(PROGRAM_FILE) == @__FILE__
    grid = parseinput(joinpath(@__DIR__, "input.txt"))
    println(count(last, exhaust(grid)))
    println(count(last, exhaust(augment(grid))))
end
