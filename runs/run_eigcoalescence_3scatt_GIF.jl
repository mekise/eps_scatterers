include("../src/ScatterersDDA.jl")
using .ScatterersDDA
using LinearAlgebra
using NPZ
using ProgressMeter

ω = 1.
J = Stdd(1.)
normalized = false

## EP parameters ##
ϵ = 0.02
rspan = LinRange(sqrt(3)*π-ϵ, sqrt(3)*π+ϵ, 400)

###################
### Evaluated using Mathematica symbolic solution
### NB: there is a conj() in alphas[2] due to inconsistency with the matrix from mathematica.
###     With this conj() the 2 expressions coincide and we find the EP.
# G12 = 1/8/π^2
# alphas = [(1/2)*(1/G12 + ((3 + 2*sqrt(2))^(1/3)*Complex(G12^6)^(1/3))/G12^3 + G12/Complex(3*G12^6 + 2*sqrt(2)*G12^6)^(1/3))
#           conj(-((-2 + ((3 + 2*sqrt(2))^(1/3)*Complex(G12^6)^(1/3))/G12^2 + Complex(G12^6)^(2/3)/((3 + 2*sqrt(2))^(1/3)*G12^4)
#             + sqrt(6 - (3*Complex(G12^6)^(1/3))/((3 + 2*sqrt(2))^(2/3)*G12^2) - (3*Complex(3 + 2*sqrt(2))^(2/3)*Complex(G12^6)^(2/3))/G12^4))/(4*G12)))
#           (2 - ((3 + 2*sqrt(2))^(1/3)*Complex(G12^6)^(1/3))/G12^2 - G12^2/Complex(3*G12^6 + 2*sqrt(2)*G12^6)^(1/3) +
#             sqrt(6 - (3*(3 + 2*sqrt(2))^(2/3)*Complex(G12^6)^(2/3))/G12^4 - (3*G12^4)/Complex(3*G12^6 + 2*sqrt(2)*G12^6)^(2/3)))/(4*G12)]

###################
### Evaluated using NLsolve solution
alphas = [4.097994070917227 + 44.62923399165831im, 4.097994077696397 - 44.6292340056232im, -245.06649427967272 - 4.4749286681151824e-7im]
###################

## Evaluation ##
p = Progress(length(rspan));
Threads.@threads for k in eachindex(rspan)
    scattpos = [[-π 0. 0.]
                [0. rspan[k] 0.] # equidistant scatterers with G = 1/8/π^2
                [π 0. 0.]]
    eigs = eigvals(intmatrix(scattpos, alphas, ω, J; normalized=normalized, imagshift=1E-23))
    next!(p)
    npzwrite("./gif/gif"*string(k)*".npz", Dict("rspan" => rspan, "scattpos" => scattpos, "eigs" => eigs))
end