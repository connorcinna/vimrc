local shell = {}

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

-- swap to cmd.exe to do a system command and then back to powershell
function shell.do_system_cmd(args)
    if vim.fn.has('win32') == 1 then
        vim.o.shell="C:\\Windows\\System32\\cmd.exe"
        output = vim.fn.system(args)
        vim.o.shell= "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
        return output
    else
        return vim.fn.system(args)
    end
end

return shell
