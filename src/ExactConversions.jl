module ExactConversions

export mincommon, maxcommon, exactconv

"""
    mincommon(I, F) :: I
    mincommon(F, I) :: F

Return the smallest number that is representable by both the integral type `I` and the
floating-point type `F`. The type of the result depends on the order of the arguments.
"""
function mincommon end

"""
    maxcommon(I, F) :: I
    maxcommon(F, I) :: F

Return the largest number that is representable by both the integral type `I` and the
floating-point type `F`. The type of the result depends on the order of the arguments.
"""
function maxcommon end

# unsigned integral types

mincommon(U::Type{<:Unsigned}, F::Type{<:AbstractFloat})::U = zero(U)

mincommon(F::Type{<:AbstractFloat}, U::Type{<:Unsigned})::F = F(mincommon(U, F))

function maxcommon(U::Type{<:Unsigned}, F::Type{<:AbstractFloat})::U
    max_exp = min(8sizeof(U)-1, Base.exponent_max(F))
    num_ones = min(8sizeof(U), Base.significand_bits(F)+1)
    ones = (U(1) << num_ones) - U(1)
    ones << (max_exp - num_ones + 1)
end

maxcommon(F::Type{<:AbstractFloat}, U::Type{<:Unsigned})::F = F(maxcommon(U, F))

# signed integral types

function mincommon(S::Type{<:Signed}, F::Type{<:AbstractFloat})::S
    if 8sizeof(S)-1 <= Base.exponent_max(F)
        S(1) << (8sizeof(S)-1)
    else
        -maxcommon(S, F)
    end
end

mincommon(F::Type{<:AbstractFloat}, S::Type{<:Signed})::F = F(mincommon(S, F))

function maxcommon(S::Type{<:Signed}, F::Type{<:AbstractFloat})::S
    max_exp = min(8sizeof(S)-2, Base.exponent_max(F))
    num_ones = min(8sizeof(S)-1, Base.significand_bits(F)+1)
    ones = (S(1) << num_ones) - S(1)
    ones << (max_exp - num_ones + 1)
end

maxcommon(F::Type{<:AbstractFloat}, S::Type{<:Signed})::F = F(maxcommon(S, F))

"""
    exactconv(I, x::F) :: Union{I,Nothing}
    exactconv(F, x::I) :: Union{F,Nothing}

Convert between integer and floating-point types. The conversion suceeds only if
it does not change the numeric value, otherwise it returns `nothing`.
"""
function exactconv end

function exactconv(I::Type{<:Union{Signed,Unsigned}}, x::F)::Union{I,Nothing} where F<:AbstractFloat
    if isinteger(x) && mincommon(F, I) <= x <= maxcommon(F, I)
        I(x)
    else
        nothing
    end
end

function exactconv(F::Type{<:AbstractFloat}, x::U)::Union{F,Nothing} where U<:Unsigned
    bw = 8sizeof(U) - leading_zeros(x) - trailing_zeros(x)
    if bw <= Base.significand_bits(F)+1 && mincommon(U, F) <= x <= maxcommon(U, F)
        F(x)
    else
        nothing
    end
end

function exactconv(F::Type{<:AbstractFloat}, x::S)::Union{F,Nothing} where S<:Signed
    if x >= S(0)
        bw = 8sizeof(S) - leading_zeros(x) - trailing_zeros(x)
        if bw <= Base.significand_bits(F)+1 && mincommon(S, F) <= x <= maxcommon(S, F)
            F(x)
        else
            nothing
        end
    elseif x == ~S(0) && x == mincommon(S, F)
        F(x)
    else
        bw = 8sizeof(S) - leading_zeros(-x) - trailing_zeros(-x)
        if bw <= Base.significand_bits(F)+1 && mincommon(S, F) <= x <= maxcommon(S, F)
            F(x)
        else
            nothing
        end
    end
end

end
