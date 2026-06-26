-- gcp.nvim — minimal GCP browser for Neovim (Artifact Registry + Secret Manager)
--
-- Backed entirely by the `gcloud` CLI. Requires `gcloud` installed + authenticated.
-- For Artifact Registry vuln data, Artifact Analysis / Container Scanning must be enabled.
--
-- :Gar  → pick project → pick docker repo → image table (lazy vuln counts) → <CR> CVE detail
--   Image table keys: <CR> vulns · st/sc/sv sort (version/created/vuln) · r refresh
--                     gr repos · gp projects · y yank ref · q quit
--   Vuln detail keys: q close
--
-- :Gsm  → pick project → secret table → <CR> versions → <CR> reveal value
--   Secrets keys:  <CR> versions · a add secret · u new version · r refresh · gp projects · q quit
--   Versions keys: <CR> reveal value · u new version · b back · q quit
--   Reveal keys:   y yank value · q close  (buffer is in-memory only, no swap)

local M = {}

M.state = {
	project = nil, -- projectId string
	repo = nil,    -- { path = "loc-docker.pkg.dev/proj/repo", location = "loc", name = "repo" }
	images = {},   -- list of image entries
	sort = "version", -- version | created | vuln
}

-- How many `list-vulnerabilities` calls to run at once while populating the table lazily.
local MAX_CONCURRENCY = 5

local ns = vim.api.nvim_create_namespace("gcp")

----------------------------------------------------------------------
-- helpers
----------------------------------------------------------------------

local function has_gcloud()
	return vim.fn.executable("gcloud") == 1
end

local function notify(msg, level)
	vim.schedule(function()
		vim.notify("[gcp] " .. msg, level or vim.log.levels.INFO)
	end)
end

-- Run a gcloud command asynchronously with --format=json appended.
-- argv excludes the leading "gcloud". Callback: on_done(ok, decoded_or_nil, stderr).
local function gcloud_json(argv, on_done)
	local cmd = { "gcloud" }
	vim.list_extend(cmd, argv)
	table.insert(cmd, "--format=json")
	vim.system(cmd, { text = true }, function(res)
		if res.code ~= 0 then
			on_done(false, nil, res.stderr or "")
			return
		end
		local ok, decoded = pcall(vim.json.decode, res.stdout or "")
		if not ok then
			on_done(false, nil, "JSON parse error: " .. tostring(decoded))
			return
		end
		on_done(true, decoded, res.stderr or "")
	end)
end

-- Run a gcloud command capturing raw stdout (no --format=json). Optional stdin string
-- (used to pipe secret payloads via --data-file=-). Callback: on_done(ok, stdout, stderr).
local function gcloud_run(argv, stdin, on_done)
	local cmd = { "gcloud" }
	vim.list_extend(cmd, argv)
	local opts = { text = true }
	if stdin ~= nil then
		opts.stdin = stdin
	end
	vim.system(cmd, opts, function(res)
		on_done(res.code == 0, res.stdout or "", res.stderr or "")
	end)
end

