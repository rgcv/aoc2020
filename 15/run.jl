#!/usr/bin/env julia

memorygame!(ns, target = 2020) =
    let cache = IdDict{Int,Int}(),
        turn = length(ns),
        cur = ns[end]

        resize!(ns, target)
        for (i, n) ∈ enumerate(ns[1:turn - 1]) cache[n] = i end

        while turn < target
            last = get!(cache, cur, turn)
            cache[cur] = turn
            cur = turn - last 
            ns[turn += 1] = cur
        end

        ns[target]
    end

if abspath(PROGRAM_FILE) == @__FILE__
    input = [0, 13, 16, 17, 1, 10, 6]
    println(memorygame!(input))
    println(memorygame!(input, 30000000))
end
