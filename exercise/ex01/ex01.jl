#-*- encoding: utf-8 -*-
# linear interpolation
# more info: https://github.com/myuuuuun/oyama_seminar2016/tree/master/exercise/ex01
# 
# Copyright (c) 2016 @myuuuuun
# Released under the MIT license.


module Ex01

immutable LinInterp
    grid::Array
    vals::Array
end

function Base.call(points::LinInterp, x::Real)
    grid = points.grid; vals = points.vals
    lower_index = searchsortedlast(points.grid, x)
    upper_index = lower_index + 1
    if lower_index == 0 || lower_index == length(grid)
        return NaN
    end

    grid_step = grid[upper_index] - grid[lower_index]
    val_step = vals[upper_index] - vals[lower_index]
    iterp_val = vals[lower_index] + (val_step / grid_step)* (x - grid[lower_index])

    return iterp_val
end

function Base.call{T<:Real}(points::LinInterp, x_array::Vector{T})
    grid = points.grid; vals = points.vals
    size = length(grid)
    interp_vals = Vector{T}()
    
    for x in x_array
        lower_index = searchsortedlast(points.grid, x)
        upper_index = lower_index + 1
        if lower_index == 0 || lower_index == length(grid)
            push!(interp_vals, NaN)
        else
            grid_step = grid[upper_index] - grid[lower_index]
            val_step = vals[upper_index] - vals[lower_index]
            push!(interp_vals, vals[lower_index] + (val_step / grid_step)* (x - grid[lower_index]))
        end
    end

    return interp_vals
end

end