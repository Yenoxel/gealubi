-- Filename: saved.lua
-- Works only if geanylua plugins is installed into your Geany IDE
-- Place this file onto:
-- 	For UNIX: $HOME/.config/geany/plugins/geanylua/events/
-- 	For MS-Windows: C:\users\username\AppData\Roaming\geany\plugins\geanylua\events\
-- Author: Yeleaf (Yenoxel).
-- Link 1: https://codeberg.org/Yeleaf/gealubi/src/branch/main/saved.lua
-- Link 2: https://github.com/Yenoxel/gealubi/blob/main/saved.lua
-- Update Date: 05.02.2025 11:29:35
-- Version: 0.3.0-alpha
-- Licence: GPL-2.0
local app_info = geany.appinfo()
local script_dir = app_info.scriptdir -- Get scritdir location for geanylua plugin.
--geany.message(script_dir) -- Uncomment this to get Geany Dialog window with path to the scriptdir.
local dirsep = geany.dirsep -- Get directory separator. '/' - for unix and '\' for microsoft windows.
local support_dir = "support" -- Place where gealubi.lua script must be.
local script_name = "gealubi.lua"
local module = script_dir .. dirsep .. support_dir .. dirsep .. script_name --Concatenate all path to the script.
local gealubi = dofile(module) -- Load gealubi script
gealubi.run() -- Run gealubi script.
