--[[
-- Filename: gealubi.lua
-- Version 0.4.0-beta
-- Update date: 14.02.2025 14:21:46
-- Script name defenition: gealubi (geany luacheck bindings)
-- Description: Auto popup annotations with described errors on each line where problem ocurrs.
-- Author: Yeleaf (Yenoxel)
-- Link 1: https://codeberg.org/Yeleaf/gealubi/src/branch/main/gealubi.lua
-- Link 2: https://github.com/Yenoxel/gealubi/blob/main/gealubi.lua
-- First date created: 2025-01-22
-- License: GPL-2.0
--
-- ## Place this file into:
-- ##	For UNIX: $HOME/.config/geany/plugins/geanylua/support/
-- ##	For MS-Windows: C:\users\username\AppData\Roaming\geany\plugins\geanylua\support\
-- ##	For macOS: ??? Please Contribute to the Issues or Pull Request.
--
-- For UNIX users:
-- 		Dependencies:
-- 			Geany >= 2.0; Geanylua plugin; Lua5.4; Luarocks 5.3;
-- 			Luacheck 1.2.0-1; LuaFileSystem 1.8.0-1; lanes 3.17.0-0; argparse 0.7.1-1)
-- Install luacheck in home directory. (without sudo) Like:
-- 		$ luarocks --local install luacheck
--
-- For MS-Windows users:
--		Dependencies:
--			Geany >=2.0; geany-plugins-2.0.exe; Luacheck.exe( already bundled with Lua and rest dependencies );
--			Download link for luacheck (https://github.com/mpeterv/luacheck/releases/download/0.23.0/luacheck.exe)
--
-- Important for:
-- 		MS-Windows users: to change variable 'gealubi.windows_luacheck_path' to set path to your luacheck application.
--
-- Optional tweaks: Change 'verbosity' variable (true/false) for enabling or disabling intermidiate data of script work.
--
-- Optional step, for those, who wants to control luacheck warnings:
-- ## How-to create luacheck config file: (https://luacheck.readthedocs.io/en/stable/config.html)
-- ## Create file: '.luacheckrc'
-- ## And place it into:
-- ## For UNIX OS:
-- ## Finalpath: /home/username/.config/luacheck/.luacheckrc
-- ## For MS-Windows OS:
-- ## Finalpath: C:\users\username\AppData\Local\Luacheck\.luacheckrc
-- ## For OS X/macOS:
-- ## Finalpath: ~/Library/Application Support/Luacheck/.luacheckrc
-- ## And put two lines below into that file. That config used for gealubi script, to be checked via luacheck.
-- max_line_length = 120
-- globals = {"geany"}
]]
----------------------------------
-- Functions diveded to blocks: --
-- 		Common functions.       --
-- 		Luacheck app functions. -- Trying to find luacheck app.
-- 		Luacheck config file.   -- Trying to find luacheck configuration file.
-- 		Parser.                 -- Extract data from luacheck warnings messages and prepare it for drawing annotations.
-- 		Draw functions.         -- Draw annotations in lua source code. And submit debug info to status bar.(Optional)
-- 		Check functions.        -- Pre-final checks for saved document and luacheck app. (If it exist.)
-- 		Final executor.         -- Final accumulator for all gealubi.lua script code.
-----------------------------------
-- GLOBALS START: (Visible in current file.)
local gealubi = {}
local conf_name = ".luacheckrc"
local dirsep = geany.dirsep -- Get current directory separator.
local raw_luacheck_report = {} -- Try to use this table and do not touch luacheck_report() function many times.
local gs = geany.scintilla
local st = geany.status
-- GLOBALS END;
----------------------------
-- Common functions.      --
----------------------------
local function clear_all_annotations()
	gs("SCI_AnnotationClearAll") -- Clear all annotations
	gs("SCI_AnnotationSetVisible", 2) -- Choose boxed annotations style. Choose from 1 to 3 (0 is set invisible)
end

local function status_messages_delemiter()
	st("[END]: _______________________________________________________________________")
end

local function is_windows()
	if dirsep == "\\" then return true else return false end
end

local function is_unix()
	if dirsep == "/" then return true else return false end
end
-- Draft function for macOS:
local function is_mac_os()
	local file = io.popen("uname", "r")
	local result = file:read("*all")
	file:close()
	if result == "Darwin\n"  then return true else return false end
end

