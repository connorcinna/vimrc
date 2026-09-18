local shell = {}

local util = require("util")

local shell_gui = {}

shell_gui.win_config = {
	relative = "editor",
	width = 90,
	height = 15,
	col = vim.o.columns - 1,
	row = vim.o.lines - 1,
	anchor = "NW",
	style = "minimal",
	border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
	title = "override",
	title_pos = "center",
}

shell_gui.opts = {
	auto_close = true,
	enter = false,
}

local function on_stdout_stderr(err, data)
	if err then
		util.print("Shell stdout/stderr read error: " .. err, vim.log.levels.ERROR)
	end
	if data then
		vim.schedule(function()
			data = util.string_to_table(data)
			vim.api.nvim_buf_set_lines(shell_gui.buf, -1, -1, false, data)
			if vim.api.nvim_win_is_valid(shell_gui.win) then
				vim.api.nvim_win_set_cursor(shell_gui.win, { vim.api.nvim_buf_line_count(shell_gui.buf), 0 })
			end
		end)
	end
end

local function on_done(obj)
	if obj.code ~= 0 then
		util.print(obj.code .. obj.stderr)
		if shell_gui.opts.auto_close then
			vim.defer_fn(function()
				vim.api.nvim_win_close(shell_gui.win, true)
				vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
			end, 3000)
		end
	else
		if shell_gui.opts.auto_close then
			vim.defer_fn(function()
				vim.api.nvim_win_close(shell_gui.win, true)
				vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
				if shell_gui.callback ~= nil then
					shell_gui.callback()
				end
			end, 1000)
		end
	end
end

function shell.do_async_cmd_with_window(args, opts, win_config, callback)
	if nil ~= win_config then
		for key, value in pairs(win_config) do
			shell_gui.win_config[key] = value
		end
	end
	if nil ~= opts then
		for key, value in pairs(opts) do
			shell_gui.opts[key] = value
		end
	end
	shell_gui.win_config.title = args
	shell_gui.callback = callback
	shell_gui.buf = vim.api.nvim_create_buf(false, true)
	shell_gui.win = vim.api.nvim_open_win(shell_gui.buf, opts.enter, shell_gui.win_config)
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(shell_gui.win, true)
		vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
	end, { buffer = shell_gui.buf })
	local final_args = { "powershell.exe", "-NoProfile", "-Command" }
	table.insert(final_args, args)
	vim.system(final_args, { text = true, stdout = on_stdout_stderr, stderr = on_stdout_stderr }, on_done)
end

return shell
