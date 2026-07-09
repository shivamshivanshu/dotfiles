local M = {}

M.config = {
	timezone_offset = 0.0,
	granularity = "ns",
}

local last_result = nil

local FRAC_DIGITS = { ns = 9, us = 6, ms = 3, s = 0 }

local function frac_digits()
	return FRAC_DIGITS[M.config.granularity] or 9
end

local function offset_seconds()
	return M.config.timezone_offset * 3600
end

-- os.time treats its table as LOCAL wall-clock; correct for the machine TZ to
-- get a true UTC epoch so the configured offset is the sole source of truth.
local function utc_time(parts)
	local secs = os.time(parts)
	local utc = os.date("!*t", secs)
	utc.isdst = nil
	return secs + os.difftime(secs, os.time(utc))
end

local function epoch_to_readable(epoch_str)
	if not epoch_str:match("^%d+$") then
		vim.notify("Invalid epoch timestamp", vim.log.levels.ERROR)
		return nil
	end

	-- Split off the sub-second portion textually: full ns epochs (~1.7e18)
	-- exceed double exactness, so arithmetic only touches the small seconds part.
	local digits = frac_digits()
	local sec_str, frac_str
	if digits == 0 then
		sec_str, frac_str = epoch_str, ""
	elseif #epoch_str <= digits then
		sec_str = "0"
		frac_str = string.rep("0", digits - #epoch_str) .. epoch_str
	else
		sec_str = epoch_str:sub(1, #epoch_str - digits)
		frac_str = epoch_str:sub(#epoch_str - digits + 1)
	end

	local adjusted_time = tonumber(sec_str) + offset_seconds()
	local date_str = os.date("!%Y-%m-%d %H:%M:%S", adjusted_time)
	local result = digits > 0 and (date_str .. "." .. frac_str) or date_str
	last_result = result
	print(
		string.format(
			"Epoch %s → %s (granularity: %s, offset: %+.1fh)",
			epoch_str,
			result,
			M.config.granularity,
			M.config.timezone_offset
		)
	)
	return result
end

local function readable_to_epoch(date_str)
	local year, month, day, hour, min, sec, frac = date_str:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)[.:]?(%d*)")
	if not year then
		vim.notify("Invalid format. Use: YYYY-MM-DD HH:MM:SS or YYYY-MM-DD HH:MM:SS.frac", vim.log.levels.ERROR)
		return nil
	end

	local seconds = utc_time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec),
	}) - offset_seconds()

	-- Reassemble as a string: append the sub-second digits (left-aligned decimal
	-- fraction, padded/truncated to the granularity) rather than doing float math.
	local digits = frac_digits()
	local epoch = string.format("%d", seconds)
	if digits > 0 then
		epoch = epoch .. (frac .. string.rep("0", digits)):sub(1, digits)
	end

	local result = epoch
	last_result = result
	print(
		string.format(
			"Date %s → %s (granularity: %s, offset: %+.1fh)",
			date_str,
			result,
			M.config.granularity,
			M.config.timezone_offset
		)
	)
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

-- Marks are charwise-precise but may be stale; trust them only when they
-- match the range the user actually gave
local function convert_range(args)
	if args.line1 == vim.fn.line("'<") and args.line2 == vim.fn.line("'>") then
		return convert_selection()
	end
	return convert(table.concat(vim.fn.getline(args.line1, args.line2), "\n"))
end

function M.setup()
	vim.api.nvim_create_user_command("Epoch", function(args)
		if args.args ~= "" then
			convert(args.args)
		elseif args.range > 0 then
			convert_range(args)
		else
			vim.notify("Usage: :Epoch <ts|date> or :'<,'>Epoch", vim.log.levels.WARN)
		end
	end, { nargs = "?", range = true, desc = "Convert epoch ↔ date/time (arg or visual range)" })

	vim.api.nvim_create_user_command("EpochCopy", function(args)
		if args.range > 0 then
			convert_range(args)
		end
		if last_result then
			vim.fn.setreg("+", last_result)
			print("Copied: " .. last_result)
		else
			vim.notify("No conversion result to copy", vim.log.levels.WARN)
		end
	end, { range = true, desc = "Copy conversion result (of range if given)" })

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
end

return M
