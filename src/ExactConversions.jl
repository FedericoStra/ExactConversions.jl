module ExactConversions

export mincommon, maxcommon

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
function mincommon end

# unsigned integral types

mincommon(U::Type{<:Unsigned}, F::Type{<:AbstractFloat})::U = zero(U)

mincommon(F::Type{<:AbstractFloat}, U::Type{<:Unsigned})::F = F(mincommon(U, F))

function maxcommon(U::Type{<:Unsigned}, F::Type{<:AbstractFloat})::U
    max_exp = min(8sizeof(U)-1, Base.exponent_max(F)-1)
    num_ones = min(8sizeof(U), Base.significand_bits(F)+1)
    ones = (U(1) << num_ones) - U(1)
    ones << (max_exp - num_ones + 1)
end

maxcommon(F::Type{<:AbstractFloat}, U::Type{<:Unsigned})::F = F(maxcommon(U, F))

# signed integral types

function mincommon(S::Type{<:Signed}, F::Type{<:AbstractFloat})::S
    if 8sizeof(S)-1 <= Base.exponent_max(F)-1
        S(1) << (8sizeof(S)-1)
    else
        -maxcommon(S, F)
    end
end

mincommon(F::Type{<:AbstractFloat}, S::Type{<:Signed})::F = F(mincommon(S, F))

function maxcommon(S::Type{<:Signed}, F::Type{<:AbstractFloat})::S
    max_exp = min(8sizeof(S)-2, Base.exponent_max(F)-1)
    num_ones = min(8sizeof(S)-1, Base.significand_bits(F)+1)
    ones = (S(1) << num_ones) - S(1)
    ones << (max_exp - num_ones + 1)
end

maxcommon(F::Type{<:AbstractFloat}, S::Type{<:Signed})::F = F(maxcommon(S, F))

end
