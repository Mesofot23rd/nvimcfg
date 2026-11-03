M = {}

-- Navigate between document symbols with { and }
local symbol_cache = { tick = nil, items = {} }

--- Fetch (or reuse) the document symbols for this buffer.
---@param callback fun(items: table[]?)
local function get_symbols(callback)
	local tick = vim.b[bufnr].changedtick
	if symbol_cache.tick == tick then return callback(symbol_cache.items) end

	local client = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/documentSymbol" })[1]
	if not client then return callback(nil) end

	client:request("textDocument/documentSymbol", {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
	}, function(err, result)
		if err or not result then return callback(nil) end

		local items = vim.lsp.util.symbols_to_items(result, bufnr, client.offset_encoding)
		local bufname = vim.api.nvim_buf_get_name(bufnr)

		-- Keep this buffer's symbols, de-duplicate shared start positions and sort.
		local seen, positions = {}, {}
		for _, item in ipairs(items) do
			if item.filename == bufname then
				local position = { item.lnum, (item.col or 1) - 1 }
				local key = position[1] .. ":" .. position[2]
				if not seen[key] then
					seen[key] = true
					positions[#positions + 1] = position
				end
			end
		end
		table.sort(positions, function(a, b) return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2]) end)

		symbol_cache = { tick = tick, items = positions }
		callback(positions)
	end, bufnr)
end

--- Jump to the previous/next document symbol.
---@param forward boolean
M.goto_symbol(forward)
	local win = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(win)
	local count = math.max(vim.v.count1, 1)

	get_symbols(function(positions)
		-- The buffer may have changed while the request was in flight.
		if not positions or #positions == 0 or vim.api.nvim_get_current_buf() ~= bufnr then return end

		local target
		if forward then
			local index
			for i, position in ipairs(positions) do
				local after = position[1] > cursor[1] or (position[1] == cursor[1] and position[2] > cursor[2])
				if after then
					index = i
					break
				end
			end
			if not index then
				vim.notify("No next document symbol", vim.log.levels.INFO)
				return
			end
			target = positions[math.min(index + count - 1, #positions)]
		else
			local index
			for i = #positions, 1, -1 do
				local position = positions[i]
				local before = position[1] < cursor[1] or (position[1] == cursor[1] and position[2] < cursor[2])
				if before then
					index = i
					break
				end
			end
			if not index then
				vim.notify("No previous document symbol", vim.log.levels.INFO)
				return
			end
			target = positions[math.max(index - count + 1, 1)]
		end

		vim.cmd "normal! m'"
		vim.api.nvim_win_set_cursor(win, target)
	end)
end

return M
