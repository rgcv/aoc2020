#!/usr/bin/env julia

import Base.Threads: @threads, Atomic, atomic_max!

const filename = joinpath(@__DIR__, "input.txt")

lowerhalf(r::AbstractUnitRange) = first(r):(first(r) + last(r)) ÷ 2
upperhalf(r::AbstractUnitRange) = 1 + (first(r) + last(r)) ÷ 2:last(r)

seatid(seat::AbstractString,
       rows::AbstractUnitRange = 0:127,
       cols::AbstractUnitRange = 0:7) =
    isempty(seat) ? 8minimum(rows) + maximum(cols) :
    let c = seat[1]
        seatid(SubString(seat, 2),
               c == 'F' ? lowerhalf(rows) :
               c == 'B' ? upperhalf(rows) : rows,
               c == 'L' ? lowerhalf(cols) :
               c == 'R' ? upperhalf(cols) : cols)
    end

# part 1
highestseatid(filename, parallel = false) =
    !parallel ? maximum(seatid, eachline(filename)) :
    let maxid = Atomic{Int}(typemin(Int))
        @threads for seat ∈ readlines(filename)
            atomic_max!(maxid, seatid(seat))
        end
        maxid[]
    end

println(highestseatid(filename))

# part 2
findid(filename) =
    let s = sort(map(seatid, eachline(filename))),
        prev = first(s)
        for e ∈ s[2:end]
            e - prev == 2 && return prev + 1
            prev = e
        end
    end

println(findid(filename))