local function is_file_exist(full_path_to_file)
	if full_path_to_file then
		if is_unix() then
			local file_exist = geany.fullpath(full_path_to_file)
			if file_exist then return true else return false end

		elseif is_windows() then
			local file_exist = io.open(full_path_to_file, "r")
			if file_exist then
				file_exist:close()
				return true
			else
				return false
			end
		end
	end
end

-----------------------------
-- Luacheck app functions. --
-----------------------------
--//// Unix part: ////
local function is_custom_unix_luacheck_exist()
	local app_exist = is_file_exist(gealubi.unix_luacheck_path) -- If setted correctly, can work on MacOS too.
	local msg_found = "[INFO]:[LUACHECK]: Success! Luacheck found at: " .. gealubi.unix_luacheck_path ..
		" (Custom unix path)"
	local msg_not_found = "[INFO]:[LUACHECK]: Custom luacheck's path not found at: " .. gealubi.unix_luacheck_path ..
		". Trying to set default path."
	if app_exist then -- If user's specified path to luacheck was setted correctly..
		return true, gealubi.unix_luacheck_path, msg_found
	else
		return false, "", msg_not_found
	end
end

local function is_default_unix_luacheck_exist()
	-- Default path to the luacheck app. On Linux distros only.
	local home_path = os.getenv("HOME") --> /home/username
	local path_to_app = ".luarocks/bin/luacheck"
	local full_path = string.format("%s/%s", home_path, path_to_app)
	local msg_found = "[INFO]:[LUACHECK]: Success! Luacheck found at: " .. full_path .. " (Default linux path)"
	local msg_not_found = "[ERROR]:[LUACHECK]: Where your luacheck? That path is correct?: " .. full_path
	local is_app_on_default_path = is_file_exist(full_path)
	if is_app_on_default_path then
		return true, full_path, msg_found
	else
		return false, "", msg_not_found
	end

end

local function get_unix_luacheck_path()
	-- custom
	local status1, path1, msg1 = is_custom_unix_luacheck_exist()
	-- default
	local status2, path2, msg2 = is_default_unix_luacheck_exist()
	if status1 then
		return status1, path1, msg1
	elseif status2 then
		return status2, path2, msg2, msg1
	elseif not status2 then
		return status2, path2, msg2, msg1
	end
end

local function is_unix_luacheck_found()
	local status, _, message, additional_msg = get_unix_luacheck_path()
	if additional_msg then st(additional_msg) end
	st(message)
	return status
end
--\\\\ MS-Windows part: \\\\
local function is_windows_luacheck_found()
	local app_found = false
	-- Check if current file can be parsed by luacheck:
	local status = os.execute('"' .. gealubi.windows_luacheck_path .. ' "' .. geany.filename() .. '"')
		if status ~= 9009 then
			st("[INFO]:[LUACHECK]: Success! Luacheck found at: " .. gealubi.windows_luacheck_path)
			app_found = true
			if status == 0 then
				st("[INFO]: Luacheck says: no warnings or errors occurred." ..
					" Exit code is: " .. status)
			elseif status == 1 then
				st("[INFO]: Luacheck says: some warnings occurred but there were no syntax errors or invalid inline options." ..
					" Exit code is: " .. status)
			elseif status == 2 then
				st("[INFO]: Luacheck says: some syntax errors or invalid inline options." ..
					" Exit code is: " .. status)
			elseif status == 3 then
				st("[ERROR]: Luacheck says: files couldn’t be checked, typically due to an incorrect file name." ..
					" Exit code is: " .. status)
			elseif status == 4 then
				st("[ERROR]: Luacheck says: there was a critical error (invalid CLI arguments, config, or cache file)." ..
					" Exit code is: " .. status)
			end
		elseif status == 9009 then -- Can't recognize 'app name' as an internal or external command, or batch script.
			st("[ERROR]: Where your luacheck.exe? That path is correct: " ..
				gealubi.windows_luacheck_path .." ? Exit code is: " .. status)
			app_found = false
		end
	return app_found
end

--------------------------
-- Luacheck config file.--
--------------------------
--[[
Try to find .luacheckrc config file. Priority:
1. custom one, which specified in gealubi.custom_luacheckrc_config_path variable.
2. local one, where scripts saved
3. parent dir of saved script
4. parent of parent dir of saved script.
5. default one, for luacheck app standart folders.
6. do job without config at all, by setting '--no-config' option to luacheck app.
]]
local function is_custom_luacheckrc_config_file_exist()
	local file_exist = is_file_exist(gealubi.custom_luacheckrc_config_path)
	if file_exist then
		return gealubi.custom_luacheckrc_config_path
	end
