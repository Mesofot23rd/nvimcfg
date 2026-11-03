--- Provider resolution.
---
--- Resolution order:
---   1. Build tools detected at the project root, highest priority first.
---   2. Language of the current buffer, when no build tool produces a plan.
---   3. A scan of every built-in language for a likely entry point.
local M = {}

local util = require("custom.code_runner.util")
local config = require("custom.code_runner.config")
local languages = require("custom.code_runner.providers.languages")
local tools = require("custom.code_runner.providers.tools")

--------------------------------------------------------------------------------
-- Context / plan helpers
--------------------------------------------------------------------------------

--- @param root string
--- @return string
local function project_name(root)
	local configured = config.get().executable_name
	if type(configured) == "function" then
		local ok, name = pcall(configured, root)
		if ok and type(name) == "string" and name ~= "" then
			return name
		end
	elseif type(configured) == "string" and configured ~= "" then
		return configured
	end

	local name = util.basename(root)
	if name == "" or name == "/" or name == "\\" then
		return "program"
	end
	return name
end

--- @param root string
--- @param build_dir string
--- @return string
local function absolute_build_dir(root, build_dir)
	if build_dir:match("^/") or build_dir:match("^%a:[/\\]") then
		return util.abspath(build_dir)
	end
	return util.abspath(util.join(root, build_dir))
end

--- Build the context shared by providers.
--- @param root string
--- @param language_id string|nil
--- @return table
local function make_context(root, language_id)
	local name = project_name(root)
	local build_dir = absolute_build_dir(root, config.get().build_dir)
	local entry = language_id and languages.entrypoint(language_id, root) or nil
	local extension = util.is_windows() and ".exe" or ""

	return {
		root = root,
		name = name,
		build_dir = build_dir,
		exe = util.join(build_dir, name .. extension),
		entry = entry,
		entry_rel = entry and util.relative(root, entry) or nil,
	}
end

--- @param base string
--- @param entry string|nil
--- @param root string
--- @param marker string|nil
--- @return string
local function make_label(base, entry, root, marker)
	local parts = { base }
	if marker and marker ~= "" then
		parts[#parts + 1] = "(" .. marker .. ")"
	end
	if entry then
		parts[#parts + 1] = "• " .. util.relative(root, entry)
	end
	return table.concat(parts, " ")
end

--- @param language table
--- @param root string
--- @return table|nil
local function plan_from_language(language, root)
	local requires_entry = language.requires_entry ~= false
	local entry = languages.entrypoint(language.id, root)
	if requires_entry and not entry then
		return nil
	end

	local ctx = make_context(root, language.id)
	ctx.entry = entry

	local build = language.build and language.build(ctx, util) or nil
	local run = language.run and language.run(ctx, util) or nil
	if not build and not run then
		return nil
	end

	return {
		id = language.id,
		provider_type = "language",
		language = language.id,
		label = make_label(language.label, entry, root),
		kind = language.kind,
		root = root,
		build_dir = ctx.build_dir,
		entry = entry,
		build = build,
		run = run,
		ctx = ctx,
	}
end

--- @param tool table
--- @param root string
--- @param marker string|nil
--- @return table|nil
local function plan_from_tool(tool, root, marker)
	local ctx = make_context(root, tool.language)
	local ok, result = pcall(tool.plan, ctx, util, config.get())
	if not ok or type(result) ~= "table" then
		return nil
	end

	local entry = result.entry or ctx.entry
	ctx.entry = entry
	ctx.entry_rel = entry and util.relative(root, entry) or nil

	if not result.build and not result.run then
		return nil
	end

	return {
		id = tool.id,
		provider_type = "tool",
		language = result.language or tool.language,
		label = result.label or make_label(tool.label, entry, root, marker),
		kind = result.kind or tool.kind,
		root = root,
		build_dir = ctx.build_dir,
		entry = entry,
		marker = marker,
		build = result.build,
		run = result.run,
		ctx = ctx,
	}
end

--------------------------------------------------------------------------------
-- Detection / resolution
--------------------------------------------------------------------------------

--- Detect build tools whose marker files exist at `root`.
--- @param root string
--- @return { tool: table, marker: string }[]
function M.detect_tools(root)
	local hits = {}
	for _, tool in ipairs(tools.list) do
		local marker = tools.detect(tool, root)
		if marker then
			hits[#hits + 1] = { tool = tool, marker = marker }
		end
	end

	table.sort(hits, function(a, b)
		if a.tool.priority ~= b.tool.priority then
			return a.tool.priority > b.tool.priority
		end
		return a.tool.id < b.tool.id
	end)
	return hits
end

--- Resolve all runnable plans for a project.
--- @param opts table|nil
--- @return { root: string, tools: table[], candidates: table[] }
function M.resolve(opts)
	opts = opts or {}
	local root = opts.root or util.root()
	local detected = M.detect_tools(root)
	local candidates = {}

	for _, hit in ipairs(detected) do
		local plan = plan_from_tool(hit.tool, root, hit.marker)
		if plan then
			candidates[#candidates + 1] = plan
		end
	end

	if #candidates == 0 then
		local buffer_language = languages.from_buffer()
		if buffer_language then
			local plan = plan_from_language(buffer_language, root)
			if plan then
				candidates[#candidates + 1] = plan
			end
		end
	end

	if #candidates == 0 then
		local scanned = {}
		for _, language in ipairs(languages.list) do
			local plan = plan_from_language(language, root)
			if plan then
				scanned[#scanned + 1] = plan
			end
		end

		table.sort(scanned, function(a, b)
			local depth_a = a.entry and util.depth(root, a.entry) or 999
			local depth_b = b.entry and util.depth(root, b.entry) or 999
			if depth_a ~= depth_b then
				return depth_a < depth_b
			end
			return a.label < b.label
		end)

		candidates = scanned
	end

	return {
		root = root,
		tools = detected,
		candidates = candidates,
	}
end

return M
