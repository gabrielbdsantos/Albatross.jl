using Test
using Albatross

@testset "Momentum theory" begin
    @testset "Momentum theory interface" begin
        models = [m() for m in subtypes(AbstractMomentumTheory)]

        @test all(model -> model isa AbstractMomentumTheory, models)

        a = [0.0, 0.25, 0.5]
        for model in models
            wake = Albatross.wake_velocity_ratio.(model, a)
            thrust = Albatross.thrust_coefficient.(model, a)

            @test wake isa Vector{Float64}
            @test thrust isa Vector{Float64}
            @test length(wake) == length(a)
            @test length(thrust) == length(a)
        end
    end

    @testset "Rankine–Froude momentum theory" begin
        model = RankineFroude()

        @test Albatross.wake_velocity_ratio(model, 0.0) == 1.0
        @test Albatross.wake_velocity_ratio(model, 0.25) == 0.5
        @test Albatross.wake_velocity_ratio(model, 0.5) == 0.0

        @test Albatross.thrust_coefficient(model, 0.0) == 0.0
        @test Albatross.thrust_coefficient(model, 0.25) == 0.75
        @test Albatross.thrust_coefficient(model, 0.4) == 0.96

        high_induction = 0.889 - (0.0203 - (0.5 - 0.143)^2) / 0.6427
        @test Albatross.thrust_coefficient(model, 0.5) == high_induction
    end

    @testset "Steiros–Hultmark momentum theory" begin
        model = SteirosHultmark()

        @test Albatross.wake_velocity_ratio(model, 0.0) == 1.0
        @test Albatross.wake_velocity_ratio(model, 0.25) == 0.6
        @test Albatross.wake_velocity_ratio(model, 0.5) == 1 / 3

        @test Albatross.thrust_coefficient(model, 0.0) == 0.0
        @test Albatross.thrust_coefficient(model, 0.25) == 4 / 3 * 0.25 * (3 - 0.25) / 1.25
        @test Albatross.thrust_coefficient(model, 0.7) == 4 / 3 * 0.7 * (3 - 0.7) / 1.7

        high_induction = 0.889 - (0.0203 - (0.8 - 0.143)^2) / 0.6427
        @test Albatross.thrust_coefficient(model, 0.8) == high_induction
    end
end
