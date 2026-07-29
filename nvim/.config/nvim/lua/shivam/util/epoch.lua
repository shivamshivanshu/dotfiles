local actions = require("shivam.util.actions")

local M = {}

M.config = {
	timezone_offset = 5.5,
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
	return digits > 0 and (date_str .. "." .. frac_str) or date_str
end

local function readable_to_epoch(date_str)
	local year, month, day, hour, min, sec, frac = date_str:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)[.:]?(%d*)")
	if not year then
		return nil, "Invalid format. Use: YYYY-MM-DD HH:MM:SS or YYYY-MM-DD HH:MM:SS.frac"
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

	return epoch
end

local function convert(input)
	input = vim.trim(input)

	local result, err
	if input:match("^%d+$") then
		result, err = epoch_to_readable(input)
	else
		result, err = readable_to_epoch(input)
	end

	if result then
		last_result = result
	end
	return result, err
end

local function convert_and_print(input)
	input = vim.trim(input)
	local result, err = convert(input)
	if not result then
		vim.notify(err, vim.log.levels.ERROR)
		return nil
	end

	print(
		string.format(
			"%s %s → %s (granularity: %s, offset: %+.1fh)",
			input:match("^%d+$") and "Epoch" or "Date",
			input,
			result,
			M.config.granularity,
			M.config.timezone_offset
		)
	)
	return result
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

	return convert_and_print(text)
end

-- Marks are charwise-precise but may be stale; trust them only when they
-- match the range the user actually gave
local function convert_range(args)
	if args.line1 == vim.fn.line("'<") and args.line2 == vim.fn.line("'>") then
		return convert_selection()
	end
	return convert_and_print(table.concat(vim.fn.getline(args.line1, args.line2), "\n"))
end

local STATUS_NS = vim.api.nvim_create_namespace("shivam.epoch")
local FLOAT_WIDTH = 44
local FLOAT_HEIGHT = 2

local function float_title()
	return string.format(" Epoch (%s, %+.1fh) ", M.config.granularity, M.config.timezone_offset)
end

local function render_status(buf, text, hl)
	vim.api.nvim_buf_clear_namespace(buf, STATUS_NS, 0, -1)
	vim.api.nvim_buf_set_extmark(buf, STATUS_NS, 0, 0, { virt_lines = { { { text, hl } } } })
end

local function convert_in_float(buf)
	local input = vim.trim(vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or "")
	if input == "" then
		return
	end

	local result, err = convert(input)
	if result then
		render_status(buf, "→ " .. result, "String")
	else
		render_status(buf, "✗ " .. err, "ErrorMsg")
	end
end

local function yank_result()
	if not last_result then
		vim.notify("No conversion result to copy", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", last_result)
	vim.notify("Copied: " .. last_result)
end

local function open_float()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = FLOAT_WIDTH,
		height = FLOAT_HEIGHT,
		row = math.floor((vim.o.lines - FLOAT_HEIGHT) / 2),
		col = math.floor((vim.o.columns - FLOAT_WIDTH) / 2),
		style = "minimal",
		border = "rounded",
		title = float_title(),
		title_pos = "center",
		footer = " <CR> convert · y yank · q close ",
		footer_pos = "center",
	})

	render_status(buf, "  timestamp or YYYY-MM-DD HH:MM:SS[.frac]", "Comment")

	-- Mapped in insert mode too, so <CR> never splits the single input line.
	vim.keymap.set({ "n", "i" }, "<CR>", function()
		convert_in_float(buf)
	end, { buffer = buf, desc = "Convert input" })
	vim.keymap.set("n", "y", yank_result, { buffer = buf, desc = "Yank conversion result" })
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf, desc = "Close epoch window" })

	vim.cmd.startinsert()
end

function M.setup()
	actions.add("epoch.convert", function(args)
		args = args or {}
		if args.args and args.args ~= "" then
			convert_and_print(args.args)
		elseif args.range and args.range > 0 then
			convert_range(args)
		else
			open_float()
		end
	end, {
		desc = "Convert epoch ↔ date/time (arg, visual range, or popup)",
		cmd = "Epoch",
		cmd_opts = { nargs = "?", range = true },
	})

	actions.add("epoch.copy", function(args)
		args = args or {}
		if args.range and args.range > 0 then
			convert_range(args)
		end
		yank_result()
	end, { desc = "Copy conversion result (of range if given)", cmd = "EpochCopy", cmd_opts = { range = true } })

	actions.add("epoch.set_timezone", function(args)
		local offset = tonumber(args and args.args)
		if not offset then
			vim.notify("Usage: :EpochSetTimezone <hours>", vim.log.levels.WARN)
			return
		end
		M.config.timezone_offset = offset
		print("Timezone offset: " .. offset .. "h")
	end, { desc = "Set timezone offset in hours", cmd = "EpochSetTimezone", cmd_opts = { nargs = 1 } })

	actions.add("epoch.set_granularity", function(args)
		local granularity = args and args.args
		if granularity == "ns" or granularity == "us" or granularity == "ms" or granularity == "s" then
			M.config.granularity = granularity
			print("Granularity: " .. granularity)
		else
			vim.notify("Invalid granularity. Use: ns, us, ms, or s", vim.log.levels.ERROR)
		end
	end, { desc = "Set epoch granularity (ns/us/ms/s)", cmd = "EpochSetGranularity", cmd_opts = { nargs = 1 } })
end

return M
