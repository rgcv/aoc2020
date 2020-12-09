#!/usr/bin/env julia

twosum(target, numbers, sorted=issorted(numbers)) =
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
        0, 0
    end

threesum(target, numbers) =
    let s = issorted(numbers) ? numbers : sort(numbers),
        l = length(numbers)
        for (i, a) ∈ enumerate(s)
            b, c = twosum(target - a, s[i + 1:l], true)
            if a ≠ target && a + b + c == target
                return a, b, c
            end
        end
        0, 0, 0
    end

if !isinteractive()
    expenses = parse.(Int, readlines(joinpath(@__DIR__, "input.txt")))
    # part 1
    println(prod(twosum(2020, expenses)))
    # part 2
    println(prod(threesum(2020, expenses)))
end
