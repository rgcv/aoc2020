#!/usr/bin/env julia

macro position(name)
    cname = Symbol(uppercase(string(name)))
    quote
        struct $name <: Position end
        const $cname = $name()
        $name() = $cname
    end |> esc
end

abstract type Position end

@position Empty
@position Occupied
@position Floor

Position(x::AbstractChar) = Position(string(x))
Position(x::AbstractString) =
    x == "L" ? Empty() :
    x == "#" ? Occupied() : Floor()

Base.isempty(::Position) = false
Base.isempty(::Empty) = true
isoccupied(::Position) = false
isoccupied(::Occupied) = true
isfloor(::Position) = false
isfloor(::Floor) = true

# helpful to display the grid
Base.show(io::IO, ::Empty   ) = show(io, "L")
Base.show(io::IO, ::Occupied) = show(io, "#")
Base.show(io::IO, ::Floor   ) = show(io, ".")
Base.transpose(x::Position) = x

directadjs(grid, i, j) =
    let (n, m) = size(grid),
        adjs = Position[]
        for di ∈ i-1:i+1, dj ∈ j-1:j+1
            di == i && dj == j && continue
            di ∈ 1:n && dj ∈ 1:m && push!(adjs, grid[di, dj])
        end
        adjs
    end

raycast(grid, coord, dir) =
    let (i, j) = coord
        !checkbounds(Bool, grid, i, j) ? nothing :
        !isfloor(grid[i, j]) ? grid[i, j] :
        raycast(grid, coord .+ dir, dir)
    end

visibleadjs(grid, i, j) =
    let (n, m) = size(grid),
        adjs = Position[]
        for di ∈ -1:1, dj ∈ -1:1
            di == dj == 0 && continue
            r = raycast(grid, (i+di, j+dj), (di, dj))
            isnothing(r) || push!(adjs, r)
        end
        adjs
    end

update(grid; adjs = directadjs, occpred = ≥(4)) =
    let (n, m) = size(grid),
        newgrid = copy(grid)
        for i ∈ 1:n, j ∈ 1:m
            occupied = count(isoccupied, adjs(grid, i, j))
            if isempty(grid[i, j]) && occupied == 0
                newgrid[i, j] = OCCUPIED
            elseif isoccupied(grid[i, j]) && occpred(occupied)
                newgrid[i, j] = EMPTY
            end
        end
        newgrid
    end

exhaust(grid; args...) =
    let rec(g, ng) = g == ng ? g : rec(ng, update(ng; args...))
        rec(grid, update(grid; args...))
    end

if abspath(PROGRAM_FILE) == @__FILE__
    grid = mapreduce(hcat, eachline(joinpath(@__DIR__, "input.txt"))) do line
        map(Position, collect(line))
    end
    println(count(isoccupied, exhaust(grid)))
    println(count(isoccupied, exhaust(grid; adjs = visibleadjs,
                                            occpred = ≥(5))))
end
