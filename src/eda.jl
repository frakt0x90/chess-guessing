using DataFrames
using CSV
using CategoricalArrays


data = DataFrame(CSV.File(open("data/features/game_features.csv")))

#TODO: There are tournaments with 92 rounds. Maybe check that out
describe(data)

