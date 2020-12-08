#!/usr/bin/env julia

mutable struct Program
    acc::Int
    pc::Int
    code::Array{String}
    visited::Array{Bool}

    Program(code::AbstractVector{<:AbstractString}) =
        new(0, 1, copy(string.(code)), zeros(Bool, length(code)))
end

const program = Program(readlines(joinpath(@__DIR__, "input.txt")))

getacc(p::Program) = p.acc
islooping(p::Program) = p.visited[p.pc]
terminated(p::Program) = p.pc > size(p)

Base.copy(p::Program) = Program(copy(p.code))
Base.reset(p::Program) = Program(p.code)
Base.getindex(p::Program, i::Integer) = p.code[i]
Base.setindex!(p::Program, v, i::Integer) = p.code[i] = v
Base.length(p::Program) = length(p.code)
Base.size(p::Program) = length(p)

run(p::Program) = run!(copy(p))
run!(p::Program) =
    let order = 0
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
        run!(p)
        for i ∈ 1:size(p)
            p = reset(p)
            op, _ = split(p[i])
            newop = op == "jmp" ? "nop" :
                    op == "nop" ? "jmp" :
                    op
            newop == op && continue
            p[i] = replace(p[i], op => newop)
            run!(p)
            terminated(p) && break
            p.code = copy(oldcode)
        end
        p
    end


program |> run |> getacc |> println
program |> fix |> run |> getacc |> println
