#!/usr/bin/env julia

abstract type Action end
abstract type Direction <: Action end
abstract type Rotation  <: Action end

# direction
struct North   <: Direction end
struct South   <: Direction end
struct East    <: Direction end
struct West    <: Direction end

struct Forward <: Direction end

# rotation
struct Left  <: Rotation end
struct Right <: Rotation end

abstract type Moveable end
macro moveable(name)
    quote
        struct $name <: Moveable
            position::Complex{Int}
            direction::Complex{Int}
        end
        $name(p::T, d::T) where T<:NTuple{2,<:Integer} =
            $name(complex(Int.(p)...), complex(Int.(d)...))
        $name(d::NTuple{2,<:Integer}) = $name((0, 0), d)
    end |> esc
end
@moveable Ship
@moveable Waypoint

position(m::Moveable)  = real(m.position),  imag(m.position)
direction(m::Moveable) = real(m.direction), imag(m.direction)

Base.show(io::IO, m::Moveable) =
    show(io, "$(typeof(m))($(position(m)), $(direction(m)))")

struct Instruction{A<:Action}
    value::Int
end
Base.parse(::Type{Instruction}, x::AbstractString) =
    let (action, value) = match(r"([NSEWFLR])(\d+)", x).captures
        A = action == "N" ? North :
            action == "S" ? South :
            action == "E" ? East  :
            action == "W" ? West  :
            action == "L" ? Left  :
            action == "R" ? Right :
            #=       "F" =# Forward
        Instruction{A}(parse(Int, value))
    end

apply(s::Moveable, i::Instruction{A}) where A = apply(s, A, i.value)
apply(s::Moveable, x, y) = s # nop
apply(s::Moveable, T::Type{<:Direction}, v) = move(s, T, v)
apply(s::Moveable, T::Type{<:Rotation},  v) = rotate(s, T, v ÷ 90)

move(m::Moveable, ::Type{Forward}, v) =
    typeof(m)(m.position + v * m.direction, m.direction)

rotate(m::Moveable, ::Type{Left},  v) =
    typeof(m)(m.position, m.direction * im^v)
rotate(m::Moveable, ::Type{Right}, v) =
    typeof(m)(m.position, Complex{Int}(m.direction / im^v))

move(s::Ship, ::Type{North}, v) = Ship(s.position + v * im, s.direction)
move(s::Ship, ::Type{South}, v) = Ship(s.position - v * im, s.direction)
move(s::Ship, ::Type{East},  v) = Ship(s.position + v, s.direction)
move(s::Ship, ::Type{West},  v) = Ship(s.position - v, s.direction)
move(w::Waypoint, ::Type{North}, v) = Waypoint(w.position, w.direction + v * im)
move(w::Waypoint, ::Type{South}, v) = Waypoint(w.position, w.direction - v * im)
move(w::Waypoint, ::Type{East},  v) = Waypoint(w.position, w.direction + v)
move(w::Waypoint, ::Type{West},  v) = Waypoint(w.position, w.direction - v)

manhattan(a::T, b::T) where T<:NTuple{2,<:Number} = sum(abs.(a .- b))
manhattan(m::Moveable, start = (0, 0)) = manhattan(position(m), start)

navigate(m::Moveable, is) = reduce(apply, is; init = m)

if abspath(PROGRAM_FILE) == @__FILE__
    is = parse.(Instruction, eachline(joinpath(@__DIR__, "input.txt")))
    println(manhattan(navigate(Ship((1, 0)), is)))
    println(manhattan(navigate(Waypoint((10, 1)), is)))
end
