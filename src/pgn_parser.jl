using Dates
using DataFrames
using CSV

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
        for line in eachline(pgn)
            if length(line) == 0
                continue
            end
            if line[1] == '['
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
                end
            elseif line[1:2] == "1."
                game["Moves"] = parse_move_line(line)
                push!(keys, "Move")
                nulls = setdiff(gamekeys, Set(keys))
                for nulcol in nulls
                    game[nulcol] =""
                end
                keys = []
                push!(games, game)
                game = copy(emptygame)
            end
        end
        return games
    end
end


dfs = []
for file in readdir("games/", join=true)
    if endswith(file, "pgn")
        game_data = parsepgn_single(file)
        game_df = vcat(DataFrame.(game_data)...)
        push!(dfs, game_df)
        println(file)
    end
end

final_df = vcat(dfs...)
CSV.write("data/games.csv", final_df)