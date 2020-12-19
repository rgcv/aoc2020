#!/usr/bin/env julia

parseinput(filename) =
    let mgrid = map(line->map(==('#'), collect(line)), eachline(filename))
        rows, cols = length(mgrid), length(mgrid[1])
        IdDict((j, i, 0) => mgrid[i][j] for i ∈ 1:rows for j ∈ 1:cols)
    end

neighbors(grid, t::NTuple{3,Int}) where N = neighbors3d(grid, t...)
neighbors(grid, t::NTuple{4,Int}) where N = neighbors4d(grid, t...)
neighbors3d(grid, x, y, z) =
    [(i, j, k) => get(grid, (i, j, k), false)
     for i ∈ x-1:x+1, j ∈ y-1:y+1, k ∈ z-1:z+1
     if !(i == x && j == y && k == z)]
neighbors4d(grid, x, y, z, w) =
    [(i, j, k, l) => get(grid, (i, j, k, l), false)
     for i ∈ x-1:x+1, j ∈ y-1:y+1, k ∈ z-1:z+1, l ∈ w-1:w+1
     if !(i == x && j == y && k == z && l == w)]

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
