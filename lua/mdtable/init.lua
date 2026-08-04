-- mdtable: render markdown tables with cell content wrapped *inside* its column.
--
-- Neovim's 'wrap' has no concept of a table cell: a table row is one logical
-- line, so an overflowing row continues at screen column 0 and the alignment
-- collapses. This module leaves the buffer text untouched (it stays valid GFM)
-- and instead draws the table as virtual lines:
--
--   conceal_lines = ''  hides the real, too-long source line
--   virt_lines          draws the wrapped replacement in its place
--
-- Requires Neovim >= 0.11 for `conceal_lines`.

local M = {}

local ns = vim.api.nvim_create_namespace("mdtable")

---@class mdtable.Config
local config = {
	enabled = true,
	-- Minimum content width a column may be shrunk to before other columns
	-- have to give up space instead.
	min_width = 6,
	-- Spaces between the cell border and the cell content, per side.
	padding = 1,
	-- What to un-render while the cursor is inside a table, so it stays
	-- editable: "table" (whole table), "line" (just that row), "none".
	reveal = "table",
	-- Skip buffers larger than this; the whole buffer is scanned per redraw.
	max_lines = 10000,
	border = {
		tl = "┌", tm = "┬", tr = "┐",
		ml = "├", mm = "┼", mr = "┤",
		bl = "└", bm = "┴", br = "┘",
		h = "─", v = "│",
	},
	-- Reused from render-markdown so the colours match the rest of the theme.
	-- Unknown groups render as Normal rather than erroring.
	hl = {
		border = "RenderMarkdownTableHead",
		head = "RenderMarkdownTableHead",
		row = "RenderMarkdownTableRow",
	},
}

M.config = config

local function dw(s)
	return vim.fn.strdisplaywidth(s)
end

