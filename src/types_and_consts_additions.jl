# These are the additions to the types_and_consts.jl file not from clang.jl

function Base.convert(::Type{Matrix}, J::DlsMat)
    _dlsmat = unsafe_load(J)
    # own is false as memory is allocated by sundials
    unsafe_wrap(Array, _dlsmat.data, (_dlsmat.M, _dlsmat.N), own = false)
end

CVRhsFn_wrapper(fp::CVRhsFn) = fp
CVRhsFn_wrapper(f) = @cfunction($f, Cint, (realtype, N_Vector, N_Vector, Ptr{Cvoid})).ptr

ARKRhsFn_wrapper(fp::ARKRhsFn) = fp
ARKRhsFn_wrapper(f) = @cfunction($f, Cint, (realtype, N_Vector, N_Vector, Ptr{Cvoid})).ptr

CVRootFn_wrapper(fp::CVRootFn) = fp
CVRootFn_wrapper(f) =
    @cfunction($f, Cint, (realtype, N_Vector, Ptr{realtype}, Ptr{Cvoid})).ptr

CVQuadRhsFn_wrapper(fp::CVQuadRhsFn) = fp
CVQuadRhsFn_wrapper(f) =
    @cfunction($f, Cint, (realtype, N_Vector, N_Vector, Ptr{Cvoid})).ptr

IDAResFn_wrapper(fp::IDAResFn) = fp
IDAResFn_wrapper(f) =
    @cfunction($f, Cint, (realtype, N_Vector, N_Vector, N_Vector, Ptr{Cvoid})).ptr

IDARootFn_wrapper(fp::IDARootFn) = fp
IDARootFn_wrapper(f) =
    @cfunction($f, Cint, (realtype, N_Vector, N_Vector, Ptr{realtype}, Ptr{Cvoid})).ptr

KINSysFn_wrapper(fp::KINSysFn) = fp
KINSysFn_wrapper(f) = @cfunction($f, Cint, (N_Vector, N_Vector, Ptr{Cvoid})).ptr

function Base.convert(::Type{Matrix}, J::SUNMatrix)
    _sunmat = unsafe_load(J)
    _mat = convert(SUNMatrixContent_Dense, _sunmat.content)
    mat = unsafe_load(_mat)
    # own is false as memory is allocated by sundials
    unsafe_wrap(Array, mat.data, (mat.M, mat.N), own = false)
end

function Base.convert(::Type{SparseArrays.SparseMatrixCSC}, J::SUNMatrix)
    _sunmat = unsafe_load(J)
    _mat = convert(SUNMatrixContent_Sparse, _sunmat.content)
    mat = unsafe_load(_mat)
    # own is false as memory is allocated by sundials
    # TODO: Get rid of allocation for 1-based index change
    rowval = unsafe_wrap(Array, mat.indexvals, (mat.NNZ), own = false)
    colptr = unsafe_wrap(Array, mat.indexptrs, (mat.NP + 1), own = false)
    colptr .+= 1
    m = mat.M
    n = mat.N
    nzval = unsafe_wrap(Array, mat.data, (mat.NNZ), own = false)
    SparseArrays.SparseMatrixCSC(m, n, colptr, rowval, nzval)
end

abstract type SundialsMatrix end
struct DenseMatrix <: SundialsMatrix end
struct BandMatrix <: SundialsMatrix end
struct SparseMatrix <: SundialsMatrix end

abstract type SundialsLinearSolver end
struct Dense <: SundialsLinearSolver end
struct Band <: SundialsLinearSolver end
struct SPGMR <: SundialsLinearSolver end
struct SPFGMR <: SundialsLinearSolver end
struct SPBCGS <: SundialsLinearSolver end
struct PCG <: SundialsLinearSolver end
struct PTFQMR <: SundialsLinearSolver end
struct KLU <: SundialsLinearSolver end
struct LapackBand <: SundialsLinearSolver end
struct LapackDense <: SundialsLinearSolver end

abstract type SundialsNonLinearSolver end
struct Newton <: SundialsNonLinearSolver end
struct FixedPoint <: SundialsNonLinearSolver end

abstract type StiffnessChoice end
struct Explicit <: StiffnessChoice end
struct Implicit <: StiffnessChoice end
