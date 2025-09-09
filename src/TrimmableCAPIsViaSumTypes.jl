module TrimmableCAPIsViaSumTypes

import LinearAlgebra: Diagonal
import Moshi.Data: @data
@data MyMatrix{T<:Number} begin
    DenseMat(Matrix{T})
    DiagMat(Diagonal{T, Vector{T}})  # <- Make sure this is a concrete type. `Diagonal{T}` wouldn't be enough.
end

module MatType
    using CEnum
    @cenum Enum::Cint begin
        dense = 1
        diag = 2
    end
end

function build_matrix(sz::Integer, ptr::Ptr{Cdouble}, mattype::MatType.Enum)::MyMatrix.Type{Cdouble}
    if mattype == MatType.dense
        # Unsafe pointer logic to create the Matrix
        m_dense = unsafe_wrap(Matrix{Cdouble}, ptr, (sz, sz))
        return MyMatrix.DenseMat(m_dense) # Wrap it in the sum type variant
    elseif mattype == MatType.diag
        m_diag = Diagonal(unsafe_wrap(Vector{Cdouble}, ptr, sz))
        return MyMatrix.DiagMat(m_diag) # Wrap it
    else
        error("Unmatched MatType")
    end
end

import Base: sum
import Moshi.Match: @match
function sum(m::MyMatrix.Type{T})::T where {T}
    @match m begin
        MyMatrix.DenseMat(mat) => sum(mat)
        MyMatrix.DiagMat(mat) => sum(mat)
    end
end

import Base: @ccallable
@ccallable function matrixsum_cc(sz::Cint, ptr::Ptr{Cdouble}, mattype::MatType.Enum)::Cdouble
    m = build_matrix(sz, ptr, mattype)
    return sum(m)
end

using LightSumTypes
@sumtype MyMatrix2{T}(
    Matrix{T},
    Diagonal{T, Vector{T}}
)

# even simpler now
sum(m::MyMatrix2{T}) where {T} = sum(variant(m))

function build_matrix2(sz::Integer, ptr::Ptr{Cdouble}, mattype::MatType.Enum)
    if mattype == MatType.dense
        # Unsafe pointer logic to create the Matrix
        m_dense = unsafe_wrap(Matrix{Cdouble}, ptr, (sz, sz))
        return MyMatrix2(m_dense) # Wrap it in the sum type variant
    elseif mattype == MatType.diag
        m_diag = Diagonal(unsafe_wrap(Vector{Cdouble}, ptr, sz))
        return MyMatrix2{Float64}(m_diag) # Wrap it
    else
        error("Unmatched MatType")
    end
end

@ccallable function matrixsum2_cc(sz::Cint, ptr::Ptr{Cdouble}, mattype::MatType.Enum)::Cdouble
    m = build_matrix2(sz, ptr, mattype)
    return sum(m)
end

end
#=
using JET
densemat = rand(3,3)
@test_opt matrixsum_cc(Cint(3), pointer(densemat), MatType.dense)
diagmat = Diagonal(rand(3))
@test_opt matrixsum_cc(Cint(3), pointer(diagmat.diag), MatType.diag)
@test_opt matrixsum2_cc(Cint(3), pointer(diagmat.diag), MatType.diag)
=#
