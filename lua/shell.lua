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

local default_opts = {
	auto_close = true,
	enter = false,
	pty = false,
}

shell_gui.opts = vim.deepcopy(default_opts)

local function on_stdout_stderr(err, data)
	if data then
		vim.schedule(function()
			data = util.string_to_table(data)
			vim.api.nvim_buf_set_lines(shell_gui.buf, -1, -1, false, data)
			if vim.api.nvim_win_is_valid(shell_gui.win) then
				vim.api.nvim_win_set_cursor(shell_gui.win, { vim.api.nvim_buf_line_count(shell_gui.buf), 0 })
			end
		end)
	end
	if err then
		vim.schedule(function()
			err = util.string_to_table(err)
			vim.api.nvim_buf_set_lines(shell_gui.buf, -1, -1, false, err)
			if vim.api.nvim_win_is_valid(shell_gui.win) then
				vim.api.nvim_win_set_cursor(shell_gui.win, { vim.api.nvim_buf_line_count(shell_gui.buf), 0 })
			end
		end)
	end
end

local function on_done(obj)
	if obj.code ~= 0 then
		vim.notify(obj.code .. obj.stderr, "error")
		if shell_gui.opts.auto_close then
			vim.defer_fn(function()
				vim.api.nvim_win_close(shell_gui.win, true)
				vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
			end, 3000)
		end
	else
		vim.notify(shell_gui.win_config.title .. " has finished")
		if shell_gui.opts.auto_close then
			vim.defer_fn(function()
				vim.api.nvim_win_close(shell_gui.win, true)
				vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
				if shell_gui.callback then
					shell_gui.callback()
				end
			end, 1000)
		end
	end
end

function shell.do_async_cmd_with_window(args, opts, win_config, callback)
	-- default title for window will be args
	shell_gui.win_config.title = args
	if win_config then
		for key, value in pairs(win_config) do
			shell_gui.win_config[key] = value
		end
	end
	shell_gui.opts = vim.tbl_extend("force", default_opts, opts or {})
	shell_gui.callback = callback
	shell_gui.buf = vim.api.nvim_create_buf(false, true)
	shell_gui.win = vim.api.nvim_open_win(shell_gui.buf, shell_gui.opts.enter, shell_gui.win_config)
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(shell_gui.win, true)
		vim.api.nvim_buf_delete(shell_gui.buf, { force = true })
	end, { buffer = shell_gui.buf })
	local final_args = { "powershell.exe", "-NoProfile", "-Command" }
	table.insert(final_args, args)
	if shell_gui.opts.pty then
		local term_opts = {
			on_exit = function(_, code)
				on_done({ code = code, stderr = "" })
			end,
		}
		vim.api.nvim_win_call(shell_gui.win, function()
			if vim.fn.exists("*termopen") == 1 then
				vim.fn.termopen(final_args, term_opts)
			else
				term_opts.term = true
				vim.fn.jobstart(final_args, term_opts)
			end
		end)
	else
		vim.system(final_args, { text = true, stdout = on_stdout_stderr, stderr = on_stdout_stderr }, on_done)
	end
end

return shell