end

local function is_local_luacheckrc_config_file_exist(path)
	local full_path = path .. conf_name
	local file_exist = is_file_exist(full_path)
	if file_exist then
		return full_path
	end
end

local function get_parents_dirs(path)
	local dirseps = {} -- Table for directory separtor positions in file path.
	local i = 0
	while true do -- Finds all directory separators in provided 'path' variable.
		i = string.find(path, dirsep, i+1)
		if i == nil then break end
		dirseps[#dirseps+1] = i
	end
	local second_to_last_dirsep = dirseps[#dirseps - 1]
	local third_to_last_dirsep = dirseps[#dirseps - 2]
	local second_to_last_dir = string.sub(path, 1, second_to_last_dirsep)
	local third_to_last_dir = string.sub(path, 1, third_to_last_dirsep)

	return second_to_last_dir, third_to_last_dir
end

local function is_parent_luacheck_config_exist(path)
	local second_to_last_dir, _ = get_parents_dirs(path)
	local full_path = second_to_last_dir .. conf_name
	local file_exist = is_file_exist(full_path)
	if file_exist then
		return full_path
	end
end

local function is_parent_of_parent_config_exist(path)
	local _, third_to_last_dir = get_parents_dirs(path)
	local full_path = third_to_last_dir .. conf_name
	local file_exist = is_file_exist(full_path)
	if file_exist then
		return full_path
	end
end

local function is_default_luacheckrc_config_file_exist()
	if is_unix() then
		local home_dir = os.getenv("HOME") --> /home/username
		local conf_dir = "/.config/luacheck/.luacheckrc"
		local full_path = home_dir .. conf_dir
		local file_exist = is_file_exist(full_path)
		if file_exist then
			return full_path
		end

	elseif is_windows() then
		local home_dir = os.getenv("LOCALAPPDATA") --> C:\users\username\AppData\Local
		local conf_dir = "\\Luacheck\\.luacheckrc"
		local full_path = home_dir .. conf_dir
		local file_exist = is_file_exist(full_path)
		if file_exist then
			return full_path
		end

	elseif is_mac_os() then
		local home_dir = os.getenv("HOME") --> ?
		local conf_dir = "/Library/Application Support/Luacheck/.luacheckrc"
		local full_path = home_dir .. conf_dir
		local file_exist = is_file_exist(full_path)
		if file_exist then
			return full_path
		end
	end
end

local function is_config_exist(path)
	local custom_config     = is_custom_luacheckrc_config_file_exist()
	local local_config      = is_local_luacheckrc_config_file_exist(path)
	local parent_config     = is_parent_luacheck_config_exist(path)
	local par_of_par_config = is_parent_of_parent_config_exist(path)
	local default_config    = is_default_luacheckrc_config_file_exist()

	if custom_config then
		st("[INFO]:[CONFIG]: Custom '.luacheckrc' config was found at: " .. custom_config)
		return custom_config
	elseif local_config then
		st("[INFO]:[CONFIG]: Local '.luacheckrc' config was found at: " .. local_config)
		return local_config
	elseif parent_config then
		st("[INFO]:[CONFIG]: Parent '.luacheckrc' config was found at: " .. parent_config)
		return parent_config
	elseif par_of_par_config then
		st("[INFO]:[CONFIG]: Parent of Parent '.luacheckrc' config was found at: " .. par_of_par_config)
		return par_of_par_config
	elseif default_config then
		st("[INFO]:[CONFIG]: Default '.luacheckrc' config was found at: " .. default_config)
		return default_config
	elseif not default_config then
		st("[INFO]:[CONFIG]: Can not find no one '.luacheckrc' configuration file. Continue job without it.")
	end
end

local function get_luacheck_config(path)
	local config_exist = is_config_exist(path)
	if is_unix() then
		if config_exist then
			local final_cmd = string.format(" --config %s ", config_exist)
			return final_cmd
		elseif not config_exist then
			return " --no-config "
		end

	elseif is_windows() then
		if config_exist then
			return config_exist
		else
			return " --no-config "
		end
	end
end
-------------
-- Parser. --
-------------
local function luacheck_report()
	local file_name = geany.filename() -- get filename with full path
	local file_info = geany.fileinfo()
	local file_path = file_info.path -- Get path to the current file without file name.

	if is_unix() then -- If unix users.
		local _, linter, _, _ = get_unix_luacheck_path()
		local config_file = get_luacheck_config(file_path)
		local unix_luacheck = linter .. config_file .. file_name .. " --no-color --codes"
		st("[INFO]: Final command is: (" .. unix_luacheck .. ").")
		local output = io.popen(unix_luacheck , "r")
		local lines = {}
		for line in output:lines() do lines[#lines + 1] = line end
		output:close()
		return lines

	elseif is_windows() then -- If MS-Windows users.
		-- That was hard to figure out how to pass correctly the paths. Was needed using extra quotes (")
		-- Tested in Command Prompt. Correct path is:
		-- "C:\path\to\luacheck.exe" --config "path\to\.luacheckrc" "path\to\file.lua" --ranges --no-color
		-- If luacheck config is not specified (no in local dir or default dir) then give filename to luacheck app only.
		local windows_luacheck = ""
		-- luacheck: ignore conf_cmd
		local conf_cmd = "--no-config"
		local config_exist = get_luacheck_config(file_path)
		if config_exist ~= " --no-config " then
			windows_luacheck = string.format([["%s --config "%s" "%s"" --no-color --codes]],
				gealubi.windows_luacheck_path, config_exist, file_name)
		elseif config_exist == " --no-config " then
			conf_cmd = "--no-config"
			windows_luacheck = string.format([["%s %s "%s"" --no-color --codes]],
				gealubi.windows_luacheck_path, conf_cmd, file_name)
		end
		st("[INFO]: Final command is: (" .. windows_luacheck .. ").") -- Useful for debugging. Able to copy directly to-
		-- -terminal(console).
		local output = io.popen(windows_luacheck , "r")
		local lines = {}
		for line in output:lines() do lines[#lines + 1] = line end
		output:close()
		return lines
	end
end

local function print_luacheck_report()
	local lines = raw_luacheck_report
	st("[DEBUG]: extracted_lines_from_luacheck_report_start:")
	for i = 1, #lines do st(lines[i]) end
	st("[DEBUG]: extracted_lines_from_luacheck_report_end;")
end

local function extract_lines()
	local lines = raw_luacheck_report
	local problematic_lines = {}
	local raw_string_pattern = ":(%d*):%d*:"
	for i = 1, #lines do
		local pattern_check = string.match(lines[i], raw_string_pattern)
		if pattern_check then
			problematic_lines[#problematic_lines + 1] = pattern_check
		end
	end
	return problematic_lines
end

local function print_extracted_lines()
	local problematic_lines = extract_lines()
	st("[DEBUG]: print_extracted_lines_start:")
	for i = 1, #problematic_lines do
		st("[DEBUG]: " .. problematic_lines[i])
	end
	st("[DEBUG]: print_extracted_lines_end;")
end

local function extract_exceptions_text()
	local lines = raw_luacheck_report
	local exceptions_list = {}
	local raw_exception_text_pattern = ": (.*)" -- Extract all text after coordinates of exceptions.
	for i = 1, #lines - 1 do -- Skip last line, where total warnings shows
		local text_check = string.match(lines[i], raw_exception_text_pattern)
		exceptions_list[#exceptions_list + 1] = text_check
	end
	return exceptions_list
end

local function print_extracted_exceptions_text()
	local exceptions_list = extract_exceptions_text()
	st("[DEBUG]: print_extracted_exceptions_text_start:")
	for i = 1, #exceptions_list do
		st("["..i.."] "..exceptions_list[i])
	end
	st("[DEBUG]: print_extracted_exceptions_text_end;")
end

local function merge_lines_with_exceptions_text()
	local exceptions_text = extract_exceptions_text()
	local list_of_lines = extract_lines()
	local exceptions_line_with_text = {}

	for i = 1, #list_of_lines do
		local line = list_of_lines[i]
		local text = exceptions_text[i]
		exceptions_line_with_text[#exceptions_line_with_text + 1] = {line, text}
	end

	local temp = {}
	for _, entry in ipairs(exceptions_line_with_text) do
		local num, text = entry[1], entry[2]
	if not temp[num] then
		temp[num] = {}
	end
		table.insert(temp[num], text)
	end

	local final_bad_lines_with_text = {}
	for num, texts in pairs(temp) do
		table.insert(final_bad_lines_with_text, {num, table.concat(texts, "\n")})
	end

	return final_bad_lines_with_text
end

local function print_merged_lines_with_exceptions_text()
	local exceptions_line_with_text = merge_lines_with_exceptions_text()
	st("[DEBUG]: print_merged_lines_with_exceptions_text_start:")
	for i = 1, #exceptions_line_with_text do
		local formated = string.format("[%s]: %s -|- %s",
			i,
			exceptions_line_with_text[i][1],
			exceptions_line_with_text[i][2])
		st(formated)
	end
	st("[DEBUG]: print_merged_lines_with_exceptions_text_end;")
end
---------------------
-- Draw functions. --
---------------------
local function draw_annotation(line, text, annotation_style)
	local ln = line - 1 -- Minus one, because indexing of lines starts from zero.
	tonumber(annotation_style)
	if type(annotation_style) ~= "number" then annotation_style = 6 end
	gs("SCI_AnnotationSetStyle", ln, annotation_style) -- Style changes on differrent color schemes.
	gs("SCI_AnnotationSetText", ln, text)
end

local function popup_all_annotations(annotation_style)
	local exceptions_line_with_text = merge_lines_with_exceptions_text()
	st("[INFO]: Total number of problematic lines: " .. #exceptions_line_with_text)
	local line_list = ""
	for i = 1, #exceptions_line_with_text do
		line_list = line_list .. exceptions_line_with_text[i][1] .. ", "
	end
	st("[INFO]: Which lines require your attention: (" .. line_list .. ").")
	for i = 1, #exceptions_line_with_text do
		local line = exceptions_line_with_text[i][1]
		local text = exceptions_line_with_text[i][2]
		draw_annotation(line, text, annotation_style)
	end
end

----------------------
-- Check functions. --
----------------------
--~ TODO: Add exceptions to luau extension and .luacheckrc config file?
local function lua_source_file()
	local file_info = geany.fileinfo() -- Get information of current saved file.
	local file_extension = file_info.ext -- Get extension of that file (e.g.: .lua, .txt, e.t.c.)
	local lua_ext = ".lua"
	if file_extension == lua_ext then
		st("[INFO]: OK! File extension is: ("..file_extension..") gealubi can do job.")
		return true
	else
		st("[INFO]: NOT OK! File extension is: ("..file_extension..") but (.lua) was expected.")
		return false
	end
end

local function tell_me_more(verbosity)
	if not verbosity then st("[INFO]: 'verbosity' variable setted to false. Skiping debug information (faster)") end
	if verbosity then
		st("[DEBUG]: START==================================================================VERBOSITY")
		print_luacheck_report()
		print_extracted_lines()
		print_extracted_exceptions_text()
		print_merged_lines_with_exceptions_text()
		st("[DEBUG]: END====================================================================VERBOSITY")
	end
end

---------------------
-- Final executor. --
---------------------
function gealubi.run(annotation_style, verbose) -- Final order of execution of the 'gealubi.lua' script.
	if lua_source_file() then -- Is current file have .lua extension?

		if is_windows() then -- If MS-Windows current Operating System.
			if is_windows_luacheck_found() then -- Is luacheck application found?
				raw_luacheck_report = luacheck_report() -- Call luacheck app once. After save.
				tell_me_more(verbose) -- Intermidiate data of script work. Depends on 'verbosity' variable.
				clear_all_annotations() -- Clear old scintilla annotations, before set the new one.
				popup_all_annotations(annotation_style) -- Core job of all script.
				status_messages_delemiter()
			end

		elseif is_unix() then -- If Unux is current operating system.
			if is_unix_luacheck_found() then -- Is luacheck application found?
				raw_luacheck_report = luacheck_report() -- Call luacheck app once. After save.
				tell_me_more(verbose) -- Intermidiate data of script work. Depends on 'verbosity' variable.
				clear_all_annotations() -- Clear old scintilla annotations, before set the new one.
				popup_all_annotations(annotation_style) -- Core job of all script.
				status_messages_delemiter()
			end
		end
	end
	raw_luacheck_report = nil -- Clear table with old reports, for filling it with fresh luacheck_report() in next run.
end
--
-- Exporting:
return gealubi -- Return module for 'saved.lua'
