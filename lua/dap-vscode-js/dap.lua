local M = {}
local dap = require("dap")
local js_adapter = require("dap-vscode-js.adapter")

local DAP_MAPPINGS = {
	node = "pwa-node",
	chrome = "pwa-chrome",
	msedge = "pwa-msedge",
	node_terminal = "node-terminal", -- This seems to be a direct mapping. Adjust if necessary.
	extensionHost = "pwa-extensionHost",
}

local function is_valid_adapter(adapter)
	return DAP_MAPPINGS[adapter] or vim.tbl_contains(vim.tbl_values(DAP_MAPPINGS), adapter)
end

local function filter_adapters(list)
	return vim.tbl_filter(is_valid_adapter, list)
end

function M.attach_adapters(config)
	local adapter_list = filter_adapters(config.adapters or vim.tbl_keys(DAP_MAPPINGS))

	for _, adapter in ipairs(adapter_list) do
		-- Check if the adapter starts with "pwa-" and issue a warning
		if string.match(adapter, "^pwa%-") then
			vim.api.nvim_err_writeln(
				"Warning: It's recommended to use the shortened adapter name instead of '" .. adapter .. "'."
			)
		end

		local mapped_value = DAP_MAPPINGS[adapter] or adapter

		-- Using the key for the dap.adapters table, but mapped value for the generation
		dap.adapters[adapter] = js_adapter.generate_adapter(mapped_value, config)
		dap.adapters[adapter].host = "127.0.0.1"
	end
end

return M
