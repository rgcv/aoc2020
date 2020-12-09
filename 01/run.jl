#!/usr/bin/env julia

findtwosum(target, numbers, sorted=issorted(numbers)) =
    let s = sorted ? numbers : sort(numbers),
        i = 1,
        j = length(numbers)
        @inbounds while i < j
            sum = s[i] + s[j]
            if sum == target
                return s[i], s[j]
            elseif sum > target
                j -= 1
            else
                i += 1
            end
        end
    end

findthreesum(target, numbers) =
    let s = issorted(numbers) ? numbers : sort(numbers),
        l = length(numbers)
        for (i, a) ∈ enumerate(s)
            res = findtwosum(target - a, s[i + 1:l], true)
            if !isnothing(res)
                return a, res...
            end
        end
    end

if abspath(PROGRAM_FILE) == @__FILE__
    expenses = parse.(Int, readlines(joinpath(@__DIR__, "input.txt")))
    # part 1
    println(prod(findtwosum(2020, expenses)))
    # part 2
    println(prod(findthreesum(2020, expenses)))
end
