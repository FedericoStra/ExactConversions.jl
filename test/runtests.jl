using ExactConversions
using Test
using TestSetExtensions

_int_types = [UInt8, UInt16, UInt32, UInt64, UInt128, Int8, Int16, Int32, Int64, Int128]
_float_types = [Float16, Float32, Float64]

macro skip(code) end

function tryconv(T, x)
    c = convert(T, x)
    x == c ? c : nothing
end

@testset ExtendedTestSet "ExactConversions.jl" begin

    @testset "bounds" begin
        @testset "$I $F" for I in _int_types, F in _float_types
            i, f = mincommon(I, F), mincommon(F, I)
            @test BigInt(i) == BigInt(f)
            i, f = maxcommon(I, F), maxcommon(F, I)
            @test BigInt(i) == BigInt(f)
        end
    end

    @testset "conversions" begin
        @testset "$I $F" for I in _int_types, F in _float_types
            @test exactconv(F, I(0)) == F(0)
            @test exactconv(I, F(0)) == I(0)
            i, f = mincommon(I, F), mincommon(F, I)
            @test exactconv(I, f) === i
            @test exactconv(F, i) === f
            i, f = maxcommon(I, F), maxcommon(F, I)
            @test exactconv(I, f) === i
            @test exactconv(F, i) === f
        end
    end

    @testset "integer to floating-point" begin
        function check_all_int_to_float(I, F)
            for n in typemin(I):typemax(I)
                x = exactconv(F, n)
                f = F(n)
                if f == n
                    x === f || return false
                else
                    x === nothing || return false
                end
            end
            return true
        end
        @testset "$I to $F" for I in [UInt8, Int8, UInt16, Int16], F in _float_types
            @test check_all_int_to_float(I, F)
        end

        function check_all_int_to_float_try_conv(I, F)
            for n in typemin(I):typemax(I)
                exactconv(F, n) === tryconv(F, n) || return false
            end
            return true
        end
        @testset "$I to $F" for I in [UInt8, Int8, UInt16, Int16], F in _float_types
            @test check_all_int_to_float_try_conv(I, F)
        end
    end

    @testset "floating-point to integer" begin
        @testset "Float16 to integer" begin
            function check_all_Float16_to_int(I)
                for u in typemin(UInt16):typemax(UInt16)
                    x = reinterpret(Float16, u)
                    n = exactconv(I, x)
                    if isinteger(x) && typemin(I) <= x <= typemax(I)
                        n === I(x) || return false
                    else
                        n === nothing || return false
                    end
                end
                return true
            end
            @testset "Float16 to $I" for I in _int_types
                @test check_all_Float16_to_int(I)
            end
        end

        @skip @testset "Float32 to integer" begin
            # function check_all_Float32(I)
            #     for u in typemin(UInt32):typemax(UInt32)
            #         x = reinterpret(Float32, u)
            #         n = exactconv(I, x)
            #         if isinteger(x) && typemin(I) <= x <= typemax(I)
            #             n === I(x) || return false
            #         else
            #             n === nothing || return false
            #         end
            #     end
            #     return true
            # end
            function check_positive_Float32(I)
                for u in reinterpret(UInt32, Float32(0)):reinterpret(UInt32, prevfloat(Inf32))
                    x = reinterpret(Float32, u)
                    n = exactconv(I, x)
                    if isinteger(x) && typemin(I) <= x <= typemax(I)
                        n === I(x) || return false
                    else
                        n === nothing || return false
                    end
                end
                return true
            end
            @testset "Float32 to $I" for I in _int_types
                # @test check_all_Float32(I)
                @test check_positive_Float32(I)
            end
        end
    end

end
