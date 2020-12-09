#!/usr/bin/env julia

import Base.Threads: @threads, Atomic, atomic_max!

lowerhalf(r) = first(r):(first(r) + last(r)) ÷ 2
upperhalf(r) = 1 + (first(r) + last(r)) ÷ 2:last(r)

seatid(seat, rows = 0:127, cols = 0:7) =
    isempty(seat) ? 8minimum(rows) + maximum(cols) :
    let c = seat[1]
        seatid(SubString(seat, 2),
               c == 'F' ? lowerhalf(rows) :
               c == 'B' ? upperhalf(rows) : rows,
               c == 'L' ? lowerhalf(cols) :
               c == 'R' ? upperhalf(cols) : cols)
    end

highestseatid(filename, parallel = false) =
    !parallel ? maximum(seatid, eachline(filename)) :
    let maxid = Atomic{Int}(typemin(Int))
        @threads for seat ∈ readlines(filename)
            atomic_max!(maxid, seatid(seat))
        end
        maxid[]
    end

findid(filename) =
    let s = sort(map(seatid, eachline(filename))),
        prev = first(s)
        for e ∈ s[2:end]
            e - prev == 2 && return prev + 1
            prev = e
        end
    end

if abspath(PROGRAM_FILE) == @__FILE__
    filename = joinpath(@__DIR__, "input.txt")
    # part 1
    println(highestseatid(filename))
    # part 2
    println(findid(filename))
end
