using HTTP

function dlmonth(year_abbrev::Int, month::String)
    resp = HTTP.get("http://ratings.fide.com/download/standard_$(month)$(year_abbrev)frl_xml.zip")
    if resp.status == 200
        open("data/players/standard_$(month)$(year_abbrev).zip", "w") do io
            write(io, resp.body)
        println("$month $year_abbrev written")
        end
    else
        println("$month $year returned status code $(resp.status)")
    end
end

for year in 17:22
    for month in ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
        dlmonth(year, month)
        sleep(1)
    end
end
