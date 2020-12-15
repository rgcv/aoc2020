#!/usr/bin/env julia

intfrombits(::Type{N}, x::BitVector) where N<:Integer =
    N(reduce((acc, y) -> acc + y[2] << (y[1] - 1), enumerate(x); init = 0))

abstract type AbstractBitMask{N} end
Base.copy(B::AbstractBitMask) = typeof(b)(copy(B.mask))
Base.length(::AbstractBitMask{N}) where N = N
Base.show(io::IO, B::AbstractBitMask) = show(io, string(B))
Base.:&(x::Signed, B::AbstractBitMask) = signed(unsigned(x) & B)
Base.:&(x::Unsigned, B::AbstractBitMask{N}) where N =
    let y = BitVector(digits(x, base = 2, pad = N))
        length(y) == N || throw(ArgumentError("$x is larger than $N bits"))
        z = BitVector(undef, N)
        foreach(i -> z[i] = applymask(B, i, y[i]), 1:N)
        intfrombits(typeof(x), z)
    end
permutations(B::AbstractBitMask{N}, x::Signed) where N =
    permutations(B, unsigned(x))
permutations(B::AbstractBitMask{N}, x::Unsigned) where N =
    permutations(B, BitVector(digits(x, base = 2, pad = N)))

struct BitMask{N} <: AbstractBitMask{N}
    mask::Array{Char}
    function BitMask(mask::AbstractString)
        isnothing(match(r"[^01X]", mask)) ||
            throw(ArgumentError("invalid mask: can only contain X, 0, or 1 characters"))
        new{length(mask)}(reverse(collect(mask)))
    end
end
Base.getindex(B::BitMask, i::Integer) = B.mask[i]
Base.string(B::BitMask) = join(reverse(B.mask))
applymask(B::BitMask, i::Integer, v) =
    let b = B[i]
        b == '0' ? 0 :
        b == '1' ? 1 :
        b == 'X' ? v : throw(ArgumentError("$b unsupported by $(nameof(B))"))
    end

struct FloatingBitMask{N} <: AbstractBitMask{N}
    mask::BitMask{N}
    FloatingBitMask(mask::AbstractString) = 
        let b = BitMask(mask)
            new{length(b)}(b)
        end
end
Base.getindex(B::FloatingBitMask, i::Integer) = B.mask[i]
Base.string(B::FloatingBitMask) = string(B.mask)
applymask(B::FloatingBitMask, i::Integer, v) =
    let b = B[i]
        b == '0' ? v :
        b == '1' ? 1 :
        b == 'X' ? v : throw(ArgumentError("$b unsupported by $(nameof(B))"))
    end
permutations(B::FloatingBitMask{N}, x::BitVector) where N =
    let is = findall(==('X'), string(B)),
        xs = Set{BitVector}()
        rec(is, x) =
            isempty(is) ? xs :
            let i = is[1],
                (y, z) = copy.((x, x))
                y[i] = 0
                z[i] = 1
                push!(xs, y, z)
                rec(@view(is[2:end]), y)
                rec(@view(is[2:end]), z)
            end
        collect(rec(is, x))
    end

store!(mem, a, B::BitMask, v) = (mem[a] = v & B; mem)
store!(mem, a, B::FloatingBitMask, v) =
    let nas = sort!(intfrombits.(typeof(v), permutations(B, a & B)))
        for na ∈ nas
            mem[na] = v
        end
        mem
    end
run(filename, T::Type{<:AbstractBitMask} = Type{BitMask}) =
    let mem = IdDict{Int,Int}(), mask, i, v
        foreach(eachline(filename)) do line
            if startswith(line, "mask")
                mask = T(split(line, "= ")[2])
            else
                a, v = parse.(Int, match(r"mem\[(\d+)\] = (\d+)", line).captures)
                store!(mem, a, mask, v)
            end
        end
        sum(values(mem))
    end

if abspath(PROGRAM_FILE) == @__FILE__
    filename = joinpath(@__DIR__, "input.txt")
    println(run(filename, BitMask))
    println(run(filename, FloatingBitMask))
end
