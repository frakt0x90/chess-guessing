using HTTP
using Dates
using Logging

logfile = open("../player_download.log", "w+")
logger = SimpleLogger(logfile)

function loginfo(logger::SimpleLogger, message::String)
    with_logger(logger) do
        @info("$(now()) - $message")
    end
end

function dlweek(n::Int)
    resp = HTTP.get("https://theweekinchess.com/zips/twic$(n)g.zip")
    if resp.status == 200
        open("data/games/$n.zip", "w") do io
            write(io, resp.body)
        loginfo(logger, "week $n written")
        end
    else
        loginfo(logger, "Request returned status code $(resp.status)")
    end
    flush(logger)
end

for issue in 1156:1440
    dlweek(issue)
    sleep(1)
end