#!/usr/bin/env julia

validpassports(batch, part1 = true) =
    count(batch) do passport
        fields = map(split(passport, r"\s")) do field
            @inbounds split(field, ":")[1]
        end
        n = length(fields)
        part1 ? n == 8 || n == 7 && "cid" ∉ fields : all(occursin.([
            r"\bbyr:(?:19[2-9][0-9]|200[0-2])\b",
            r"\biyr:20(?:1[0-9]|20)\b",
            r"\beyr:20(?:2[0-9]|30)\b",
            r"\bhgt:(?:1(?:[5-8][0-9]|9[0-3])cm|(?:59|6[0-9]|7[0-6])in)\b",
            r"\bhcl:#[0-9a-f]{6}\b",
            r"\becl:(?:amb|blu|brn|gry|grn|hzl|oth)\b",
            r"\bpid:[0-9]{9}\b",
        ], passport))
    end

if abspath(PROGRAM_FILE) == @__FILE__
    batch = strip.(split(read(joinpath(@__DIR__, "input.txt"), String), "\n\n"))
    # part 1
    println(validpassports(batch))
    # part 2
    println(validpassports(batch, false))
end
