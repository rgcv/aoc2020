#!/usr/bin/env julia

mutable struct Program
    acc::Int
    pc::Int
    code::Array{String}
    visited::Array{Bool}
    function Program(acc::Int,
                     pc::Int,
                     code::AbstractVector{<:AbstractString},
                     visited::AbstractVector{Bool})
        @boundscheck let len = length(code)
            1 ≤ pc ≤ len + 1 ||
            throw(ErrorException("program counter goes beyond program end"))
            length(visited) == len ||
            throw(ErrorException("`visited` vector must be the same length as the code (=$len)"))
        end
        new(acc, pc, string.(code), visited)
    end
end
Program(code::AbstractVector{<:AbstractString}) =
    @inbounds Program(0, 1, code, falses(length(code)))

getacc(p::Program) = p.acc
islooping(p::Program) = p.visited[p.pc]
terminated(p::Program) = p.pc > size(p)
reset!(p::Program) = (p.acc = 0; p.pc = 1; p.visited .= false; p)

Base.copy(p::Program) = Program(p.acc, p.pc, copy(p.code), copy(p.visited))
Base.getindex(p::Program, i::Integer) = p.code[i]
Base.length(p::Program) = length(p.code)
Base.setindex!(p::Program, v, i::Integer) = p.code[i] = v
Base.size(p::Program) = length(p)
Base.reset(p::Program) = reset!(copy(p))

run(p::Program) = run!(copy(p))
function run!(p::Program)
    while !terminated(p) && !islooping(p)
        p.visited[p.pc] = true
        op, arg = split(p[p.pc])
        arg = parse(Int, arg)
        op == "acc" && (p.acc += arg)
        p.pc += op == "jmp" ? arg : 1
    end 
    p
end

fix(p::Program) = fix!(copy(p))
fix!(p::Program) =
    let oldcode = copy(p.code)
        for i ∈ 1:size(p)
            op, _ = split(p[i])
            newop = op == "jmp" ? "nop" :
                    op == "nop" ? "jmp" :
                    op
            newop == op && continue
            p[i] = replace(p[i], op => newop)
            run!(p)
            terminated(p) && break
            p = Program(copy(oldcode))
        end
        p
    end

let program = Program(readlines(joinpath(@__DIR__, "input.txt")))
    program |> run |> getacc |> println # part 1
    program |> fix |> run |> getacc |> println # part 2
end
