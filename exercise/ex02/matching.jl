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

function Base.size(a::RowMajorMatrix)
    col_size = size(a.data)[1]
    row_size = size(a.data)[2]
    return (row_size, col_size)
end

function argsort{T<:Int}(array::AbstractVector{T})
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

function argsort{T<:Int}(array::AbstractArray{T, 2})
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

function gale_shapley{T<:Int}(m_prefs::AbstractArray{T, 2}, f_prefs::AbstractArray{T, 2})
    #= Deferred Acceptance Algorithm
    
    男性の人数をm, 女性の人数をnとする
    Input:
        m_prefs: m * n+1 の行列. 各行には0〜nまでの数字が1つずつ入る.
        f_prefs: n * m+1 の行列 各行には0〜mまでの数字が1つずつ入る.

    Output:
        m_matched: 各男性のマッチング相手のリスト
        f_matched: 各女性のマッチング相手のリスト
    
    m_prefs[i, :]が男性iの選好順位表: 
        例) m_prefs[i, :] = [4, 3, 0, 1, 2]
    1番目に好きな女性が1, 2番目が3, ...
    0をunmatch flagとし, それ以降の男性とはマッチングしない.
    
    女性に関しても同様. male-optimalなstable matchingを返す.
    =#

    # 第1次元（行）のサイズ = 男, 女の人数 を取得
    m_size = size(m_prefs, 1)
    f_size = size(f_prefs, 1)
    
    # 仮マッチング済相手を入れる（0をunmatch）
    m_matched = zeros(Int64, m_size)
    f_matched = zeros(Int64, f_size)
    
    # 未処理の男を入れておくスタック
    stack = Stack(Int)
    for i in m_size:-1:1
        push!(stack, i)
    end
    
    # 女の選好を[男1の順位, 男2の順位,...] -> [1位の男の番号, 2位の男の番号,...] に変える
    male_rankings = argsort(f_prefs)

    # それぞれの男が何番目の女まで告白したかを保存するリスト
    proposed = zeros(Int64, m_size)
    
    while length(stack) != 0
        male = pop!(stack)
        
        for i in proposed[male]+1:f_size
            proposed[male] += 1

            # 順位表が終わりまで来たら探索終了
            if m_prefs[male, i] == 0
                break
            end
            
            female = m_prefs[male, i]
            # 女性が誰ともマッチしていない場合, 女性にとって男性がacceptableならマッチ
            if f_matched[female] == 0 && male_rankings[female, male+1] < male_rankings[female, 1]
                m_matched[male] = female
                f_matched[female] = male
                break
            # 誰かとマッチしている場合, 男性が現在のパートナーよりもランクが高ければマッチ
            else
                current_partner = f_matched[female]
                if male_rankings[female, male+1] < male_rankings[female, current_partner+1]
                    m_matched[male] = female
                    f_matched[female] = male
                    m_matched[current_partner] = 0
                    push!(stack, current_partner)
                    break
                end
            end
        end
    end
    return m_matched, f_matched
end

function gale_shapley_T{T<:Int}(m_prefs::AbstractArray{T, 2}, f_prefs::AbstractArray{T, 2})
    #= 選好表が転置して与えられた場合用のDA
    
    男性の人数をm, 女性の人数をnとする
    Input:
        m_prefs: n+1 * m の行列
        f_prefs: m+1 * n の行列
    =#
    m_prefs_T = RowMajorMatrix(m_prefs)
    f_prefs_T = RowMajorMatrix(f_prefs)
    return gale_shapley(m_prefs_T, f_prefs_T)
end

function is_valid_matching{T<:Int}(
    #= 男女それぞれがunacceptableな相手とmatchingしてないかチェック
    =#

    m_matched::AbstractVector{T}, f_matched::AbstractVector{T},
    m_prefs::AbstractArray{T, 2}, f_prefs::AbstractArray{T, 2},
    print_blocking::Bool=true)

    m_size = size(m_prefs, 1)
    f_size = size(f_prefs, 1)
    f_rankings = argsort(m_prefs)
    m_rankings = argsort(f_prefs)
    
    for m in 1:m_size
        if f_rankings[m, 1] < f_rankings[m, m_matched[m]+1]
            if print_blocking
                println("Invalid matchings")
                println("For man: $(m), staying alone is better than matching with woman: $(m_matched[m]).")
            end
            return false
        end
    end

    for f in 1:f_size
        if m_rankings[f, 1] < m_rankings[f, f_matched[f]+1]
            if print_blocking
                println("Invalid matchings")
                println("For woman: $(f), staying alone is better than matching with man: $(f_matched[f]).")
            end
            return false
        end
    end

    return true
end

function is_stable_matching{T<:Int}(
    m_matched::AbstractVector{T}, f_matched::AbstractVector{T},
    m_prefs::AbstractArray{T, 2}, f_prefs::AbstractArray{T, 2},
    print_blocking::Bool=true)
    
    m_size = size(m_prefs, 1)
    f_size = size(f_prefs, 1)
    f_rankings = argsort(m_prefs)
    m_rankings = argsort(f_prefs)

    if !is_valid_matching(m_matched, f_matched, m_prefs, f_prefs, print_blocking)
        return false
    end

    for m in 1:m_size
        for i in 1:f_size
            f = m_prefs[m, i]

            if f == m_matched[m]
                break
            end

            m2 = f_matched[f]

            if m_rankings[f, m+1] < m_rankings[f, m2+1]
                if print_blocking
                    println("Find a blocking pair. man: $(m) woman: $(f)")
                end
                return false
            end
        end
    end

    return true
end

function make_f_matched_from_m_matched{T<:Int}(m_matched::AbstractVector{T}, m_size::Int, f_size::Int)
    f_matched = zeros(Int, f_size)

    for i in 1:m_size
        if m_matched[i] != 0
            f_matched[m_matched[i]] = i
        end
    end
    return f_matched
end

function find_all_stable_matchings{T<:Int}(
    m_prefs::AbstractArray{T, 2}, f_prefs::AbstractArray{T, 2})

    m_size = size(m_prefs, 1)
    f_size = size(f_prefs, 1)

    stable_matchings = Set()

    # base matchingsを作る
    base_matchings = []

    if m_size > f_size
        min_zero = m_size - f_size
    else
        min_zero = 0
    end

    for n_zeros in min_zero:m_size
        n_nonzeros = m_size - n_zeros
        for c in combinations(collect(1:f_size), n_nonzeros)
            b = append!(zeros(Int64, n_zeros), c)
            push!(base_matchings, b)
        end
    end

    for b in base_matchings
        for m_matched in permutations(b)
            f_matched = make_f_matched_from_m_matched(m_matched, m_size, f_size)
            if is_stable_matching(m_matched, f_matched, m_prefs, f_prefs, false)
                push!(stable_matchings, m_matched)
            end
        end
    end

    return stable_matchings
end


end # end module
