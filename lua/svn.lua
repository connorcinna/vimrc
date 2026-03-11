local svn = {}

local shell = require('shell')

-- TODO check for if you need to update first
local function commit()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'commit_message')
    local win = vim.api.nvim_open_win(buf, 0, {
	    relative = 'cursor',
	    width = 90,
	    height = 30,
	    col = 0,
	    row = 1,
	    anchor = 'NW',
	    style = 'minimal',
		border = { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" },
		title = 'Enter commit message',
		title_pos = 'center',
    })
    vim.keymap.set('i', '<CR>', function()
        local buf_text = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local output = shell.do_system_cmd(string.format('svn commit -m "%s"', buf_text[1]))
        vim.api.nvim_buf_delete(buf, {force = true})
        local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
        vim.api.nvim_feedkeys(esc, 'i', false)
    end, {buffer = true})
    vim.api.nvim_feedkeys("i", 'n', false)
end

local function diff()
    local modified = shell.do_system_cmd("svn status --quiet")
    local modified_table = {}
    for line in modified:gmatch("[^\r\n]+") do
        table.insert(modified_table, line)
    end
    for index, line in ipairs(modified_table) do
        --according to `svn help status`
        --The first seven columns in the output are each one character wide
        local line = string.sub(line, 7)
        shell.do_system_cmd(string.format("svn cat %s > %s.tmp", line, line))
        shell.do_cmd(string.format("tabnew %s", line))
        shell.do_cmd(string.format("vert diffsplit %s.tmp", line))
        shell.do_system_cmd(string.format("rm %s.tmp", line))
    end
end

local function blame()
    shell.do_cmd("tabnew | r ! svn blame #")
end


vim.api.nvim_create_user_command('SvnCommit', commit, {})
vim.api.nvim_create_user_command('SvnDiff', diff, {})
vim.api.nvim_create_user_command('SvnBlame', blame, {})

return svn
