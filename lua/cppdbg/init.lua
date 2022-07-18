local cxt = require("plenary.context_manager")
local job = require("plenary.job")
local M = {}

local read_file = function(file)
	local with = cxt.with
	local open = cxt.open

	local res = with(open(file), function(reader)
		return reader:read("*all")
	end)
	return res
end

local open_file = function(file)
	local status_ok, data = pcall(read_file, file)

	if not status_ok then
		print("file not found")
		return
	end

	data = vim.json.decode(data)
	return data
end

M.build = function()
	local o = open_file("config.json")
	if o == nil or o.build == nil then
		return
	end
	vim.cmd("TermExec 2 cmd=" .. o.build .. ' dir="' .. vim.fn.getcwd() .. '" direction="horizontal"')
end

M.debug = function()
	local o = open_file("config.json")
    if o == nil or o.file == nil then
		return
	end
	local conf = {
		name = "Launch file",
		type = "cppdbg",
		request = "launch",
		program = o.file,
		cwd = "${workspaceFolder}",
		stopOnEntry = true,
        arg = o.args
	}

    require("dap").run(conf)
end

return M