-- Generic selector: uses Telescope if available, else falls back to vim.ui.select.
local function select_one(title, items, format_item, on_choice)
	if #items == 0 then
		notify("nothing to select for: " .. title, vim.log.levels.WARN)
		return
	end
	local ok_tel, pickers = pcall(require, "telescope.pickers")
	if ok_tel then
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")
		pickers
			.new({}, {
				prompt_title = title,
				finder = finders.new_table({
					results = items,
					entry_maker = function(it)
						local disp = format_item(it)
						return { value = it, display = disp, ordinal = disp }
					end,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local entry = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						if entry then
							on_choice(entry.value)
						end
					end)
					return true
				end,
			})
			:find()
	else
		vim.ui.select(items, { prompt = title, format_item = format_item }, function(choice)
			if choice then
				on_choice(choice)
			end
		end)
	end
end

local function normalize_tags(tags)
	if type(tags) == "table" then
		return tags
	end
	if type(tags) == "string" and tags ~= "" then
		return vim.split(tags, ",", { plain = true, trimempty = true })
	end
	return {}
end

-- Pull a {major, minor, patch} tuple out of a tag like "v1.2.3" / "release-1.2.3".
local function parse_semver(tag)
	local maj, min, pat = tostring(tag):match("v?(%d+)%.(%d+)%.(%d+)")
	if maj then
		return { tonumber(maj), tonumber(min), tonumber(pat) }
	end
	return nil
end

-- Prefer a semver-looking tag for display/sort, else the first tag.
local function best_tag(tags)
	for _, t in ipairs(tags) do
		if parse_semver(t) then
			return t
		end
	end
	return tags[1]
end

-- Sort comparator: highest version first, semver tags ahead of non-semver, then newest.
local function cmp_version_desc(a, b)
	local sa, sb = parse_semver(a._tag or ""), parse_semver(b._tag or "")
	if sa and sb then
		for i = 1, 3 do
			if sa[i] ~= sb[i] then
				return sa[i] > sb[i]
			end
		end
		return (a.createTime or "") > (b.createTime or "")
	elseif sa then
		return true
	elseif sb then
		return false
	end
	return (a.createTime or "") > (b.createTime or "")
end

-- Returns (display_text, highlight_group) for an entry's vuln state.
local function vuln_cell(entry)
	local v = entry.vuln
	if v == nil then
		return "scanning…", "Comment"
	end
	if v == false then
		return "—", "Comment"
	end
	if v.total == 0 then
		return "clean", "DiagnosticOk"
	end
	local parts = {}
	if v.critical > 0 then table.insert(parts, "C:" .. v.critical) end
	if v.high > 0 then table.insert(parts, "H:" .. v.high) end
	if v.medium > 0 then table.insert(parts, "M:" .. v.medium) end
	if v.low > 0 then table.insert(parts, "L:" .. v.low) end
	local hl = (v.critical > 0 or v.high > 0) and "DiagnosticError"
		or (v.medium > 0 and "DiagnosticWarn" or "DiagnosticHint")
	return table.concat(parts, " "), hl
end

-- Column layout: "  " + 28 + " " + 16 + " " + 22 + " " + vuln  ⇒ vuln starts at col 71.
local ROW_FMT = "  %-28s %-16s %-22s %s"
local VULN_COL = 71

----------------------------------------------------------------------
-- image table
----------------------------------------------------------------------

local function render_images()
	local buf = M.img_buf
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local entries = M.state.images
	table.sort(entries, function(a, b)
		if M.state.sort == "created" then
			return (a.createTime or "") > (b.createTime or "")
		elseif M.state.sort == "vuln" then
			local function score(e)
				local v = e.vuln
				if type(v) ~= "table" then
					return -1
				end
				return v.critical * 1e6 + v.high * 1e4 + v.medium * 1e2 + v.low
			end
			return score(a) > score(b)
		end
		return cmp_version_desc(a, b)
	end)

	local lines = {
		"  GCP Artifact Registry — " .. (M.state.repo and M.state.repo.path or ""),
		"  sort:" .. M.state.sort .. "   <CR> vulns · st/sc/sv sort · r refresh · gr repos · gp projects · y yank · q quit",
		"",
		string.format(ROW_FMT, "IMAGE:TAG", "DIGEST", "CREATED", "VULNERABILITIES"),
		"  " .. string.rep("─", 86),
	}
	M.img_rowmap = {}
	local hl_lines = {}
	for _, e in ipairs(entries) do
		local vtext, vhl = vuln_cell(e)
		local imgtag = (e._img or "?") .. ":" .. (e._tag or "<untagged>")
		local created = (e.createTime or ""):sub(1, 19):gsub("T", " ")
		local line = string.format(ROW_FMT, imgtag:sub(1, 28), (e._digest or ""):sub(1, 16), created, vtext)
		table.insert(lines, line)
		M.img_rowmap[#lines] = e
		hl_lines[#lines] = { hl = vhl, len = #line }
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for ln, info in pairs(hl_lines) do
		vim.api.nvim_buf_set_extmark(buf, ns, ln - 1, VULN_COL, {
			end_row = ln - 1,
			end_col = math.max(VULN_COL, info.len),
			hl_group = info.hl,
		})
	end
end

-- Populate vuln counts lazily after the table is shown, throttled to MAX_CONCURRENCY.
local function start_vuln_scan()
	local queue = {}
	for _, e in ipairs(M.state.images) do
		if e.vuln == nil then
			table.insert(queue, e)
		end
	end
	local active, idx = 0, 1
	local function pump()
		while active < MAX_CONCURRENCY and idx <= #queue do
			local e = queue[idx]
			idx = idx + 1
			active = active + 1
			gcloud_json(
				{ "artifacts", "docker", "images", "list-vulnerabilities", e.ref, "--project=" .. M.state.project },
				function(ok, data)
					if ok and type(data) == "table" then
						local c = { critical = 0, high = 0, medium = 0, low = 0, total = 0, occ = data }
						for _, occ in ipairs(data) do
							local v = occ.vulnerability or {}
							local sev = tostring(v.effectiveSeverity or v.severity or "UNKNOWN"):upper()
							if sev == "CRITICAL" then c.critical = c.critical + 1
							elseif sev == "HIGH" then c.high = c.high + 1
							elseif sev == "MEDIUM" then c.medium = c.medium + 1
							elseif sev == "LOW" then c.low = c.low + 1 end
							c.total = c.total + 1
						end
						e.vuln = c
					else
						e.vuln = false -- no scan data / not enabled / error
					end
					active = active - 1
					vim.schedule(function()
						render_images()
						pump()
					end)
				end
			)
		end
	end
	pump()
end

function M.open_images()
	if not M.state.repo then
		return M.pick_repo()
	end
	local buf = vim.api.nvim_create_buf(false, true)
	M.img_buf = buf
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "gar-images"
	pcall(vim.api.nvim_buf_set_name, buf, "gar://" .. M.state.repo.path)
	vim.api.nvim_set_current_buf(buf)

	local function map(lhs, fn, desc)
		vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true, desc = desc })
	end
	map("<CR>", function() M.show_vulns_under_cursor() end, "Show vulnerabilities")
	map("st", function() M.state.sort = "version"; render_images() end, "Sort by version")
	map("sc", function() M.state.sort = "created"; render_images() end, "Sort by created")
	map("sv", function() M.state.sort = "vuln"; render_images() end, "Sort by vulnerability")
	map("r", function() M.open_images() end, "Refresh")
	map("gr", function() M.pick_repo() end, "Back to repos")
	map("gp", function() M.pick_project() end, "Back to projects")
	map("y", function() M.yank_under_cursor() end, "Yank image ref")
	map("q", function() vim.api.nvim_buf_delete(buf, { force = true }) end, "Close")

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  loading images for " .. M.state.repo.path .. " …" })
	vim.bo[buf].modifiable = false

	notify("loading images…")
	gcloud_json(
		{ "artifacts", "docker", "images", "list", M.state.repo.path, "--include-tags", "--project=" .. M.state.project },
		function(ok, data, err)
			if not ok then
				notify("images list failed: " .. err, vim.log.levels.ERROR)
				return
			end
			local entries = {}
			for _, im in ipairs(data or {}) do
				local tags = normalize_tags(im.tags)
				table.insert(entries, {
					package = im.package,
					version = im.version, -- sha256:...
					ref = (im.package or "") .. "@" .. (im.version or ""),
					createTime = im.createTime,
					tags = tags,
					_img = (im.package or ""):match("/([^/]+)$") or im.package,
					_tag = best_tag(tags),
					_digest = (im.version or ""):gsub("^sha256:", ""),
					vuln = nil,
				})
			end
			M.state.images = entries
			vim.schedule(function()
				render_images()
				start_vuln_scan()
			end)
		end
	)
end

----------------------------------------------------------------------
-- vuln detail
----------------------------------------------------------------------

local SEV_ORDER = { CRITICAL = 1, HIGH = 2, MEDIUM = 3, LOW = 4, MINIMAL = 5, UNKNOWN = 6 }
local DETAIL_FMT = "  %-9s %-20s %-22s %-18s %-18s %s"

function M.render_vuln_detail(entry, occurrences)
	local rows = {}
	for _, occ in ipairs(occurrences) do
		local v = occ.vulnerability or {}
		local pi = (v.packageIssue or {})[1] or {}
		local fixed = pi.fixedVersion and (pi.fixedVersion.fullName or (pi.fixedVersion.kind == "MAXIMUM" and "—")) or ""
		table.insert(rows, {
			sev = tostring(v.effectiveSeverity or v.severity or "UNKNOWN"):upper(),
			cve = (occ.noteName or ""):match("/notes/(.+)$") or (v.shortDescription or "?"),
			pkg = pi.affectedPackage or "",
			affected = (pi.affectedVersion and pi.affectedVersion.fullName) or "",
			fixed = (fixed ~= "" and fixed) or "—",
			cvss = v.cvssScore,
		})
	end
	table.sort(rows, function(a, b)
		local sa, sb = SEV_ORDER[a.sev] or 9, SEV_ORDER[b.sev] or 9
		if sa ~= sb then
			return sa < sb
		end
		return (a.cve or "") < (b.cve or "")
	end)

	local lines = {
		"  Vulnerabilities — " .. (entry._img or "") .. ":" .. (entry._tag or ""),
		"  " .. (entry.ref or ""),
		"  q close · sorted by severity · total: " .. #rows,
		"  " .. string.rep("─", 96),
		string.format(DETAIL_FMT, "SEVERITY", "CVE", "PACKAGE", "AFFECTED", "FIXED", "CVSS"),
	}
	local hl_lines = {}
	for _, r in ipairs(rows) do
		local line = string.format(
			DETAIL_FMT,
			r.sev,
			r.cve:sub(1, 20),
			r.pkg:sub(1, 22),
			r.affected:sub(1, 18),
			r.fixed:sub(1, 18),
			r.cvss and string.format("%.1f", r.cvss) or ""
		)
		table.insert(lines, line)
		hl_lines[#lines] = (r.sev == "CRITICAL" or r.sev == "HIGH") and "DiagnosticError"
			or (r.sev == "MEDIUM" and "DiagnosticWarn" or "DiagnosticHint")
	end
	if #rows == 0 then
		table.insert(lines, "  (no vulnerabilities found — image may be unscanned or clean)")
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "gar-vulns"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_set_current_buf(buf)
	vim.keymap.set("n", "q", function()
		vim.api.nvim_buf_delete(buf, { force = true })
	end, { buffer = buf, nowait = true, silent = true })
	for ln, hl in pairs(hl_lines) do
		vim.api.nvim_buf_set_extmark(buf, ns, ln - 1, 2, { end_row = ln - 1, end_col = 11, hl_group = hl })
	end
end

function M.entry_under_cursor()
	local ln = vim.api.nvim_win_get_cursor(0)[1]
	return M.img_rowmap and M.img_rowmap[ln]
end

function M.yank_under_cursor()
	local e = M.entry_under_cursor()
	if not e then
		return
	end
	vim.fn.setreg("+", e.ref)
	notify("yanked: " .. e.ref)
end

function M.show_vulns_under_cursor()
	local e = M.entry_under_cursor()
	if not e then
		notify("no image on this line", vim.log.levels.WARN)
		return
	end
	if type(e.vuln) == "table" and e.vuln.occ then
		M.render_vuln_detail(e, e.vuln.occ) -- use cached scan result
		return
	end
	notify("fetching vulnerabilities…")
	gcloud_json(
		{ "artifacts", "docker", "images", "list-vulnerabilities", e.ref, "--project=" .. M.state.project },
		function(ok, data)
			vim.schedule(function()
				if ok and type(data) == "table" then
					M.render_vuln_detail(e, data)
				else
					notify("no vulnerability data for this image", vim.log.levels.WARN)
				end
			end)
		end
	)
end

----------------------------------------------------------------------
-- pickers / entry points
----------------------------------------------------------------------

function M.pick_repo()
	if not M.state.project then
		return M.pick_project()
	end
	notify("loading repositories…")
	gcloud_json({ "artifacts", "repositories", "list", "--project=" .. M.state.project }, function(ok, data, err)
		if not ok then
			notify("repositories list failed: " .. err, vim.log.levels.ERROR)
			return
		end
		local repos = {}
		for _, r in ipairs(data or {}) do
			if tostring(r.format or ""):upper() == "DOCKER" then
				local loc = r.name:match("/locations/([^/]+)/")
				local name = r.name:match("/repositories/([^/]+)$")
				if loc and name then
					table.insert(repos, {
						location = loc,
						name = name,
						path = string.format("%s-docker.pkg.dev/%s/%s", loc, M.state.project, name),
					})
				end
			end
		end
		vim.schedule(function()
			select_one("Docker Repos (" .. M.state.project .. ")", repos, function(r)
				return string.format("%s   [%s]", r.name, r.location)
			end, function(r)
				M.state.repo = r
				M.open_images()
			end)
		end)
	end)
end

-- next_fn runs after a project is chosen (defaults to the registry repo picker).
function M.pick_project(next_fn)
	next_fn = next_fn or M.pick_repo
	if not has_gcloud() then
		notify("gcloud not found on PATH", vim.log.levels.ERROR)
		return
	end
	notify("loading projects…")
	gcloud_json({ "projects", "list" }, function(ok, data, err)
		if not ok then
			notify("projects list failed: " .. err, vim.log.levels.ERROR)
			return
		end
		vim.schedule(function()
			select_one("GCP Projects", data, function(p)
				return string.format("%s  (%s)", p.projectId, p.name or "")
			end, function(p)
				M.state.project = p.projectId
				notify("project: " .. p.projectId)
				next_fn()
			end)
		end)
	end)
end

----------------------------------------------------------------------
-- Secret Manager (GSM)
----------------------------------------------------------------------

local SEC_FMT = "  %-32s %-22s %s"
local VER_FMT = "  %-10s %-12s %s"

-- A scratch buffer to type a (possibly multi-line) secret value, then submit with <C-s> / :w.
local function compose_value(title, on_submit)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"# " .. title,
		"# Type the secret value below. Lines starting with # are ignored.",
		"# Submit: <C-s> or :w   ·   Cancel: q",
		"",
		"",
	})
	vim.api.nvim_set_current_buf(buf)
	vim.cmd("normal! G")
	local submitted = false
	local function submit()
		if submitted then
			return
		end
		submitted = true
		local body = {}
		for _, l in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
			if not l:match("^#") then
				table.insert(body, l)
			end
		end
		local value = table.concat(body, "\n"):gsub("^\n+", ""):gsub("\n+$", "")
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
		if value == "" then
			notify("empty value — aborted", vim.log.levels.WARN)
			return
		end
		on_submit(value)
	end
	vim.keymap.set("n", "<C-s>", submit, { buffer = buf, nowait = true })
	vim.keymap.set("i", "<C-s>", function()
		vim.cmd("stopinsert")
		submit()
	end, { buffer = buf })
	vim.keymap.set("n", "q", function()
		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end, { buffer = buf, nowait = true })
	vim.api.nvim_create_autocmd("BufWriteCmd", { buffer = buf, callback = submit })
