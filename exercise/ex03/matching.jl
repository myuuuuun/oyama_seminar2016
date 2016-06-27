#-*- encoding: utf-8 -*-
# deffered acceptance
# more info: https://github.com/myuuuuun/oyama_seminar2016/tree/master/exercise/ex02
# 
# Copyright (c) 2016 @myuuuuun
# Released under the MIT license.


module Matching # begin module
    export argsort, gale_shapley, gale_shapley_T, is_stable_matching,
            find_all_stable_matchings, make_f_matched_from_m_matched


using DataStructures


#= Type: RowMajorMatrix

行列を転置した行列のviewを作る
=#
type RowMajorMatrix{T} <: AbstractMatrix{T}
    data::AbstractMatrix{T}
end

Base.getindex(a::RowMajorMatrix, i::Int, j::Int) = a.data[j, i]

type Matched2d
    matched::AbstractArray{Integer, 1}
    indptr::AbstractArray{Integer, 1}
end

function Base.size(a::RowMajorMatrix)
    col_size = size(a.data)[1]
    row_size = size(a.data)[2]
    return (row_size, col_size)
end

function  Matched2d(caps)
    indptr = ones(Integer, length(caps)+1)
    cms = cumsum(caps)
    for i in 2:length(caps)+1
        indptr[i] += cms[i-1]
    end
    return Matched2d(zeros(Integer, sum(caps)), indptr)
end

function Base.getindex(a::Matched2d, i::Integer, j::Integer)
    if i < 1 || length(a.indptr) < i || j < 1 || a.indptr[i+1] - a.indptr[i] < j
        throw(BoundsError)
    end
    return a.matched[a.indptr[i]+j-1]
end

function Base.setindex!(a::Matched2d, m::Integer, i::Integer, j::Integer)
    if i < 1 || length(a.indptr) < i || j < 1 || a.indptr[i+1] - a.indptr[i] < j
        throw(BoundsError)
    end
    a.matched[a.indptr[i]+j-1] = m
end

function argsort{T<:Integer}(array::AbstractVector{T})
    #=1次元配列をArgument Sortする
    
    配列をSortした後, その要素が元あった場所のIndexを返す
    例: [1, 3, 4, 2, 0] -> [5, 1, 4, 2, 3]
    タイの順位には非対応
    =#
    
    array_with_index = Array{T}(length(array), 2)
    for i in 1:length(array)
        array_with_index[i, 1] = array[i]
        array_with_index[i, 2] = i
    end
    sorted_array_with_index = sortrows(array_with_index, by=x->x[1])
    return sorted_array_with_index[:, 2]
end

function argsort{T<:Integer}(array::AbstractArray{T, 2})
    #=2次元配列をArgument Sortする
    
    それぞれの行毎にargsortする.
    例: [1 3 4 2 0;
        　　　1 2 0 4 3]
    
    　->　[5 1 4 2 3;
        　　　3 1 2 5 4]
    =#
    
    row = size(array)[1]
    col = size(array)[2]
    argsorted = Array{T}(size(array))
    for i in 1:row
        out = argsort(squeeze(array[i, :], 1))
        for j in 1:col
            argsorted[i, j] = out[j]
        end
    end
    return argsorted
end

function gale_shapley{T<:Integer}(
    prop_prefs::AbstractArray{T, 2}, 
    resp_prefs::AbstractArray{T, 2},
    caps::AbstractArray{T, 1})

    # 第1次元（行）のサイズ = 受験者数, 大学数 を取得
    prop_size = size(prop_prefs, 1)
    resp_size = size(resp_prefs, 1)

    # 仮マッチング済相手を入れる（0をunmatch）
    prop_matched = zeros(Int64, prop_size)

    n_props = zeros(Int64, resp_size)
    resp_worst_matched = ones(Int64, resp_size)
    
    # 未処理の受験者を入れておくスタック
    stack = Stack(Int)
    for i in prop_size:-1:1
        push!(stack, i)
    end
    
    # 大学の選好を[受験者1の順位, 受験者2の順位,...] -> [1位の受験者の番号, 2位の受験者の番号,...] に変える
    prop_rankings = argsort(resp_prefs)

    # それぞれの受験者が何番目の大学まで受けたかを保存するリスト
    proposed = zeros(Int64, prop_size)
    
    while length(stack) != 0
        prop = pop!(stack)
        
        for i in proposed[prop]+1:resp_size
            proposed[prop] += 1
            resp = prop_prefs[prop, i]

            # 順位表が終わりまで来たら探索終了
            if resp == 0
                break
            end
            
            worst = resp_worst_matched[resp]
            # 大学が定員に達していない場合, 大学にとって受験者がacceptableならマッチ
            if n_props[resp] < caps[resp]
                if prop_rankings[resp, prop+1] < prop_rankings[resp, 1]
                    prop_matched[prop] = resp
                    n_props[resp] += 1
                    if prop_rankings[resp, worst+1] < prop_rankings[resp, prop+1]
                        resp_worst_matched[resp] = prop
                    end
                    break
                end
                
            # 定員が埋まっている場合, 受験者が現在のworst受験者よりもランクが高ければマッチ
            else
                if prop_rankings[resp, prop+1] < prop_rankings[resp, worst+1]
                    prop_matched[prop] = resp
                    prop_matched[worst] = 0
                    push!(stack, worst)
                    worst = prop
                    
                    # worstを探す
                    for p in 1:prop_size
                        if prop_matched[prop] == resp && prop_rankings[resp, worst+1] < prop_rankings[resp, p+1]
                            worst = p
                        end
                        resp_worst_matched[resp] = worst
                    end
                    break
                end
            end
            
        end
    end

    resp_matched = Matched2d(n_props)
    n_props[:] = 0

    for p in 1:prop_size
        resp = prop_matched[p]

        if resp != 0 
            n_props[resp] += 1
            resp_matched[resp, n_props[resp]] = p
        end
    end
    return prop_matched, resp_matched.matched, resp_matched.indptr
end

function gale_shapley_T{T<:Integer}(
    prop_prefs::AbstractArray{T, 2}, 
    resp_prefs::AbstractArray{T, 2},
    caps::AbstractArray{T, 1})
    
    prop_prefs_T = RowMajorMatrix(prop_prefs)
    resp_prefs_T = RowMajorMatrix(resp_prefs)
    return gale_shapley(prop_prefs_T, resp_prefs_T, caps)
end

function gale_shapley{T<:Integer}(
    prop_prefs::AbstractArray{T, 2}, 
    resp_prefs::AbstractArray{T, 2})
    
    c_size = size(resp_prefs, 1)
    caps = ones(Int64, c_size)
    p, r, ind = gale_shapley(prop_prefs, resp_prefs, caps)
    
    r_matched = zeros(Int64, c_size)
    for i in 1:c_size
        if ind[i+1] - ind[i] != 0
            r_matched[i] = r[ind[i]]
        end
    end
    return p, r_matched
end

function gale_shapley_T{T<:Integer}(
    prop_prefs::AbstractArray{T, 2}, 
    resp_prefs::AbstractArray{T, 2})
    
    prop_prefs_T = RowMajorMatrix(prop_prefs)
    resp_prefs_T = RowMajorMatrix(resp_prefs)
    return gale_shapley(prop_prefs_T, resp_prefs_T)
end


end # end module
