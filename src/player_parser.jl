using EzXML
using Base
using DataFrames
using Dates

Base.parse(x, y::Missing) = missing
convert_empty(val::String, replacement=missing) = val == "" ? replacement : val

function make_player(node::EzXML.Node)
	fideid = findfirst("fideid", node).content
	name = findfirst("name", node).content
	country = findfirst("country", node).content
	sex = findfirst("sex", node).content
	title = findfirst("title", node).content
	rating = parse(Int, convert_empty(findfirst("rating", node).content))
	games = parse(Int, convert_empty(findfirst("games", node).content))
	k = parse(Int, convert_empty(findfirst("k", node).content))
	birthyear = parse(Int, convert_empty(findfirst("birthday", node).content))
	inactive = occursin("i", findfirst("flag", node).content)
	[fideid, name, country, sex, title, rating, games, k, birthyear, inactive]
end

function parse_file(path::String)
    doc = readxml(path)
    players = findall("player", doc.root)
    data = make_player.(players)
    df = DataFrame(permutedims(hcat(data...)), ["fideid", "name", "country", "sex", "title", "rating", "games", "k", "birthyear", "inactive"])
end

rootpath = "data/players/"
dfs = [[] for i in 1:Threads.nthreads()]
files = readdir(rootpath)
Threads.@threads for file in files
    playerdf = parse_file(joinpath(rootpath, file))
    playerdf[!, :asof] .= lastdayofmonth(Date(match(r"\w{3}\d{2}", file).match, dateformat"uuuyy") + Year(2000))
    playerdf[!, :gametype] .= convert(String, split(file, "_")[1])
    push!(dfs[Threads.threadid()], playerdf)
end

println("prpcessing finished")
finaldf = vcat(vcat(dfs...)...)
transform!(finaldf, names(finaldf, String) .=> ByRow(convert_empty), renamecols=false)
CSV.write("data/players.csv", finaldf)