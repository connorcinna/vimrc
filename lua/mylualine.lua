local svn_counts = nil
local svn_running = false

local function bold_hl()
	local suffix = require("lualine.highlight").get_mode_suffix() -- e.g. "_normal"
	local base = "lualine_b" .. suffix
	local bold = "SvnStatusBold" .. suffix
	local hl = vim.api.nvim_get_hl(0, { name = base, link = false })
	hl.bold = true
	vim.api.nvim_set_hl(0, bold, hl)
	return bold, base
end

local function svnstatus()
	if not vim.uv.fs_stat(".svn") then
		svn_counts = nil
		return ""
	end

	if not svn_running then
		svn_running = true
		vim.system({ "svn", "status" }, { text = true }, function(obj)
			local counts = {}
			for line in string.gmatch(obj.stdout or "", "[^\n]+") do
				local status = string.sub(line, 1, 1)
				counts[status] = (counts[status] or 0) + 1
			end
			svn_counts = counts
			svn_running = false

			vim.schedule(function()
				require("lualine").refresh()
			end)
		end)
	end

	if not svn_counts then
		return ""
	end

	local bold, base = bold_hl()
	local keys = vim.tbl_keys(svn_counts)
	table.sort(keys)
	local parts = {}
	for _, k in ipairs(keys) do
		table.insert(parts, "%#" .. bold .. "#" .. k .. "%#" .. base .. "#: " .. svn_counts[k])
	end
	return " " .. table.concat(parts, " ")
end

require("lualine").setup({
	options = {
		component_separators = "",
		section_separators = "",
		refresh = {
			statusline = 2000,
		},
	},
	globalstatus = true,
	sections = {
		lualine_a = { "mode" },
		lualine_b = { svnstatus, {'branch', icon = ''}, "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
			-- LSP status
			{
				function()
                    local line = "󰒋"
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					if #clients > 0 then
                        line = line .. " " .. clients[0].name
					end
					return line
				end,
				color = function()
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					if #clients > 0 then
						return nil
					else
						return "Comment"
					end
				end,
			},
			-- Formatter status
			{
				function()
					return "󰉣"
				end,
				color = function()
					local has_conform, conform = pcall(require, "conform")
					if not has_conform then
						return "Comment"
					end
					local formatters = conform.list_formatters(0)
					if #formatters > 0 then
						return nil
					else
						return "Comment"
					end
				end,
			},
		},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	extensions = { "mason" },
})
