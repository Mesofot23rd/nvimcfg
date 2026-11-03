--- Run the file in the current buffer as a standalone program.
---
--- This is the single-file counterpart to the project runner.  It reuses the
--- same terminal window, notifications, and process state, so `:ProjectStop`
--- works for file runs too.  Compiled files are written below
--- `<root>/.build/file_runner/`, keeping the project root clean.
local M = {}

local util = require "custom.code_runner.util"
local config = require "custom.code_runner.config"
local runner = require "custom.code_runner.runner"
local languages = require "custom.code_runner.providers.languages"

local notify = runner.notify

--------------------------------------------------------------------------------
-- Command builders
--------------------------------------------------------------------------------

--- Directory used for single-file build artifacts.
--- @param root string
--- @return string
local function artifact_dir(root) return util.join(root, config.get().build_dir or ".build", "file_runner") end

--- Java's main class, including its package when one is declared.
--- @param entry string
--- @return string
local function java_main_class(entry)
	local content = util.read_file(entry) or ""
	local package = content:match "^%s*package%s+([%w_%.]+)%s*;"
	local class = util.stem(entry)
	return package and (package .. "." .. class) or class
end

--- Build and run commands for compiled languages.
---
--- Each entry returns `build, run`, both already shell-quoted.
local compiled = {
	c = function(ctx)
		local compiler = util.first_executable("cc", "gcc", "clang") or "cc"
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			compiler .. " -O2 " .. util.q(ctx.entry) .. " -o " .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	cpp = function(ctx)
		local compiler = util.first_executable("c++", "g++", "clang++") or "c++"
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			compiler .. " -O2 " .. util.q(ctx.entry) .. " -o " .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	rust = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"rustc -O " .. util.q(ctx.entry) .. " -o " .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	go = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"go build -o " .. util.q(ctx.exe) .. " " .. util.q(ctx.entry),
		},
			util.q(ctx.exe)
	end,

	zig = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"zig build-exe " .. util.q(ctx.entry) .. " -O ReleaseFast -femit-bin=" .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	swift = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"swiftc -O " .. util.q(ctx.entry) .. " -o " .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	java = function(ctx)
		local classes = util.join(ctx.build_dir, "classes")
		return util.chain {
			"mkdir -p " .. util.q(classes),
			"javac -d " .. util.q(classes) .. " " .. util.q(ctx.entry),
		},
			"java -cp " .. util.q(classes) .. " " .. util.q(java_main_class(ctx.entry))
	end,

	kotlin = function(ctx)
		local jar = util.join(ctx.build_dir, ctx.name .. ".jar")
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"kotlinc " .. util.q(ctx.entry) .. " -include-runtime -d " .. util.q(jar),
		},
			"java -jar " .. util.q(jar)
	end,

	fortran = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"gfortran -O2 " .. util.q(ctx.entry) .. " -o " .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	asm = function(ctx)
		local object = util.join(ctx.build_dir, ctx.name .. ".o")
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"nasm -f elf64 " .. util.q(ctx.entry) .. " -o " .. util.q(object),
			"ld " .. util.q(object) .. " -o " .. util.q(ctx.exe),
		},
			util.q(ctx.exe)
	end,

	nim = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"nim c -d:release --out:" .. util.q(ctx.exe) .. " " .. util.q(ctx.entry),
		},
			util.q(ctx.exe)
	end,

	crystal = function(ctx)
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			"crystal build --release -o " .. util.q(ctx.exe) .. " " .. util.q(ctx.entry),
		},
			util.q(ctx.exe)
	end,

	d = function(ctx)
		local compiler = util.first_executable("dmd", "ldc2", "gdc") or "dmd"
		local output = compiler == "gdc" and ("-o " .. util.q(ctx.exe)) or ("-of=" .. util.q(ctx.exe))
		return util.chain {
			"mkdir -p " .. util.q(ctx.build_dir),
			compiler .. " -O " .. output .. " " .. util.q(ctx.entry),
		},
			util.q(ctx.exe)
	end,
}

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Build a runnable plan for the current buffer without starting it.
--- @param bufnr integer|nil
--- @return table|nil plan
--- @return string|nil error
function M.resolve(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(bufnr)
	if not path or path == "" then return nil, "The current buffer is not saved to a file." end

	local root = vim.fn.getcwd()
	local entry = util.abspath(path)
	local language = languages.from_buffer(bufnr)
	if not language then
		local extension = util.extension(entry)
		return nil, "Unsupported file type: " .. (extension ~= "" and extension or "<none>")
	end

	local ctx = {
		root = root,
		entry = entry,
		name = util.stem(entry),
		build_dir = artifact_dir(root),
	}
	ctx.exe = util.join(ctx.build_dir, ctx.name)

	local plan = {
		id = "file:" .. language.id .. ":" .. ctx.name,
		label = "file " .. language.label .. " - " .. util.basename(entry),
		root = root,
		entry = entry,
		language = language.id,
	}

	local build_command = compiled[language.id]
	if build_command then
		plan.kind = "compiled"
		plan.build, plan.run = build_command(ctx)
		return plan
	end

	if language.kind == "interpreted" and language.run then
		plan.kind = "interpreted"
		plan.run = language.run(ctx)
		return plan
	end

	return nil, "No single-file runner for " .. language.label .. "."
end

--- Run the current buffer as a standalone file.
--- @param opts table|nil  { bufnr = integer }
--- @return boolean
function M.run(opts)
	opts = opts or {}
	local plan, err = M.resolve(opts.bufnr)
	if not plan then
		notify(err or "Cannot run the current file.", vim.log.levels.WARN)
		return false
	end
	return runner.run(plan, { mode = "all" })
end

return M
