#!/usr/bin/env julia

parseinput(filename) =
    let timestamp, buses = NTuple{2,Int}[]
        open(filename) do io
            timestamp = parse(Int, readline(io))
            foreach(enumerate(split(readline(io), ","))) do (i, bid)
                bid ≠ "x" || return
                push!(buses, (i, parse(Int, bid)))
            end
        end
        timestamp, buses
    end

earliestbus(timestamp, busids, id = first(busids), left = typemax(id)) =
    isempty(busids) ? (id, left) :
    let newid = first(busids),
        newleft = newid - (timestamp % newid)
        newleft < left ?
            earliestbus(timestamp, @view(busids[2:end]), newid, newleft) :
            earliestbus(timestamp, @view(busids[2:end]), id, left)
    end

unzip(A) = (getfield.(A, x) for x ∈ fieldnames(eltype(A)))
earliestcontiguous(buses) = # FIXME: doc/revise half-assed CRT implementation
    let (is, bids) = unzip(buses),
        product = prod(bids),
        rems = bids .- (is .- 1),
        partial = product .÷ bids,
        invmods = invmod.(partial, bids)
        sum(@. partial * invmods * rems) % product
    end

if abspath(PROGRAM_FILE) == @__FILE__
    timestamp, buses = parseinput(joinpath(@__DIR__, "input.txt"))
    println(prod(earliestbus(timestamp, getindex.(buses, 2))))
    println(earliestcontiguous(buses))
end
