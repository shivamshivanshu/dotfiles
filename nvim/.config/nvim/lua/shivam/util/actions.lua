-- Central registry of named, user-callable actions. Keybinds and user
-- commands are thin wrappers over registry entries, so a keybind can be
-- deleted while the action stays callable (:Cmd or the Actions picker).
local M = {}

local registry = {}
local order = {}

-- Idempotent: lazy.nvim re-executes spec modules on reload, so
-- re-registration overwrites in place.
function M.add(name, fn, opts)
	opts = opts or {}
	if not registry[name] then
		table.insert(order, name)
	end
	registry[name] = { fn = fn, desc = opts.desc or name, cmd = opts.cmd, keys = {} }
	if opts.cmd then
		local cmd_opts = vim.tbl_extend("force", { desc = opts.desc }, opts.cmd_opts or {})
		vim.api.nvim_create_user_command(opts.cmd, fn, cmd_opts)
	end
end

function M.run(name)
	local action = assert(registry[name], "unknown action: " .. name)
	action.fn()
end

-- Late-binding wrapper so keymaps survive an action being re-registered.
function M.fn(name)
	return function()
		M.run(name)
	end
end

-- Bind a key to a registered action; records the lhs so the picker can show it.
function M.map(mode, lhs, name, opts)
	local action = assert(registry[name], "unknown action: " .. name)
	opts = opts or {}
	if not vim.tbl_contains(action.keys, lhs) then
		table.insert(action.keys, lhs)
	end
	vim.keymap.set(mode, lhs, M.fn(name), { desc = opts.desc or action.desc, buffer = opts.buffer })
end

function M.list()
	local items = {}
	for _, name in ipairs(order) do
		local action = registry[name]
		local binding = #action.keys > 0 and table.concat(action.keys, " ")
			or (action.cmd and (":" .. action.cmd) or "")
		table.insert(items, { name = name, desc = action.desc, fn = action.fn, cmd = action.cmd, binding = binding })
	end
	return items
end

function M.picker()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local telescope_actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")

	local displayer = entry_display.create({
		separator = "  ",
		items = { { width = 30 }, { width = 16 }, { remaining = true } },
	})

	pickers
		.new({}, {
			prompt_title = "Actions",
			finder = finders.new_table({
				results = M.list(),
				entry_maker = function(item)
					return {
						value = item,
						ordinal = item.name .. " " .. item.desc .. " " .. item.binding,
						display = function(entry)
							return displayer({ entry.value.name, entry.value.binding, entry.value.desc })
						end,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				telescope_actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					telescope_actions.close(prompt_bufnr)
					if not entry then
						return
					end
					local item = entry.value
					if item.cmd then
						vim.schedule(function()
							vim.api.nvim_feedkeys(":" .. item.cmd .. " ", "n", false)
						end)
					else
						item.fn()
					end
				end)
				return true
			end,
		})
		:find()
end

return M
