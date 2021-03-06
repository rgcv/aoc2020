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

Base.copy(p::Program) =
    @inbounds Program(p.acc, p.pc, copy(p.code), copy(p.visited))
Base.getindex(p::Program, i::Integer) = p.code[i]
Base.length(p::Program) = length(p.code)
Base.setindex!(p::Program, v, i::Integer) = p.code[i] = v
Base.size(p::Program) = length(p)

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
            terminated(run(p)) && break
            p[i] = replace(p[i], newop => op)
        end
        p
    end

if abspath(PROGRAM_FILE) == @__FILE__
    program = Program(readlines(joinpath(@__DIR__, "input.txt")))
    # part 1
    println(getacc(run(program)))
    # part 2
    println(getacc(run(fix(program))))
end
