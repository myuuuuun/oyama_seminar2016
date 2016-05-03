#-*- encoding: utf-8 -*-
# linear interpolation
# more info: https://github.com/myuuuuun/oyama_seminar2016/tree/master/exercise/ex01
# 
# Copyright (c) 2016 @myuuuuun
# Released under the MIT license.


module Ex01

type LinInterp
    grid::Array
    vals::Array
end

function Base.call(points::LinInterp, x)
    grid = points.grid; vals = points.vals
    lower_index = searchsortedlast(points.grid, x)
    upper_index = lower_index + 1
    if lower_index == 0 || lower_index == length(grid)
        throw(DomainError())
    end

    grid_step = grid[upper_index] - grid[lower_index]
    val_step = vals[upper_index] - vals[lower_index]
    iterp_val = vals[lower_index] + (val_step / grid_step)* (x - grid[lower_index])

    return iterp_val
end

end