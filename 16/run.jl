#!/usr/bin/env julia

using Base.Iterators

struct Field
    name::String
    ranges::NTuple{2,UnitRange{Int}}
    Field(line::AbstractString) =
        let m = match(r"(.+): (\d+)-(\d+) or (\d+)-(\d+)", line)
            length(m.captures) == 5 || throw(ArgumentError("invalid field: $line"))
            name, s1, e1, s2, e2 = m.captures
            new(name,
                (parse(Int, s1):parse(Int, e1),
                 parse(Int, s2):parse(Int, e2)))
        end
end
name(x::Field) = x.name
ranges(x::Field) = x.ranges

Base.:(==)(x::Field, y::Field) = name(x) == name(y) && ranges(x) == ranges(y)
Base.hash(x::Field, h::UInt) = hash(ranges(x), hash(name(x), h))
Base.in(x::Integer, f::Field) = any(Int(x) .∈ ranges(f))

showrange(r::AbstractUnitRange) = join(extrema(r), "-")
showranges(x::Field) = join(showrange.(ranges(x)), " or ")
Base.show(io::IO, x::Field) = 
    print(io, "$(typeof(x))($(name(x)): $(showranges(x)))")

parseinput(filename) =
    let itr = eachline(filename)
        fs = map(Field, takewhile(!isempty, itr))
        iterate(itr)
        t = parse.(Int, split(iterate(itr)[1], ","))
        iterate(drop(itr, 1))
        fs, t, map(line -> parse.(Int, split(line, ",")), itr)
    end

invalidfields(t, fs) = filter(v->!any(v ∈ f for f ∈ fs), t)
invalidsum(ts, fs) = sum(first, filter(!isempty, invalidfields.(ts, [fs])))

isvalid(t, fs) = isempty(invalidfields(t, fs))
isvalid(fs) = t -> isvalid(t, fs)
validtickets(ts, fs) = filter(isvalid(fs), ts)
orderedfields(ts, fs) =
    let cands = IdDict(f => Set(1:length(fs)) for f ∈ fs)
        for f ∈ fs, t ∈ ts, i ∈ values(cands[f])
            t[i] ∈ f || delete!(cands[f], i) 
        end
        ks = sort!([keys(cands)...], by=k->length(cands[k]))
        for i ∈ length(ks):-1:2
            setdiff!(cands[ks[i]], cands[ks[i-1]])
        end
        sort!([keys(cands)...], by=k->first(cands[k]))
    end
depprod(t, ts, fs) =
    let ofs = orderedfields(validtickets(ts, fs), fs)
        prod(t[findall(startswith("departure"), map(name, ofs))])
    end

if abspath(PROGRAM_FILE) == @__FILE__
    fs, t, ts = parseinput(joinpath(@__DIR__, "input.txt"))
    println(invalidsum(ts, fs))
    println(depprod(t, ts, fs))
end
