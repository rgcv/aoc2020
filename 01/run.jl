#!/usr/bin/env julia

const expenses = parse.(Int, readlines(joinpath(@__DIR__, "input.txt")))

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
        for (i, n) ∈ enumerate(s)
            a, b = twosum(target - n, s[i + 1:l], true)
            if n ≠ target && a + b + n == target
                return a, b, n
            end
        end
        0, 0, 0
    end


println(prod(twosum(2020, expenses)))
println(prod(threesum(2020, expenses)))