--- Split a markdown table row into trimmed cells, honouring `\|` escapes.
---@return string[]|nil
local function split_row(line)
	local s = line:match("^%s*(.-)%s*$")
	if not s:match("^|") then
		return nil
	end
	s = s:sub(2)
	-- Strip the trailing pipe, but not an escaped one.
	if s:sub(-1) == "|" and s:sub(-2, -2) ~= "\\" then
		s = s:sub(1, -2)
	end

	local cells, buf, i = {}, {}, 1
	while i <= #s do
		local c = s:sub(i, i)
		if c == "\\" and s:sub(i + 1, i + 1) == "|" then
			buf[#buf + 1] = "|"
			i = i + 2
		elseif c == "|" then
			cells[#cells + 1] = table.concat(buf)
			buf = {}
			i = i + 1
		else
			buf[#buf + 1] = c
			i = i + 1
		end
	end
	cells[#cells + 1] = table.concat(buf)

	for k, v in ipairs(cells) do
		cells[k] = v:match("^%s*(.-)%s*$")
	end
	return cells
end

--- Is this the `|---|:--:|` row that makes a pipe table a table?
local function is_delim(cells)
	if not cells or #cells == 0 then
		return false
	end
	for _, c in ipairs(cells) do
		if not c:match("^:?%-+:?$") then
			return false
		end
	end
	return true
end

local function align_of(delim_cell)
	local left = delim_cell:sub(1, 1) == ":"
	local right = delim_cell:sub(-1) == ":"
	if left and right then
		return "center"
	elseif right then
		return "right"
	end
	return "left"
end

--- Greedy word wrap. Words longer than `width` are hard-split so a single
--- long token (a URL, a path) can never blow the column back open.
---@return string[]
local function wrap_text(text, width)
	if width < 1 then
		width = 1
	end
	if text == "" then
		return { "" }
	end

	local lines, cur = {}, ""
	for word in text:gmatch("%S+") do
		local cand = cur == "" and word or (cur .. " " .. word)
		if dw(cand) <= width then
			cur = cand
		else
			if cur ~= "" then
				lines[#lines + 1] = cur
				cur = ""
			end
			while dw(word) > width do
				local take = ""
				-- Iterate UTF-8 codepoints so we never split a multibyte char.
				for ch in word:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
					if dw(take .. ch) > width then
						break
					end
					take = take .. ch
				end
				if take == "" then
					break
				end
				lines[#lines + 1] = take
				word = word:sub(#take + 1)
			end
			cur = word
		end
	end
	if cur ~= "" then
		lines[#lines + 1] = cur
	end
	if #lines == 0 then
		lines = { "" }
	end
	return lines
end

--- Fit columns into `budget` total content width.
--- Water-fills: every column keeps its natural width until a shared cap has to
--- bite, so narrow columns are never squeezed to make room for a wide one.
---@return integer[]
local function layout(natural, budget, min_w)
	local widths, total = {}, 0
	for i, v in ipairs(natural) do
		widths[i] = v
		total = total + v
	end
	if total <= budget then
		return widths
	end

	local floor_w = math.max(1, math.min(min_w, math.floor(budget / math.max(1, #natural))))
	local lo, hi, best = floor_w, math.max(floor_w, budget), floor_w
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		local s = 0
		for _, v in ipairs(natural) do
			s = s + math.min(v, mid)
		end
		if s <= budget then
			best = mid
			lo = mid + 1
		else
			hi = mid - 1
		end
	end

	total = 0
	for i, v in ipairs(natural) do
		-- The floor only applies to columns actually being clipped; a column
		-- whose natural width is already below it stays at its natural width.
		widths[i] = math.min(v, math.max(floor_w, best))
		total = total + widths[i]
	end

	-- Hand any rounding slack back to the columns that are still clipped.
	local left = budget - total
	while left > 0 do
		local progressed = false
		for k = 1, #widths do
			if left > 0 and widths[k] < natural[k] then
				widths[k] = widths[k] + 1
				left = left - 1
				progressed = true
			end
		end
		if not progressed then
			break
		end
	end
	return widths
end

local function pad_cell(text, width, align)
	local space = width - dw(text)
	if space < 0 then
		space = 0
	end
	if align == "right" then
		return string.rep(" ", space) .. text
	elseif align == "center" then
		local l = math.floor(space / 2)
		return string.rep(" ", l) .. text .. string.rep(" ", space - l)
	end
	return text .. string.rep(" ", space)
end

---@return table[] chunks for a single virtual line
local function border_line(widths, l, m, r)
	local B, pad = config.border, config.padding
	local parts = { l }
	for c = 1, #widths do
		parts[#parts + 1] = string.rep(B.h, widths[c] + pad * 2)
		parts[#parts + 1] = (c == #widths) and r or m
	end
	return { { table.concat(parts), config.hl.border } }
end

---@return table[] chunks for one display row of a (possibly wrapped) table row
local function content_line(cell_lines, k, widths, aligns, hl)
	local B, pad = config.border, config.padding
	local sp = string.rep(" ", pad)
	local chunks = { { B.v, config.hl.border } }
	for c = 1, #widths do
		local txt = (cell_lines[c] or {})[k] or ""
		chunks[#chunks + 1] = { sp .. pad_cell(txt, widths[c], aligns[c]) .. sp, hl }
		chunks[#chunks + 1] = { B.v, config.hl.border }
	end
	return chunks
end

--- Locate every pipe table in `lines`. Returns 1-indexed inclusive ranges.
local function find_tables(lines)
	local out, i = {}, 1
	while i <= #lines do
		if lines[i]:match("^%s*|") then
			local start = i
			local j = i
			while j <= #lines and lines[j]:match("^%s*|") do
				j = j + 1
			end
			local stop = j - 1
			if stop - start >= 1 and is_delim(split_row(lines[start + 1])) then
				out[#out + 1] = { start = start, stop = stop }
			end
			i = j
		else
			i = i + 1
		end
	end
	return out
end

local function render_table(buf, tbl, lines, avail, cursor)
	local raw = {}
	for r = tbl.start, tbl.stop do
		raw[#raw + 1] = split_row(lines[r]) or {}
	end
	if #raw < 2 then
		return
	end

	local ncols = #raw[1]
	if ncols == 0 then
		return
	end

	local aligns = {}
	for c = 1, ncols do
		aligns[c] = align_of(raw[2][c] or "")
	end

	-- Normalise every row to exactly ncols cells.
	for _, cells in ipairs(raw) do
		for c = 1, ncols do
			cells[c] = cells[c] or ""
		end
		for c = #cells, ncols + 1, -1 do
			cells[c] = nil
		end
	end

	local natural = {}
	for c = 1, ncols do
		local w = 0
		for idx, cells in ipairs(raw) do
			if idx ~= 2 then -- the delimiter row carries no content
				w = math.max(w, dw(cells[c]))
			end
		end
		natural[c] = math.max(1, w)
	end

	-- avail = │ + per column (pad + content + pad + │)
	local overhead = 1 + ncols * (config.padding * 2 + 1)
	local widths = layout(natural, math.max(ncols, avail - overhead), config.min_width)

	-- The whole table, as finished virtual lines.
	local display = { border_line(widths, config.border.tl, config.border.tm, config.border.tr) }
	for idx = 1, #raw do
		if idx == 2 then
			display[#display + 1] = border_line(widths, config.border.ml, config.border.mm, config.border.mr)
		else
			local hl = idx == 1 and config.hl.head or config.hl.row
			local cell_lines, height = {}, 1
			for c = 1, ncols do
				cell_lines[c] = wrap_text(raw[idx][c], widths[c])
				height = math.max(height, #cell_lines[c])
			end
			for k = 1, height do
				display[#display + 1] = content_line(cell_lines, k, widths, aligns, hl)
			end
		end
	end
	display[#display + 1] = border_line(widths, config.border.bl, config.border.bm, config.border.br)

	-- Hiding the source needs `conceal_lines`: character-level conceal leaves
	-- the line's *wrapped height* intact, which under 'wrap' shows up as blank
	-- rows between the table rows. But `conceal_lines` also suppresses that
	-- line's own virt_lines, so the drawing has to hang off a line that stays
	-- visible -- the one before the table, or the one after it.
	local anchor, above
	local is_row = function(n)
		return lines[n] ~= nil and lines[n]:match("^%s*|") ~= nil
	end
	if tbl.start > 1 and not is_row(tbl.start - 1) then
		anchor, above = tbl.start - 2, false
	elseif tbl.stop < #lines and not is_row(tbl.stop + 1) then
		anchor, above = tbl.stop, true
	end

	if not anchor then
		-- Table fills the buffer with no neighbouring line to hang it on.
		-- Leave the source visible rather than blanking it out.
		return
	end

	for r = tbl.start, tbl.stop do
		vim.api.nvim_buf_set_extmark(buf, ns, r - 1, 0, { conceal_lines = "" })
	end
	vim.api.nvim_buf_set_extmark(buf, ns, anchor, 0, {
		virt_lines = display,
		virt_lines_above = above,
	})
end

function M.render(buf)
	-- Normalise 0 ("current buffer" to the API) to a real bufnr, so the
	-- window/buffer identity check below compares like with like.
	if buf == nil or buf == 0 then
		buf = vim.api.nvim_get_current_buf()
	end
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	if not config.enabled or vim.bo[buf].filetype ~= "markdown" then
		return
	end
	-- Match render-markdown's render_modes: normal and command only, so the
	-- raw source is always what you edit.
	if not vim.api.nvim_get_mode().mode:match("^[nc]") then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	if #lines > config.max_lines then
		return
	end

	local win = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_get_buf(win) ~= buf then
		return
	end
	local info = vim.fn.getwininfo(win)[1]
	local avail = vim.api.nvim_win_get_width(win) - ((info and info.textoff) or 0)
	local cursor = vim.api.nvim_win_get_cursor(win)[1]

	for _, tbl in ipairs(find_tables(lines)) do
		local inside = cursor >= tbl.start and cursor <= tbl.stop
		if not (inside and config.reveal == "table") then
			render_table(buf, tbl, lines, avail, cursor)
		end
	end
end

function M.toggle()
	config.enabled = not config.enabled
	M.render()
	vim.notify("mdtable " .. (config.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	M.config = config

	local group = vim.api.nvim_create_augroup("mdtable", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = "markdown",
		callback = function(ev)
			-- conceal_lines only takes effect at conceallevel >= 2.
			vim.wo.conceallevel = math.max(vim.wo.conceallevel, 2)
			vim.schedule(function()
				M.render(ev.buf)
			end)
		end,
	})

	vim.api.nvim_create_autocmd(
		{ "BufEnter", "TextChanged", "InsertLeave", "CursorMoved", "WinScrolled", "VimResized", "WinResized" },
		{
			group = group,
			callback = function(ev)
				if vim.bo[ev.buf].filetype == "markdown" then
					M.render(ev.buf)
				end
			end,
		}
	)

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = group,
		callback = function(ev)
			if vim.bo[ev.buf].filetype == "markdown" then
				vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
			end
		end,
	})

	vim.api.nvim_create_user_command("MDTableToggle", M.toggle, { desc = "Toggle wrapped markdown tables" })
end

-- Exposed for tests.
M._internal = {
	split_row = split_row,
	is_delim = is_delim,
	wrap_text = wrap_text,
	layout = layout,
	find_tables = find_tables,
}

return M
