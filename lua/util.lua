local util = {}

function util.filter_from_table(t, remove)
    new_t = {}
    for i, line in ipairs(t) do
        line = line:gsub(remove, "")
        table.insert(new_t, line)
    end
    return new_t
end

function util.string_to_table(s)
    local t = {}
    s = s:gsub("\r\n", "\n")
    for line in s:gmatch("(.-)\n") do
        table.insert(t, line)
    end
    return t
end

function util.execute_powershell_file(ps_file)
    local file, err = io.open(ps_file, "rb")
    if file then
        local script = file:read("*a")
        vim.system({'powershell.exe', '-NoProfile', '-Command', script})
        file:close()
    end
end

return util
