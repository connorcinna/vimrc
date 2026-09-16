local shell = {}

local util = require("util")

local window_opts = {
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

local shell_gui = {}

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
		if shell_gui.auto_close then
			vim.defer_fn(function()
				vim.api.nvim_win_close(shell_gui.win, true)
				vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
			end, 3000)
		end
	else
		if shell_gui.auto_close then
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

-- swap to cmd.exe to do a command and then back to powershell
function shell.do_cmd(args)
	if vim.fn.has("win32") == 1 then
		vim.o.shell = "C:\\Windows\\System32\\cmd.exe"
		vim.cmd(args)
		vim.o.shell = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
	else
		vim.cmd(args)
	end
end

function shell.do_async_cmd_with_window(args, callback, auto_close)
	if auto_close == nil then
		auto_close = true
	end
	shell_gui.auto_close = auto_close
	shell_gui.callback = callback
	shell_gui.buf = vim.api.nvim_create_buf(false, true)
	shell_gui.win = vim.api.nvim_open_win(shell_gui.buf, false, window_opts)
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(shell_gui.win, true)
		vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
	end, { buffer = shell_gui.buf })
	window_opts.title = args
	local final_args = { "powershell.exe", "-NoProfile", "-Command" }
	table.insert(final_args, args)
	vim.system(final_args, { text = true, stdout = on_stdout_stderr, stderr = on_stdout_stderr }, on_done)
end

return shell
