# Exercise1

線形補間をするコードを書く.  
詳細: [https://github.com/OyamaZemi/exercises2017/tree/master/ex01](https://github.com/OyamaZemi/exercises2017/tree/master/ex01)

## 作ったもの

* [Demo](http://nbviewer.jupyter.org/github/myuuuuun/oyama_seminar2016/blob/master/exercise/ex01/ex01_demo.ipynb)
* [Package](https://github.com/myuuuuun/MInterpolations)

## モジュールのインポート方法

exp(x)を線形補間して, exp(1.5)を求める例

```
Pkg.clone("https://github.com/myuuuuun/MInterpolations.jl")
using MInterpolations
grid = linspace(0, 10, 11)
val = exp(grid)
myinterp = MInterpolations.LinInterp(grid, val)
println(myinterp(1.5))
```

## 参考

* [Sorting and Related Functions](http://docs.julialang.org/en/release-0.4/stdlib/sort/) - Julia documentation
* [Types](http://docs.julialang.org/en/release-0.4/manual/types/) - Julia documentation
* [Introducing Julia/Arrays and tuples](https://en.wikibooks.org/wiki/Introducing_Julia/Arrays_and_tuples) - Julia wiki
* [Learn Julia in ? minutes](https://learnxinyminutes.com/docs/julia/)
* [Gadfly](http://dcjones.github.io/Gadfly.jl/)
* [Map, Filter, Reduce in Julia](https://mmstickman.wordpress.com/2015/01/30/map-filter-and-reduce-in-julia/)