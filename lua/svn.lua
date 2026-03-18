local svn = {}

local shell = require('shell')

local STATUS_COL_LENGTH = 7

-- window options passed to vim.api.nvim_open_win
-- each function needs to insert it's own "title" field
local window_opts = {
    relative = "cursor",
	width = 120,
    height = 40,
    col = 0,
    row = 1,
    anchor = "NW",
    style = "minimal",
    border = { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" },
    title = "override",
    title_pos = "center"
}

local function string_to_table(s)
    local t = {}
    s = s:gsub("\r\n", "\n")
    -- if s:sub(-1) ~= "\n" then
    --     s = s .. "\n"
    -- end
    for line in s:gmatch("(.-)\n") do
        table.insert(t, line)
    end
    -- -- for some reason the above is inserting a new line at the top, not sure why.
    -- if t[1] == '\n' then
    --     t = table.remove(t, 1)
    -- end
    return t
end

-- TODO check for if you need to update first
local function commit()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'svn_commit')
    window_opts.title = "Enter a commit message"
    local win = vim.api.nvim_open_win(buf, 0, window_opts)
    vim.keymap.set('i', '<CR>', function()
        local buf_text = vim.api.nvim_buf_get_lines(buf, -1, -1, false)
        local output = shell.do_system_cmd(string.format('svn commit -m "%s"', buf_text[1]))
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
    end, {buffer = true})
    vim.keymap.set('i', 'q', function()
        vim.api.nvim_buf_delete(buf, {force = true})
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, 'i', false)
    end, {buffer = true})
    vim.api.nvim_feedkeys("i", 'n', false)
end

local function log()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'svn_log')
    window_opts.title = string.format('SVN Log: %s', vim.fn.getcwd())
    local win = vim.api.nvim_open_win(buf, 0, window_opts)
    vim.fn.jobstart({"svn", "log"},
    {
        on_stdout = function(_, data)
            vim.schedule(function()
                if data then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
                end
            end)
        end,
        on_stderr = function(_, data)
            vim.schedule(function()
                if data then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
                end
            end)
        end,
        stdout_buffered = false,
        stderr_buffered = false,
    })
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_buf_delete(buf, {force = true})
    end, {buffer = true})
end

local function diff()
    local modified = shell.do_system_cmd("svn status --quiet")
    local modified_table = string_to_table(modified)
    for index, line in ipairs(modified_table) do
        local line = string.sub(line, STATUS_COL_LENGTH)
        local buf = vim.api.nvim_create_buf(false, true)
        local pristine_copy = shell.do_system_cmd(string.format("svn cat %s", line))
        local pristine_copy_table = string_to_table(pristine_copy)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, pristine_copy_table)
        local filetype = vim.api.nvim_get_option_value('filetype', {scope = 'local'})
        --set the filetype to be the same as the left view
        vim.api.nvim_set_option_value('filetype', filetype, {buf = buf})
        shell.do_cmd(string.format("tabnew %s", line))
        --from this point on current window and buffer is a new tab
        local left_win = vim.api.nvim_get_current_win()
        local right_win = vim.api.nvim_open_win(buf, false, {split = 'right', win = 0})
        --set all related diff options for each tab
        vim.api.nvim_set_option_value('diff', true, {win = left_win})
        vim.api.nvim_set_option_value('scrollbind', true, {win = left_win})
        vim.api.nvim_set_option_value('cursorbind', true, {win = left_win})
        vim.api.nvim_set_option_value('wrap', false, {win = left_win})
        vim.api.nvim_set_option_value('foldmethod', 'diff', {win = left_win})
        vim.api.nvim_set_option_value('foldcolumn', '2', {win = left_win})

        vim.api.nvim_set_option_value('diff', true, {win = right_win})
        vim.api.nvim_set_option_value('scrollbind', true, {win = right_win})
        vim.api.nvim_set_option_value('cursorbind', true, {win = right_win})
        vim.api.nvim_set_option_value('wrap', false, {win = right_win})
        vim.api.nvim_set_option_value('foldmethod', 'diff', {win = right_win})
        vim.api.nvim_set_option_value('foldcolumn', '2', {win = right_win})
    end
end

-- update with '--accept postpone' and resolve in resolve()
local function up()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'svn_up')
    window_opts.title = string.format('SVN Up: %s', vim.fn.getcwd())
    local win = vim.api.nvim_open_win(buf, 0, window_opts)
    vim.fn.jobstart({"svn", "up", "--accept", "postpone"},
    {
        on_stdout = function(_, data)
            vim.schedule(function()
                if data then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
                end
            end)
        end,
        on_stderr = function(_, data)
            vim.schedule(function()
                if data then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
                end
            end)
        end,
        stdout_buffered = false,
        stderr_buffered = false,
    })
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_buf_delete(buf, {force = true})
    end, {buffer = true})
end

local function resolve()
    local modified = shell.do_system_cmd("svn status --quiet")
    local conflicted_table = {}
    for line in modified:gmatch("[^\r\n]+") do
        -- look for conflict marker
        local line = string.sub(line, STATUS_COL_LENGTH)
        if string.find(line, "C") then
            table.insert(conflicted_table, line)
        end
    end
    for index, line in ipairs(conflicted_table) do
        local line = string.sub(line, STATUS_COL_LENGTH)
        shell.do_cmd(string.format("tabnew %s", line)) -- local changes
        -- TODO how to get the local files with rev number created by up()
        shell.do_cmd(string.format("vert diffsplit %s.tmp", line)) --incoming changes
    end
    for index, line in ipairs(conflicted_table) do
        shell.do_system_cmd(string.format("rm %s.tmp", line))
    end
end

local function show_updates()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'svn_show_updates')
    window_opts.title = string.format('SVN Remote Updates: %s', vim.fn.getcwd())
    local win = vim.api.nvim_open_win(buf, 0, window_opts)
    vim.fn.jobstart({"svn", "status", "--show-updates"},
    {
        on_stdout = function(_, data)
            vim.schedule(function()
                if data then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
                end
            end)
        end,
        on_stderr = function(_, data)
            vim.schedule(function()
                if data then
                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, data)
                end
            end)
        end,
        stdout_buffered = false,
        stderr_buffered = false,
    })
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_buf_delete(buf, {force = true})
    end, {buffer = true})
end


local function blame()
    shell.do_cmd("tabnew | r ! svn blame #")
end

vim.api.nvim_create_user_command('SvnCommit', commit, {})
vim.api.nvim_create_user_command('SvnDiff', diff, {})
vim.api.nvim_create_user_command('SvnBlame', blame, {})
vim.api.nvim_create_user_command('SvnLog', log, {})
vim.api.nvim_create_user_command('SvnUp', up, {})
vim.api.nvim_create_user_command('SvnCheck', show_updates, {})

return svn
