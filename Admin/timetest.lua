local headers = {
    ["abbreviation"] = "",
    ["day_of_week"] = "",
    ["day_of_year"] = "",
    ["dst"] = "",
    ["dst_from"] = "",
    ["dst_offset"] = "",
    ["dst_until"] = "",
    ["raw_offset"] = "",
    ["timezone"] = "",
    ["unixtime"] = "",
    ["utc_datetime"] = "",
    ["utc_offset"] = "",
    ["week_number"] = ""
}
local fulldt = http.get("http://worldtimeapi.org/api/timezone/Asia/Jerusalem.txt", headers).readAll()
write(fulldt)
read()
