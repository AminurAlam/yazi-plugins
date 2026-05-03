---@diagnostic disable: undefined-global

local M = {}

-- TODO: colorized output (current only git log)
-- TODO: show all remotes
-- TODO: show all branches
-- TODO: show all stash
function M:peek(job)
	local ori = Command("git"):arg({ "remote", "get-url", "origin" }):output()
	local ups = Command("git"):arg({ "remote", "get-url", "upstream" }):output()
	local remotes = Command("git"):arg({ "remote", "-v" }):output()
	local status = Command("git"):arg({ "--no-optional-locks", "status", "-bs" }):output()

	local log = Command("git")
		:arg("-c")
		:arg("color.ui=always")
		:arg("log")
		:arg("--graph")
		:arg("--format=%C(auto)%h %s %C(magenta)(%cr)%C(auto)%d")
		:arg("-n15")
		:output()

	local text = ""
		.. (ori and ori.stdout ~= "" and ("origin: " .. ori.stdout) or "")
		.. (ups and ups.stdout ~= "" and ("upstream: " .. ups.stdout) or "")
		.. "\n"
		.. "Remotes:\n"
		.. (remotes and remotes.stdout)
		.. "\n"
		.. (status and status.stdout ~= "" and ("status: " .. status.stdout) or "")
		.. "\n"
		.. "Log:\n"
		.. (log and log.stdout)

	ya.preview_widget(job, ui.Text.parse(text):area(job.area))
end

function M:seek() end

return M
