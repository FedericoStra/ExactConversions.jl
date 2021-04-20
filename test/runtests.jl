using ExactConversions
using Test

@testset "ExactConversions.jl" begin
    @testset "bounds" begin
        for I in [Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8], F in [Float16, Float32, Float64]
            i, f = mincommon(I, F), mincommon(F, I)
            @test BigInt(i) == BigInt(f)
            i, f = maxcommon(I, F), maxcommon(F, I)
            @test BigInt(i) == BigInt(f)
        end
    end
    @testset "conversions" begin
        for I in [Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8], F in [Float16, Float32, Float64]
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
end
