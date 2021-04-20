using ExactConversions
using Test

@testset "ExactConversions.jl" begin
    for I in [Int128, Int16, Int32, Int64, Int8, UInt128, UInt16, UInt32, UInt64, UInt8], F in [Float16, Float32, Float64]
        i, f = mincommon(I, F), mincommon(F, I)
        @test BigInt(i) == BigInt(f)
        i, f = maxcommon(I, F), maxcommon(F, I)
        @test BigInt(i) == BigInt(f)
    end
end