end

local function gsm_render_secrets()
	local buf = M.sec_buf
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local lines = {
		"  GCP Secret Manager — project: " .. (M.state.project or "?"),
		"  <CR> versions · a add secret · u new version · r refresh · gp projects · q quit",
		"",
		string.format(SEC_FMT, "NAME", "CREATED", "LABELS"),
		"  " .. string.rep("─", 80),
	}
	M.sec_rowmap = {}
	for _, s in ipairs(M.state.secrets or {}) do
		local labels = {}
		for k, v in pairs(s.labels or {}) do
			table.insert(labels, k .. "=" .. v)
		end
		local created = (s.createTime or ""):sub(1, 19):gsub("T", " ")
		table.insert(lines, string.format(SEC_FMT, (s._name or ""):sub(1, 32), created, table.concat(labels, ",")))
		M.sec_rowmap[#lines] = s
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
end

-- Access and display one secret version's payload in an ephemeral buffer.
function M.gsm_reveal(secret, version)
	notify("accessing " .. secret._name .. " v" .. version .. "…")
	gcloud_run(
		{ "secrets", "versions", "access", version, "--secret=" .. secret._name, "--project=" .. M.state.project },
		nil,
		function(ok, out, err)
			vim.schedule(function()
				if not ok then
					notify("access failed: " .. err, vim.log.levels.ERROR)
					return
				end
				local buf = vim.api.nvim_create_buf(false, true)
				vim.bo[buf].buftype = "nofile"
				vim.bo[buf].bufhidden = "wipe"
				vim.bo[buf].swapfile = false
				local lines = {
					"  ⚠ SECRET VALUE — " .. secret._name .. " (version " .. version .. ")",
					"  y yank value · q close · in-memory only, not written to disk",
					"  " .. string.rep("─", 70),
					"",
				}
				vim.list_extend(lines, vim.split(out, "\n", { plain = true }))
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
				vim.bo[buf].modifiable = false
				vim.api.nvim_set_current_buf(buf)
				vim.keymap.set("n", "q", function()
					vim.api.nvim_buf_delete(buf, { force = true })
				end, { buffer = buf, nowait = true })
				vim.keymap.set("n", "y", function()
					vim.fn.setreg("+", out)
					notify("secret value yanked to clipboard")
				end, { buffer = buf, nowait = true })
			end)
		end
	)
end

-- Add a new version (i.e. update the value) of an existing secret.
function M.gsm_add_version(secret)
	compose_value("New version for secret '" .. secret._name .. "'", function(value)
		notify("adding version to " .. secret._name .. "…")
		gcloud_run(
			{ "secrets", "versions", "add", secret._name, "--data-file=-", "--project=" .. M.state.project },
			value,
			function(ok, _, err)
				if ok then
					notify("added new version to " .. secret._name)
				else
					notify("add version failed: " .. err, vim.log.levels.ERROR)
				end
			end
		)
	end)
end

-- Create a brand new secret with an initial value.
function M.gsm_add_secret()
	vim.ui.input({ prompt = "New secret name: " }, function(name)
		if not name or name == "" then
			return
		end
		compose_value("Initial value for new secret '" .. name .. "'", function(value)
			notify("creating secret " .. name .. "…")
			gcloud_run({
				"secrets",
				"create",
				name,
				"--replication-policy=automatic",
				"--data-file=-",
				"--project=" .. M.state.project,
			}, value, function(ok, _, err)
				if ok then
					notify("created secret " .. name)
					vim.schedule(M.gsm_open_secrets)
				else
					notify("create failed: " .. err, vim.log.levels.ERROR)
				end
			end)
		end)
	end)
end

function M.gsm_open_versions(secret)
	notify("loading versions…")
	gcloud_json({ "secrets", "versions", "list", secret._name, "--project=" .. M.state.project }, function(ok, data, err)
		if not ok then
			notify("versions list failed: " .. err, vim.log.levels.ERROR)
			return
		end
		vim.schedule(function()
			local buf = vim.api.nvim_create_buf(false, true)
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].filetype = "gsm-versions"
			local lines = {
				"  Secret versions — " .. secret._name,
				"  <CR> reveal value · u new version · b back · q quit",
				"",
				string.format(VER_FMT, "VERSION", "STATE", "CREATED"),
				"  " .. string.rep("─", 60),
			}
			local rowmap = {}
			for _, v in ipairs(data or {}) do
				local num = (v.name or ""):match("/versions/([^/]+)$") or "?"
				local created = (v.createTime or ""):sub(1, 19):gsub("T", " ")
				table.insert(lines, string.format(VER_FMT, num, v.state or "", created))
				rowmap[#lines] = num
			end
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].modifiable = false
			vim.api.nvim_set_current_buf(buf)
			local function under()
				return rowmap[vim.api.nvim_win_get_cursor(0)[1]]
			end
			vim.keymap.set("n", "<CR>", function()
				local n = under()
				if n then
					M.gsm_reveal(secret, n)
				end
			end, { buffer = buf, nowait = true })
			vim.keymap.set("n", "u", function()
				M.gsm_add_version(secret)
			end, { buffer = buf, nowait = true })
			vim.keymap.set("n", "b", function()
				M.gsm_open_secrets()
			end, { buffer = buf, nowait = true })
			vim.keymap.set("n", "q", function()
				vim.api.nvim_buf_delete(buf, { force = true })
			end, { buffer = buf, nowait = true })
		end)
	end)
