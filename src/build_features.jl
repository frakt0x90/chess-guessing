using DataFrames
using CSV
using CategoricalArrays
using DataFramesMeta
using MLJ


# Features to add:
#  - rounds in tourney
#  - current place
#  - closest next people
#  - utc offset between event country and player country

data = DataFrame(CSV.File(open("data/features/game_features.csv")))

@select! data $(Not(:timeformat))
data = coerce(data, 
    :blacktitle => OrderedFactor,
    :gamedow => Multiclass,
    :gamemonth => Multiclass,
    :eventtype => Multiclass,
    :gameresult => OrderedFactor,
    :whitetitle => OrderedFactor,
    :blackelo => Continuous,
    :whiteelo => Continuous,
    :daysfromstart => Continuous,
    :elodiff => Continuous
)

rng = 42
y, X = unpack(data, ==(:gameresult); rng=rng)
encoder = ContinuousEncoder()
mach = fit!(machine(encoder, X))
W = MLJ.transform(mach, X)
(Xtrain, Xtest), (ytrain, ytest) = partition((W, y), 0.8, rng=rng, multi=true)

Multinom = @load MultinomialClassifier pkg=MLJLinearModels
mdl = Multinom()
mcmach = machine(mdl, Xtrain, ytrain)
fit!(mcmach)
ypred = predict(mcmach, Xtest)
flat_pred = predict_mode(mcmach, Xtest)
params = fitted_params(mcmach)
params.coefs # coefficients of the regression
accuracy = sum(flat_pred .== ytest)/length(ytest)
MLJ.confusion_matrix(flat_pred, ytest)