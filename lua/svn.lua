local svn = {}

local shell = require("shell")
local util = require("util")

local STATUS_COL_LENGTH = 9

-- default window options passed to vim.api.nvim_open_win
-- each function should change the "title" field
local window_opts = {
	relative = "cursor",
	width = 120,
	height = 40,
	col = 0,
	row = 1,
	anchor = "NW",
	style = "minimal",
	border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
	title = "override",
	title_pos = "center",
}

local function find_out_of_date(t)
	local ood = {}
	for _, line in ipairs(t) do
		if string.find(line, "*") ~= nil then
			table.insert(ood, line)
		end
	end
	return ood
end

local function on_stdout_stderr(err, data)
	if err then
		util.print("Shell stdout/stderr read error: " .. err, vim.log.levels.ERROR)
	end
	if data then
		vim.schedule(function()
			data = util.string_to_table(data)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
			end
		end)
	end
end

-- update with '--accept postpone' and resolve in resolve()
local function up()
	shell.do_async_cmd_with_window("svn up --accept postpone")
end

local function _checkupdates(buf_id, win_id)
	local buf = -1
	if buf_id == nil then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf, "svn_checkupdates")
	else
		buf = buf_id
	end
	local win = -1
	if win_id == nil then
		window_opts.title = string.format("SVN Remote Updates: %s", vim.fn.getcwd())
		win = vim.api.nvim_open_win(buf, true, window_opts)
		vim.keymap.set("n", "q", function()
			vim.api.nvim_win_close(win, true)
			vim.api.nvim_buf_delete(buf, { force = true })
		end, { buffer = buf })
	else
		win = win_id
	end
	local checkupdate = vim.system({ "svn", "status", "--show-updates" }, { text = true }):wait().stdout
	local update_table = util.string_to_table(checkupdate)
	update_table = find_out_of_date(update_table)
	if #update_table > 0 then
		table.insert(
			update_table,
			1,
			"Files have updates available! Press 'u' to update before continuing, or 'q' to exit without updating"
		)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, update_table)
		vim.keymap.set("n", "u", function()
			up()
		end, { buffer = buf })
	end
end

local function status()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "svn_status")
	window_opts.title = string.format("SVN Status: %s", vim.fn.getcwd())
	local win = vim.api.nvim_open_win(buf, true, window_opts)
	vim.fn.jobstart({ "svn", "status" }, {
		on_stdout = function(_, data)
			vim.schedule(function()
				if data then
					data = util.filter_from_table(data, "\r")
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end)
		end,
		on_stderr = function(_, data)
			vim.schedule(function()
				if data then
					data = util.filter_from_table(data, "\r")
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end)
		end,
		stdout_buffered = false,
		stderr_buffered = false,
	})
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf })
end

local function _info()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "svn_info")
	window_opts.title = string.format("SVN Info: %s", vim.fn.getcwd())
	local win = vim.api.nvim_open_win(buf, true, window_opts)
	vim.fn.jobstart({ "svn", "info" }, {
		on_stdout = function(_, data)
			vim.schedule(function()
				if data then
					data = util.filter_from_table(data, "\r")
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end)
		end,
		on_stderr = function(_, data)
			vim.schedule(function()
				if data then
					data = util.filter_from_table(data, "\r")
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end)
		end,
		stdout_buffered = false,
		stderr_buffered = false,
	})
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf })
end

local function checkupdates(opts)
	_checkupdates(nil, nil)
end

local function commit()
	_checkupdates()
	local buf = vim.api.nvim_create_buf(false, true)
	window_opts.title = "SVN Commit"
	local win = vim.api.nvim_open_win(buf, true, window_opts)
	vim.api.nvim_buf_set_name(buf, "svn_commit")
	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(buf, { force = true })
		vim.api.nvim_win_close(win, true)
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		vim.api.nvim_feedkeys(esc, "i", false)
	end, { buffer = buf })
	vim.keymap.set("i", "<CR>", function()
		local buf_text = vim.api.nvim_buf_get_lines(buf, 1, -1, false)
		local output = vim.system({ "svn", "commit", "-m", buf_text[1] }, { text = true }):wait().stdout
		local output_table = util.string_to_table(output)
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		vim.api.nvim_feedkeys(esc, "i", false)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_table)
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Press 'q' to exit." })
	end, { buffer = buf })
end

local function log()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "svn_log")
	window_opts.title = string.format("SVN Log: %s", vim.fn.getcwd())
	local win = vim.api.nvim_open_win(buf, true, window_opts)
	vim.fn.jobstart({ "svn", "log" }, {
		on_stdout = function(_, data)
			vim.schedule(function()
				if data then
					data = util.filter_from_table(data, "\r")
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end)
		end,
		on_stderr = function(_, data)
			vim.schedule(function()
				if data then
					data = util.filter_from_table(data, "\r")
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
				end
			end)
		end,
		stdout_buffered = false,
		stderr_buffered = false,
	})
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf })
end

