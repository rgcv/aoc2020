#!/usr/bin/env julia

parseinput(filename) =
    let t, bs = Pair{Int,Int}[]
        open(filename) do io
            t = parse(Int, readline(io))
            foreach(enumerate(split(readline(io), ","))) do (i, id)
                id ≠ "x" || return
                push!(bs, i => parse(Int, id))
            end
        end
        t, bs
    end

earliestbus(t, ns, id = first(ns), w = typemax(id)) =
    isempty(ns) ? (id, w) :
    let n = first(ns),
        nw = n - (t % n)
        nw < w ?
            earliestbus(t, @view(ns[2:end]), n, nw) :
            earliestbus(t, @view(ns[2:end]), id, w)
    end

unzip(A) = (getfield.(A, x) for x ∈ fieldnames(eltype(A)))
earliestsequence(bs) =
    let (is, ns) = (first.(bs) .- 1, last.(bs)),
        p = prod(ns),
        as = ns .- is,
        Ns = p .÷ ns,
        Ms = invmod.(Ns, ns)
        sum(as .* Ms .* Ns) % p
    end

if abspath(PROGRAM_FILE) == @__FILE__
    t, bs = parseinput(joinpath(@__DIR__, "input.txt"))
    println(prod(earliestbus(t, last.(bs))))
    println(earliestsequence(bs))
end
