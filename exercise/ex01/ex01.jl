#-*- encoding: utf-8 -*-
# linear interpolation
# more info: https://github.com/myuuuuun/oyama_seminar2016/tree/master/exercise/ex01
# 
# Copyright (c) 2016 @myuuuuun
# Released under the MIT license.


module GaleShapley

immutable LinInterp
    grid::Array
    vals::Array
end

function Base.call(points::LinInterp, x::Real)
    grid = points.grid; vals = points.vals
    lower_index = searchsortedlast(points.grid, x)

    # 補外に対応
    if lower_index == 0 
        lower_index = 1
    elseif lower_index == length(grid)
        lower_index = length(grid) - 1
    end

    upper_index = lower_index + 1
    grid_step = grid[upper_index] - grid[lower_index]
    val_step = vals[upper_index] - vals[lower_index]
    iterp_val = vals[lower_index] + (val_step / grid_step) * (x - grid[lower_index])

    return iterp_val
end

function Base.call{T<:Real}(points::LinInterp, x_array::Vector{T})
    grid = points.grid; vals = points.vals
    size = length(grid)
    interp_vals = Array(T, size)
    
    for (i, x) in zip(1:size, x_array)
        interp_vals[i] = points(x)
    end

    return interp_vals
end

end