local function diff()
	local modified = vim.system({ "svn", "status", "--quiet" }, { text = true }):wait().stdout
	local modified_table = util.string_to_table(modified)
	for _, line in ipairs(modified_table) do
		line = string.sub(line, STATUS_COL_LENGTH)
		local buf = vim.api.nvim_create_buf(false, true)
		local pristine_copy = vim.system({ "svn", "cat", line }, { text = true }):wait().stdout
		--E200009 - new file, nothing to diff against
		if string.find(pristine_copy, "E200009") then
			pristine_copy = "New File - Nothing to diff against"
		end
		local pristine_copy_table = util.string_to_table(pristine_copy)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, pristine_copy_table)
		local filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" })
		--set the filetype to be the same as the left view
		vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
		vim.cmd("tabnew " .. line)
		--from this point on current window and buffer is a new tab
		local right_win = vim.api.nvim_get_current_win()
		local left_win = vim.api.nvim_open_win(buf, true, { split = "left", win = 0 })
		--set diff options
		-- right window
		vim.api.nvim_set_option_value("diff", true, { win = right_win })
		vim.api.nvim_set_option_value("scrollbind", true, { win = right_win })
		vim.api.nvim_set_option_value("cursorbind", true, { win = right_win })
		vim.api.nvim_set_option_value("wrap", false, { win = right_win })
		vim.api.nvim_set_option_value("foldmethod", "diff", { win = right_win })
		vim.api.nvim_set_option_value("foldcolumn", "2", { win = right_win })

		-- left window
		vim.api.nvim_set_option_value("diff", true, { win = left_win })
		vim.api.nvim_set_option_value("scrollbind", true, { win = left_win })
		vim.api.nvim_set_option_value("cursorbind", true, { win = left_win })
		vim.api.nvim_set_option_value("wrap", false, { win = left_win })
		vim.api.nvim_set_option_value("foldmethod", "diff", { win = left_win })
		vim.api.nvim_set_option_value("foldcolumn", "2", { win = left_win })

		vim.api.nvim_set_current_win(right_win)
	end
end

local function resolve()
	local modified = vim.system({ "svn", "status" }, { text = true }):wait().stdout
	local conflicts = {}
	local current = nil
	for line in modified:gmatch("[^\r\n]+") do
		if line:match("^C%s+") then
			current = {
				conflict = line:match("^C%s+(.+)$"),
				files = {},
			}
			table.insert(conflicts, current)
		elseif current then
			local path = line:match("^%?%s+(.+)$")
			if path then
				table.insert(current.files, path)
			end
		end
	end
	if next(conflicts) ~= nil then
		local conflict_filenames = ""
		for _, conflict in ipairs(conflicts) do
			conflict_filenames = conflict_filenames .. conflict.conflict .. " "
		end
		print(conflict_filenames)
		vim.notify(
			"Currently resolving the following files: "
				.. conflict_filenames
				.. " When you are done resolving, press d."
		)
	end

	for _, conflict in ipairs(conflicts) do
		if #conflict.files == 3 then
			local mine
			local others = {}

			for _, path in ipairs(conflict.files) do
				if path:match("%.mine$") then
					mine = path
				else
					table.insert(others, path)
				end
			end
			if mine and #others == 2 then
				--new tab 1st revision, hsplit with `mine`, move up, vsplit with 2nd revision
				vim.cmd("tabnew " .. vim.fn.fnameescape(others[1]))
				vim.cmd("split " .. vim.fn.fnameescape(mine))
				vim.cmd("wincmd J")
				vim.cmd("wincmd k")
				vim.cmd("vertical diffsplit " .. vim.fn.fnameescape(others[2]))
				vim.cmd("wincmd L")
				vim.cmd("wincmd h")
				vim.cmd("wincmd j")
				vim.cmd("wincmd J")

				-- Enable diff mode in all windows
				vim.cmd("diffthis")
				vim.cmd("wincmd h")
				vim.cmd("diffthis")
				vim.cmd("wincmd j")
				vim.cmd("diffthis")
			end
		end
	end
end

local function blame()
	vim.cmd("tabnew | r ! svn blame #")
end

local function info(opts)
	_info()
end

vim.api.nvim_create_user_command("SvnCommit", commit, {})
vim.api.nvim_create_user_command("SvnDiff", diff, {})
vim.api.nvim_create_user_command("SvnBlame", blame, {})
vim.api.nvim_create_user_command("SvnLog", log, {})
vim.api.nvim_create_user_command("SvnUp", up, {})
vim.api.nvim_create_user_command("SvnCheck", checkupdates, {})
vim.api.nvim_create_user_command("SvnStatus", status, {})
vim.api.nvim_create_user_command("SvnInfo", info, {})
vim.api.nvim_create_user_command("SvnResolve", resolve, {})

return svn
