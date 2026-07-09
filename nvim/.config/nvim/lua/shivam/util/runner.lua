local M = {}

M.cpp = {
	cc = nil,
	cc_candidates = {
		"/opt/homebrew/opt/llvm/bin/clang++",
		"/usr/local/opt/llvm/bin/clang++",
		"clang++",
		"g++",
	},
	cflags = {
		"-Wall",
		"-Wextra",
		"-pedantic",
		"-std=c++23",
		"-Wshadow",
		"-Wformat=2",
		"-Wfloat-equal",
		"-Wconversion",
		"-Wshift-overflow",
		"-Wcast-qual",
		"-Wcast-align",
		"-D_GLIBCXX_DEBUG",
		"-D_GLIBCXX_DEBUG_PEDANTIC",
		"-D_FORTIFY_SOURCE=2",
		"-DLOCAL_JUDGE",
	},
	sanitizer = {
		"-fsanitize=address",
		"-fsanitize=undefined",
		"-fno-sanitize-recover",
		"-fstack-protector",
	},
	modes = {
		release = { "-O2" },
		debug = { "-O0", "-g" },
	},
	extra = {},
	out = "a",
}

M.term = {
	height = 15,
	input_file = "input.txt",
	output_file = "output.txt",
}

local function file_info()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return nil
	end
	local name = vim.fs.basename(path)
	return {
		path = path,
		dir = vim.fs.dirname(path),
		name = name,
		stem = (name:gsub("%.[^.]+$", "")),
		ext = name:match("%.([^.]+)$") or "",
	}
end

local function require_file()
	local f = file_info()
	if not f then
		vim.notify("No file in buffer", vim.log.levels.WARN)
	end
	return f
end

local function save_if_modifiable()
	if vim.bo.modifiable and vim.bo.modified then
		vim.cmd("silent write")
	end
end

local function run_in_term(shell_cmd, cwd, title)
	vim.cmd("botright " .. M.term.height .. "split | enew")
	vim.bo.bufhidden = "wipe"
	local buf = vim.api.nvim_get_current_buf()
	if title then
		vim.api.nvim_buf_set_name(buf, "runner: " .. title)
	end
	vim.fn.jobstart({ "bash", "-c", shell_cmd }, {
		term = true,
		cwd = cwd,
		on_exit = function(_, code)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end
				if code == 0 then
					vim.api.nvim_buf_delete(buf, { force = true })
				else
					vim.keymap.set("n", "q", "<cmd>bd!<cr>", { buffer = buf, desc = "Close runner" })
					pcall(vim.cmd, "stopinsert")
				end
			end)
		end,
	})
	vim.cmd("startinsert")
end

local function resolve_cc()
	if M.cpp.cc and vim.fn.executable(M.cpp.cc) == 1 then
		return M.cpp.cc
	end
	for _, c in ipairs(M.cpp.cc_candidates) do
		if vim.fn.executable(c) == 1 then
			M.cpp.cc = c
			return c
		end
	end
	return nil
end

local function build_cpp_args(cc, src, out, mode)
	local args = { cc }
	vim.list_extend(args, M.cpp.cflags)
	vim.list_extend(args, M.cpp.sanitizer)
	vim.list_extend(args, M.cpp.modes[mode] or M.cpp.modes.release)
	vim.list_extend(args, M.cpp.extra)
	vim.list_extend(args, { src, "-o", out })
	return args
end

function M.build(mode)
	mode = mode or "release"
	local f = require_file()
	if not f then
		return false
	end
	if f.ext ~= "cpp" then
		vim.notify("Build supports only .cpp (got ." .. f.ext .. ")", vim.log.levels.WARN)
		return false
	end
	if not M.cpp.modes[mode] then
		vim.notify("Unknown build mode: " .. mode, vim.log.levels.ERROR)
		return false
	end
	local cc = resolve_cc()
	if not cc then
		vim.notify("No C++ compiler found. Tried: " .. table.concat(M.cpp.cc_candidates, ", "), vim.log.levels.ERROR)
		return false
	end
	save_if_modifiable()
	vim.notify("Building " .. f.name .. " [" .. mode .. "] with " .. cc .. "...")
	local res = vim.system(build_cpp_args(cc, f.name, M.cpp.out, mode), { cwd = f.dir, text = true }):wait()
	if res.code ~= 0 then
		vim.notify("Build failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR)
		return false
	end
	vim.notify("Build OK [" .. mode .. "] → " .. f.dir .. "/" .. M.cpp.out)
	return true
end

local function with_io(cmd_str, opts)
	if opts.stdin then
		cmd_str = cmd_str .. " < " .. vim.fn.shellescape(opts.stdin)
	end
	if opts.tee then
		-- pipefail so a crash isn't masked by tee's 0 and the buffer survives
		cmd_str = "set -o pipefail; " .. cmd_str .. " | tee " .. vim.fn.shellescape(opts.tee)
	end
	return cmd_str
end

local function run_cmd_for(f, opts)
	if f.ext == "cpp" then
		return with_io("./" .. M.cpp.out, opts)
	elseif f.ext == "py" then
		return with_io("python3 " .. vim.fn.shellescape(f.name), opts)
	end
	return nil
end

function M.run(opts)
	opts = opts or {}
	local f = require_file()
	if not f then
		return
	end
	save_if_modifiable()

	if f.ext == "cpp" then
		if not M.build(opts.mode) then
			return
		end
	elseif f.ext ~= "py" then
		vim.notify("Run not supported for ." .. f.ext, vim.log.levels.WARN)
		return
	end

	local cmd = run_cmd_for(f, opts)
	if not cmd then
		return
	end
	run_in_term(cmd, f.dir, f.name)
end

local function open_split(dir, fname, split_cmd)
	vim.cmd(split_cmd .. " " .. vim.fn.fnameescape(dir .. "/" .. fname))
end

function M.open_input()
	local f = require_file()
	if f then
		open_split(f.dir, M.term.input_file, "vsplit")
	end
end

function M.open_output()
	local f = require_file()
	if f then
		open_split(f.dir, M.term.output_file, "vsplit")
	end
end

function M.clean()
	local f = require_file()
	if not f then
		return
	end
	local target = f.dir .. "/" .. M.cpp.out
	if vim.uv.fs_stat(target) then
		os.remove(target)
		vim.notify("Removed " .. target)
	else
		vim.notify("Nothing to clean (" .. target .. " not found)")
	end
end

local function run_with_input()
	M.run({ stdin = M.term.input_file, tee = M.term.output_file })
end

function M.setup()
	local cmd = vim.api.nvim_create_user_command
	cmd("BuildRelease", function()
		M.build("release")
	end, { desc = "Runner: build .cpp with release flags (-O2)" })
	cmd("BuildWithDebugInfo", function()
		M.build("debug")
	end, { desc = "Runner: build .cpp with debug flags (-O0 -g)" })
	cmd("Run", function()
		M.run()
	end, { desc = "Runner: build (cpp) & run current file" })
	cmd("RunWithInput", run_with_input, { desc = "Runner: run with input.txt → tee output.txt" })
	cmd("OpenInput", M.open_input, { desc = "Runner: open input.txt (vsplit)" })
	cmd("OpenOutput", M.open_output, { desc = "Runner: open output.txt (vsplit)" })
	cmd("CleanBinary", M.clean, { desc = "Runner: clean built binary" })
end

return M
