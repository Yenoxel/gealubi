-- Filename: saved.lua
-- Version: 0.4.0-beta
-- Update Date: 14.02.2025 14:22:28
-- ## Works only if geanylua plugins is installed into your Geany IDE
-- ## Place this file onto:
-- 	## For UNIX: $HOME/.config/geany/plugins/geanylua/events/
-- 	## For MS-Windows: C:\users\username\AppData\Roaming\geany\plugins\geanylua\events\
-- 	## For macOS: ? Need testers. Please contribute to Issues or Pull Request.
-- Author: Yeleaf (Yenoxel).
-- Link 1: https://codeberg.org/Yeleaf/gealubi/src/branch/main/saved.lua
-- Link 2: https://github.com/Yenoxel/gealubi/blob/main/saved.lua
-- Licence: GPL-2.0
local app_info = geany.appinfo()
local script_dir = app_info.scriptdir -- Get scripts directory location for geanylua plugin.
--geany.message(script_dir) -- Uncomment this to get Geany Dialog window with path to the scriptdir.
local dirsep = geany.dirsep -- Get directory separator. '/' - for unix and '\' for microsoft windows.
local support_dir = "support" -- Place where gealubi.lua script must be.
local script_name = "gealubi.lua"
local path_to_script = script_dir .. dirsep .. support_dir .. dirsep .. script_name
if not geany.fullpath(path_to_script) then -- If gealubi not in correct path:
	geany.message("[ERROR]: gealubi.lua was not found at: " .. path_to_script)
else
	local gealubi = dofile(path_to_script) -- Load gealubi script

	-- (IMPORTANT!) Put your path to luacheck.exe Path must be in "quotes". Important for MS-Windows only:
	-- Download link (x64bit): https://github.com/lunarmodules/luacheck/releases/download/v1.2.0/luacheck.exe
	-- Download link (x32bit): https://github.com/lunarmodules/luacheck/releases/download/v1.2.0/luacheck32.exe
	gealubi.windows_luacheck_path = [["C:\Program Files\Lua\luacheck.exe"]] -- Preserve quotes "" if path contains spaces.

	-- (Optional for Linux, but IMPORTANT for MacOS)
	-- Put your path to luacheck app. This variable have higher priority. If path incorrect, script will try to find -
	-- - luacheck app in default linux OS directory (/home/username/.luarocks/bin/luacheck) If luacheck was ins-
	-- -talled localy. Like this: $ luarocks --local install luacheck
	-- Download link: https://github.com/lunarmodules/luacheck/releases/download/v1.2.0/luacheck
	gealubi.unix_luacheck_path = [[/home/yeleaf/.luarocks/bin/luacheck2]] -- Without "quotes" if no spaces in path.

	-- (Optional)
	-- If custom .luacheckrc config not specified, then script will try to use local one, else if local config not in -
	-- - same directory with saved .lua file then search for default config, if empty then do work without config.
	gealubi.custom_luacheckrc_config_path = [[C:\.luacheckrc2]] -- This variable have higher priority. If path contains-
	-- - spaces then use "quotes"

	-- (Optional tweaks.)
	gealubi.run(6, false) -- Run gealubi script.
	--          |  ^--> @param 2 (type boolean): is for printing debug information. (Deafult: false (faster))
	--          ^--> @param1 (type number) : is for annotation style, select from 1 to 21. (Default: 6)
end

-- Learn about luacheck warning( and errors) codes at:
-- Link: https://luacheck.readthedocs.io/en/stable/warnings.html
