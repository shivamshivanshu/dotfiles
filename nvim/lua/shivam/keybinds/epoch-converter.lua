local M = {}

M.config = {
	timezone_offset = 0.0,
	granularity = "ns",
}

local last_result = nil

local function get_divisor()
	local divisors = { ns = 1e9, us = 1e6, ms = 1e3, s = 1 }
	return divisors[M.config.granularity] or 1e9
end

local function apply_timezone(timestamp)
	return timestamp + (M.config.timezone_offset * 3600)
end

local function epoch_to_readable(epoch_str)
	local epoch = tonumber(epoch_str)
	if not epoch then
		vim.notify("Invalid epoch timestamp", vim.log.levels.ERROR)
		return nil
	end

	local seconds = math.floor(epoch / get_divisor())
	local adjusted_time = apply_timezone(seconds)
	local date_str = os.date("%Y-%m-%d %H:%M:%S", adjusted_time)
	local remainder = epoch % get_divisor()

	local result = string.format("%s.%09d", date_str, remainder)
	last_result = result
	print(string.format("Epoch %s → %s (granularity: %s, offset: %+.1fh)", epoch_str, result, M.config.granularity, M.config.timezone_offset))
	return result
end

local function readable_to_epoch(date_str)
	local year, month, day, hour, min, sec, ms = date_str:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+):?(%d*)")
	if not year then
		vim.notify("Invalid format. Use: YYYY-MM-DD HH:MM:SS or YYYY-MM-DD HH:MM:SS:mmm", vim.log.levels.ERROR)
		return nil
	end

	local time = os.time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec),
	})

	local adjusted_time = time - (M.config.timezone_offset * 3600)
	local epoch = adjusted_time * get_divisor()

	if ms and ms ~= "" then
		local ms_nanos = tonumber(ms) * 1e6
		epoch = epoch + ms_nanos
	end

	local result = string.format("%d", epoch)
	last_result = result
	print(string.format("Date %s → %s (granularity: %s, offset: %+.1fh)", date_str, result, M.config.granularity, M.config.timezone_offset))
	return result
end

local function convert(input)
	input = input:match("^%s*(.-)%s*$")

	if input:match("^%d+$") then
		return epoch_to_readable(input)
	else
		return readable_to_epoch(input)
	end
end

local function convert_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local lines = vim.fn.getline(start_pos[2], end_pos[2])

	if #lines == 0 then
		return
	end

	local text = table.concat(lines, "\n")
	if #lines == 1 then
		text = text:sub(start_pos[3], end_pos[3])
	end

	return convert(text)
end

function M._convert_selection()
	return convert_selection()
end

function M._convert_and_copy()
	convert_selection()
	if last_result then
		vim.fn.setreg("+", last_result)
		print("Copied: " .. last_result)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("Epoch", function(args)
		convert(args.args)
	end, { nargs = 1, desc = "Convert epoch ↔ date/time (auto-detect)" })

	vim.api.nvim_create_user_command("EpochSetTimezone", function(args)
		M.config.timezone_offset = tonumber(args.args) or 0
		print("Timezone offset: " .. M.config.timezone_offset .. "h")
	end, { nargs = 1, desc = "Set timezone offset in hours" })

	vim.api.nvim_create_user_command("EpochSetGranularity", function(args)
		local granularity = args.args
		if granularity == "ns" or granularity == "us" or granularity == "ms" or granularity == "s" then
			M.config.granularity = granularity
			print("Granularity: " .. granularity)
		else
			vim.notify("Invalid granularity. Use: ns, us, ms, or s", vim.log.levels.ERROR)
		end
	end, { nargs = 1, desc = "Set epoch granularity (ns/us/ms/s)" })

	vim.keymap.set("x", "<leader>ec", ":<C-u>lua require('shivam.keybinds.epoch-converter')._convert_selection()<CR>", { desc = "Epoch convert (selection)" })
	vim.keymap.set("x", "<leader>ee", ":<C-u>lua require('shivam.keybinds.epoch-converter')._convert_and_copy()<CR>", { desc = "Epoch convert and copy (selection)" })
	vim.keymap.set("n", "<leader>ey", function()
		if last_result then
			vim.fn.setreg("+", last_result)
			print("Copied: " .. last_result)
		else
			vim.notify("No conversion result to copy", vim.log.levels.WARN)
		end
	end, { desc = "Copy last conversion result" })
end

return M
