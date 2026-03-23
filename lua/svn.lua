local svn = {}

local shell = require('shell')

local STATUS_COL_LENGTH = 7

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
    border = { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" },
    title = "override",
    title_pos = "center"
}

local function string_to_table(s)
    local t = {}
    s = s:gsub("\r\n", "\n")
    for line in s:gmatch("(.-)\n") do
        table.insert(t, line)
    end
    return t
end

local function find_out_of_date(t)
    ood = {}
    for i, line in ipairs(t) do
        if string.find(line, "*") ~= nil then
            table.insert(ood, line)
        end
    end
    return ood
end
local function filter_from_table(t, remove)
    new_t = {}
    for i, line in ipairs(t) do
        line = line:gsub(remove, "")
        table.insert(new_t, line)
    end
    return new_t
end

-- update with '--accept postpone' and resolve in resolve()
local function _up(buf_id, win_id, commit_hook)
    local buf = -1
    if buf_id == nil then
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, 'svn_up')
    else
        buf = buf_id
    end
    local win = -1
    if win_id == nil then
        window_opts.title = string.format('SVN Up: %s', vim.fn.getcwd())
        win = vim.api.nvim_open_win(buf, 0, window_opts)
        vim.keymap.set('n', 'q', function()
            vim.api.nvim_win_close(win, {force = true})
            vim.api.nvim_buf_delete(buf, {force = true})
        end, {buffer = true})
    else
        win = win_id
    end
    local output = shell.do_system_cmd('svn up --accept postpone')
    local output_table = string_to_table(output)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, output_table)
    if commit_hook then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Update finished - enter commit mesage:"})
        -- create empty line so that we can place the cursor on it
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {""})
        vim.api.nvim_win_set_cursor(win, {2, 0})
        vim.api.nvim_feedkeys("i", "n", false)
    else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Update finished, press 'q' to exit."})
    end
end

local function up(opts)
    _up(nil, nil)
end

local function _check_updates(buf_id, win_id, commit_hook)
    local buf = -1
    if buf_id == nil then
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, 'svn_check_updates')
    else
        buf = buf_id
    end
    local win = -1
    if win_id == nil then
        window_opts.title = string.format('SVN Remote Updates: %s', vim.fn.getcwd())
        win = vim.api.nvim_open_win(buf, 0, window_opts)
        vim.keymap.set('n', 'q', function()
            vim.api.nvim_win_close(win, {force = true})
            vim.api.nvim_buf_delete(buf, {force = true})
        end, {buffer = true})
    else
        win = win_id
    end
    local check_update = shell.do_system_cmd('svn status --show-updates')
    local update_table = string_to_table(check_update)
    update_table = find_out_of_date(update_table)
    if not commit_hook then
        if #update_table > 0 then
            table.insert(update_table, 1, "These files have updates available: Press 'u' to update, or 'q' to exit without updating")
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, update_table)
            vim.keymap.set('n', 'u', function()
                _up(buf, win)
            end, {buffer = true})
        else
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Local copy up to date - press 'q' to exit."})
        end
    else
        if #update_table > 0 then
            table.insert(update_table, 1, "Files have updates available! Press 'u' to update before continuing, or 'q' to exit without updating")
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, update_table)
            vim.keymap.set('n', 'u', function()
                _up(buf, win, commit_hook)
            end, {buffer = true})
        else
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"Enter commit message:"})
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {""})
            vim.api.nvim_win_set_cursor(win, {2, 0})
            vim.api.nvim_feedkeys("i", "n", false)
        end
    end
end

local function _status()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'svn_status')
    window_opts.title = string.format('SVN Status: %s', vim.fn.getcwd())
    local win = vim.api.nvim_open_win(buf, 0, window_opts)
    vim.fn.jobstart({"svn", "status"},
    {
        on_stdout = function(_, data)
            vim.schedule(function()
                if data then
                    data = filter_from_table(data, "\r")
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                end
            end)
        end,
        on_stderr = function(_, data)
            vim.schedule(function()
                if data then
                    data = filter_from_table(data, "\r")
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                end
            end)
        end,
        stdout_buffered = false,
        stderr_buffered = false,
    })
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, {force = true})
        vim.api.nvim_buf_delete(buf, {force = true})
    end, {buffer = true})
end

local function check_updates(opts)
    _check_updates(nil, nil, false)
end

local function commit(opts)
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, 0, window_opts)
    vim.api.nvim_buf_set_name(buf, 'svn_commit')
    window_opts.title = "SVN Commit"
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_buf_delete(buf, {force = true})
        vim.api.nvim_win_close(win, {force = true})
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, 'i', false)
    end, {buffer = true})
    vim.keymap.set('i', '<CR>', function()
        local buf_text = vim.api.nvim_buf_get_lines(buf, 1, -1, false)
        local output = shell.do_system_cmd('svn commit -m ' .. buf_text[1])
        local output_table = string_to_table(output)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, output_table)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, {"Press 'q' to exit."})
    end, {buffer = true})
    _check_updates(buf, win, true)
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
                    data = filter_from_table(data, "\r")
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                end
            end)
        end,
        on_stderr = function(_, data)
            vim.schedule(function()
                if data then
                    data = filter_from_table(data, "\r")
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                end
            end)
        end,
        stdout_buffered = false,
        stderr_buffered = false,
    })
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, {force = true})
        vim.api.nvim_buf_delete(buf, {force = true})
    end, {buffer = true})
end

local function diff()
    local modified = shell.do_system_cmd('svn status --quiet')
    local modified_table = string_to_table(modified)
    for index, line in ipairs(modified_table) do
        local line = string.sub(line, STATUS_COL_LENGTH)
        local buf = vim.api.nvim_create_buf(false, true)
        local pristine_copy = shell.do_system_cmd('svn cat ' .. line)
        local pristine_copy_table = string_to_table(pristine_copy)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, pristine_copy_table)
        local filetype = vim.api.nvim_get_option_value('filetype', {scope = 'local'})
        --set the filetype to be the same as the left view
        vim.api.nvim_set_option_value('filetype', filetype, {buf = buf})
        shell.do_cmd(string.format("tabnew %s", line))
        --from this point on current window and buffer is a new tab
        local left_win = vim.api.nvim_get_current_win()
        local right_win = vim.api.nvim_open_win(buf, 0, {split = 'right', win = 0})
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

local function resolve()
    local modified = shell.do_system_cmd('svn status --quiet')
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
        local tmp_file = string.format("%s.tmp")
        shell.do_system_cmd({'rm'}, {tmp_file})
    end
end

local function blame()
    shell.do_cmd("tabnew | r ! svn blame #")
end

local function status(opts)
    _status()
end

vim.api.nvim_create_user_command('SvnCommit', commit, {})
vim.api.nvim_create_user_command('SvnDiff', diff, {})
vim.api.nvim_create_user_command('SvnBlame', blame, {})
vim.api.nvim_create_user_command('SvnLog', log, {})
vim.api.nvim_create_user_command('SvnUp', up, {})
vim.api.nvim_create_user_command('SvnCheck', check_updates, {})
vim.api.nvim_create_user_command('SvnStatus', status, {})

return svn
