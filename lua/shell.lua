local shell = {}

local util = require('util')

-- swap to cmd.exe to do a command and then back to powershell
function shell.do_cmd(args)
    if vim.fn.has('win32') == 1 then
        vim.o.shell="C:\\Windows\\System32\\cmd.exe"
        vim.cmd(args)
        vim.o.shell= "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
    else
        vim.cmd(args)
    end
end

-- swap to cmd.exe to do a synchronous system command and then back to powershell
function shell.do_system_cmd(args)
    if vim.fn.has('win32') == 1 then
        vim.o.shell="C:\\Windows\\System32\\cmd.exe"
        local output = vim.fn.system(args)
        vim.o.shell= "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
        return output
    else
        local output = vim.fn.system(args)
        return output
    end
end

function shell.do_async_cmd(args, callback)
    local window_opts = {
        relative = "editor",
        width = 90,
        height = 15,
        col = vim.o.columns-1,
        row = vim.o.lines-1,
        anchor = "NW",
        style = "minimal",
        border = { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" },
        title = string.format(table.concat(args, ' ')),
        title_pos = "center"
    }
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'async_shell')
    local win = vim.api.nvim_open_win(buf, false, window_opts)
    local function on_done(obj)
        if obj.code ~= 0 then
            vim.schedule(function()
                vim.notify("Command failed:\n" .. obj.stderr, vim.log.levels.ERROR)
                vim.api.nvim_win_close(win, {force = true})
                vim.api.nvim_buf_delete(buf, {force = true})
                if callback ~= nil then
                    callback()
                end
            end)
        else
            vim.schedule(function()
                vim.notify("Command completed: " .. table.concat(args, ' '))
                vim.api.nvim_win_close(win, {force = true})
                vim.api.nvim_buf_delete(buf, {force = true})
                if callback ~= nil then
                    callback()
                end
            end)
        end
    end
    local function on_stdout_stderr(err, data)
        if err then
            vim.schedule(function()
                vim.notify("Shell stdout/stderr read error: " .. err, vim.log.levels.ERROR)
            end)
            return
        end
        if data then
            vim.schedule(function()
                data = util.string_to_table(data)
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                if vim.api.nvim_win_is_valid(win) then
                    local line_count = vim.api.nvim_buf_line_count(buf)
                    vim.api.nvim_win_set_cursor(win, {line_count, 0})
                end
            end)
        end
    end
    vim.system(args, {text = true, stdout = on_stdout_stderr, stderr = on_stdout_stderr}, on_done)
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(win, {force = true})
        vim.api.nvim_buf_delete(buf, {force = true})
    end, {buffer = buf})
end

return shell
