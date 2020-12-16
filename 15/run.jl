#!/usr/bin/env julia

memorygame(ns, target = 2020) =
    let lastseen = IdDict{Int,Int}(),
        len = length(ns),
        cur = ns[end]

        foreach(enumerate(ns[1:end-1])) do (i, n)
            lastseen[n] = i
        end
        resize!(ns, target)

        for turn ∈ len:target - 1
            i = get!(lastseen, cur, turn)
            lastseen[cur] = turn
            cur = turn - i 
            ns[turn + 1] = cur
        end

        ns[target]
    end

if abspath(PROGRAM_FILE) == @__FILE__
    input = [0, 13, 16, 17, 1, 10, 6]
    println(memorygame(input))
    println(memorygame(input, 30000000))
end
