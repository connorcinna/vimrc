local work_config = {}

--change this to false if not at work!
work_config.enabled = true and vim.fn.has("win32")

return work_config
