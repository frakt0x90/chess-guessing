using Dates
using DataFrames
using CSV


function maxmove(line::String)
    matches = eachmatch(r"\d+(?=\.)", line)
    if length(collect(matches)) > 0
        maximum(parse.(Int, String.(getproperty.(matches, :match))))
    end
end

function parse_move_line(line::String)
    matches = eachmatch(r"(?<=(\d\. )).+? .+?(?=( \d\.))", line)
    return join([i.match for i in matches], ",")
end

function parsepgn_single(filepath::String)
    emptygame = Dict("Event" => "", "Site" => "", "Date" => "",
    "Round" => "", "White" => "", "Black" => "", 
    "Result" => "", "WhiteTitle" => "", "BlackTitle" => "", 
    "WhiteElo" => "", "BlackElo" => "", "ECO" => "", 
    "Opening" => "", "Variation" => "", "WhiteFideId" => "", 
    "BlackFideId" => "", "EventDate" => "", "Moves" => "",
    "EventType" => "", "SetUp" => "", "Variant" => "")
    gamekeys = Set(keys(emptygame))
    trashkeys = Dict(
        "WhiteTeam" => true, "BlackTeam" => true,
        "FEN" => true, "Annotator" => true
    )

    open(filepath, "r") do pgn
        keys = []
        game = copy(emptygame)
        games = []
        moves = 0
        inmovelist = false
        for line in eachline(pgn)
            if length(line) == 0
                continue
            end
            if startswith(line, '[')
                key = match(r"(?<=\[)\w+?(?= )", line)
                if !isnothing(key)
                    key = key.match
                    if haskey(trashkeys, key)
                        continue
                    end
                end
                value = match(r"(?<=\").+?(?=\")", line)
                if !isnothing(value)
                    game[key] = value.match
                    push!(keys, key)
                    continue
                end
            elseif startswith(line, "1.")
                inmovelist = true
                moves = maxmove(line)
            elseif inmovelist
                linemoves = maxmove(line)
                if !isnothing(linemoves)
                    moves = linemoves
                end
                if !isnothing(match(r"1-0|1/2-1/2|0-1", line))
                    game["Moves"] = string(moves)
                    push!(keys, "Moves")
                    nulls = setdiff(gamekeys, Set(keys))
                    for nulcol in nulls
                        game[nulcol] =""
                    end
                    keys = []
                    push!(games, game)
                    game = copy(emptygame)
                end
            end
        end
        return games
    end
end


dfs = []
for file in readdir("data/games/", join=true)
    game_data = parsepgn_single(file)
    game_df = vcat(DataFrame.(game_data)...)
    push!(dfs, game_df)
    println(file)
end

final_df = vcat(dfs...)
CSV.write("data/games2.csv", final_df)