require("strpack")

module Sundials

typealias __builtin_va_list Ptr{:Void}

shlib = :libsundials_nvecserial
include("nvector.jl")
shlib = :libsundials_cvode
include("sundials.jl")
include("cvode.jl")
shlib = :libsundials_cvodes
include("cvodes.jl")
shlib = :libsundials_ida
include("ida.jl")
shlib = :libsundials_idas
include("idas.jl")
shlib = :libsundials_kinsol
include("kinsol.jl")

nvlength(x::N_Vector) = unsafe_ref(unsafe_ref(convert(Ptr{Ptr{Int64}}, x)))
asarray(x::N_Vector) = pointer_to_array(N_VGetArrayPointer_Serial(x), (nvlength(x),))
asarray(x::Vector{realtype}) = x
asarray(x::Ptr{realtype}, dims::Tuple) = pointer_to_array(x, dims)
asarray(x::N_Vector, dims::Tuple) = reinterpret(realtype, asarray(x), dims)
nvector(x::Vector{realtype}) = N_VMake_Serial(length(x), x)
nvector(x::N_Vector) = x

KINInit(mem, sysfn::Function, y) =
    KINInit(mem, cfunction(sysfn, Int32, (N_Vector, N_Vector, Ptr{Void})), nvector(y))
KINSetConstraints(mem, constraints::Vector{realtype}) =
    KINSetConstraints(mem, nvector(constraints))
KINSol(mem, u::Vector{realtype}, strategy, u_scale::Vector{realtype}, f_scale::Vector{realtype}) =
    KINSol(mem, nvector(u), strategy, nvector(u_scale), nvector(f_scale))

IDAInit(mem, res::Function, t0, yy0, yp0) =
    IDAInit(mem, cfunction(res, Int32, (realtype, N_Vector, N_Vector, N_Vector, Ptr{Void})), t0, nvector(yy0), nvector(yp0))
IDARootInit(mem, nrtfn, g::Function) =
    IDARootInit(mem, nrtfn, cfunction(g, Int32, (realtype, N_Vector, N_Vector, Ptr{realtype}, Ptr{Void})))
IDASVtolerances(mem, reltol, abstol::Vector{realtype}) =
    IDASVtolerances(mem, reltol, nvector(abstol))
IDADlsSetDenseJacFn(mem, jac::Function) =
    IDADlsSetDenseJacFn(mem, cfunction(jac, Int32, (Int32, realtype, realtype, N_Vector, N_Vector, N_Vector, DlsMat, Ptr{Void}, N_Vector, N_Vector, N_Vector)))
IDASetId(mem, id::Vector{realtype}) =
    IDASetId(mem, nvector(id))
IDASetConstraints(mem, constraints::Vector{realtype}) =
    IDASetConstraints(mem, nvector(constraints))
IDASolve(mem, tout, tret, yret::Vector{realtype}, ypret::Vector{realtype}, itask) =
    IDASolve(mem, tout, tret, nvector(yret), nvector(ypret), itask)

CVodeInit(mem, f::Function, t0, y0) =
    CVodeInit(mem, cfunction(f, Int32, (realtype, N_Vector, N_Vector, Ptr{Void})), t0, nvector(y0))
CVodeSVtolerances(mem, reltol, abstol::Vector{realtype}) =
    CVodeSVtolerances(mem, reltol, nvector(abstol))
CVodeRootInit(mem, nrtfn, g::Function) =
    CVodeRootInit(mem, nrtfn, cfunction(g, Int32, (realtype, N_Vector, Ptr{realtype}, Ptr{Void})))
CVDlsSetDenseJacFn(mem, jac::Function) =
    CVDlsSetDenseJacFn(mem, cfunction(jac, Int32, (Int32, realtype, N_Vector, N_Vector, DlsMat, Ptr{Void}, N_Vector, N_Vector, N_Vector)))
CVode(mem, tout, yout::Vector{realtype}, tret, itask) =
    CVode(mem, tout, nvector(yout), tret, itask)

end # module 