end

function M.gsm_open_secrets()
	if not M.state.project then
		return M.pick_project(M.gsm_open_secrets)
	end
	notify("loading secrets…")
	gcloud_json({ "secrets", "list", "--project=" .. M.state.project }, function(ok, data, err)
		if not ok then
			notify("secrets list failed: " .. err, vim.log.levels.ERROR)
			return
		end
		local secrets = {}
		for _, s in ipairs(data or {}) do
			table.insert(secrets, {
				name = s.name,
				_name = (s.name or ""):match("/secrets/([^/]+)$") or s.name,
				createTime = s.createTime,
				labels = s.labels,
			})
		end
		M.state.secrets = secrets
		vim.schedule(function()
			local buf = M.sec_buf
			if not buf or not vim.api.nvim_buf_is_valid(buf) then
				buf = vim.api.nvim_create_buf(false, true)
				M.sec_buf = buf
				vim.bo[buf].buftype = "nofile"
				vim.bo[buf].bufhidden = "wipe"
				vim.bo[buf].filetype = "gsm-secrets"
				local function under()
					return M.sec_rowmap and M.sec_rowmap[vim.api.nvim_win_get_cursor(0)[1]]
				end
				vim.keymap.set("n", "<CR>", function()
					local s = under()
					if s then
						M.gsm_open_versions(s)
					end
				end, { buffer = buf, nowait = true })
				vim.keymap.set("n", "a", function()
					M.gsm_add_secret()
				end, { buffer = buf, nowait = true })
				vim.keymap.set("n", "u", function()
					local s = under()
					if s then
						M.gsm_add_version(s)
					end
				end, { buffer = buf, nowait = true })
				vim.keymap.set("n", "r", function()
					M.gsm_open_secrets()
				end, { buffer = buf, nowait = true })
				vim.keymap.set("n", "gp", function()
					M.pick_project(M.gsm_open_secrets)
				end, { buffer = buf, nowait = true })
				vim.keymap.set("n", "q", function()
					vim.api.nvim_buf_delete(buf, { force = true })
				end, { buffer = buf, nowait = true })
			end
			vim.api.nvim_set_current_buf(buf)
			gsm_render_secrets()
		end)
	end)
end

----------------------------------------------------------------------
-- entry points
----------------------------------------------------------------------

function M.setup()
	vim.api.nvim_create_user_command("Gar", function()
		M.pick_project(M.pick_repo)
	end, { desc = "Browse GCP Artifact Registry (project → repo → images → vulns)" })
	vim.api.nvim_create_user_command("Gsm", function()
		M.pick_project(M.gsm_open_secrets)
	end, { desc = "Browse GCP Secret Manager (project → secrets → versions → value)" })
	vim.api.nvim_create_user_command("GarRepos", function()
		M.pick_repo()
	end, { desc = "GAR: pick a repo in the current project" })
end

return M
