-- tscompat: bridge nvim-treesitter's query handlers to the Neovim 0.12 API.
--
-- Neovim <= 0.11 let a predicate/directive opt out of multi-node captures with
-- `all = false`, and its handler then received `match[id]` as a single TSNode.
-- Neovim 0.12 removed that option: `vim.treesitter.query.add_predicate.Opts`
-- now carries only `force`, and handlers always receive
-- `table<integer, TSNode[]>` -- a *list* of nodes per capture.
--
-- nvim-treesitter (master, pinned) still passes `all = false` and still does
-- `local node = match[id]`, so on 0.12 it hands a Lua table to
-- `vim.treesitter.get_node_text`, which calls `node:range()` and throws:
--
--   treesitter.lua:197: attempt to call method 'range' (a nil value)
--
-- This fires on any markdown buffer with a fenced code block, via the
-- `set-lang-from-info-string!` injection directive. Reported entry points
-- include the treesitter highlighter, render-markdown, and treesitter-context.
--
-- The fix wraps `add_predicate`/`add_directive` so that any handler which
-- explicitly asked for `all = false` gets its match table collapsed back to
-- one node per capture. Handlers written against the new API leave `all`
-- unset and pass through completely untouched.
--
-- Remove this once nvim-treesitter is updated to a 0.12-compatible revision.

local M = {}

--- Collapse `{[id] = {TSNode, ...}}` to `{[id] = TSNode}`.
--- TSNodes are userdata, so a table value is unambiguously the new list form.
local function collapse(match)
	local out = {}
	for id, value in pairs(match) do
		if type(value) == "table" then
			out[id] = value[1]
		else
			out[id] = value
		end
	end
	return out
end

local function wrap(register)
	return function(name, handler, opts)
		if type(opts) == "table" and opts.all == false and type(handler) == "function" then
			local inner = handler
			handler = function(match, ...)
				return inner(collapse(match), ...)
			end
		end
		return register(name, handler, opts)
	end
end

--- Install the shim. Must run before nvim-treesitter registers its handlers,
--- i.e. before `nvim-treesitter.query_predicates` is first required.
function M.setup()
	-- 0.12 is where `all` disappeared; on older versions the native behaviour
	-- is still correct and wrapping would double-collapse.
	if vim.fn.has("nvim-0.12") ~= 1 then
		return
	end

	local query = vim.treesitter.query
	if query._tscompat_patched then
		return
	end
	query._tscompat_patched = true

	query.add_predicate = wrap(query.add_predicate)
	query.add_directive = wrap(query.add_directive)
end

M._internal = { collapse = collapse }

return M
