local util = {}

function util.filter_from_table(t, remove)
	local new_t = {}
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
		vim.system({ "powershell.exe", "-NoProfile", "-Command", script })
		file:close()
	end
end

function util.tokenize(inputstr, sep)
	sep = sep or "%s" -- Defaults to whitespace if no separator is given
	local t = {}

	-- Pattern matches any sequence of characters that are NOT the separator
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end

	return t
end

-- wrapper around vim.notify
function util.print(msg, level, opts)
	vim.schedule(function()
		vim.notify(msg, level, opts)
	end)
end

return util
