-- Filename: gealubi.lua
-- ## Place this file into:
-- ## 	For UNIX: $HOME/.config/geany/plugins/geanylua/support
-- ##	For Windows: ? Need MS-Windows users help.
-- Script name: gealubi (geany luacheck bindings)
-- Version 0.2.0-alpha
-- Author: Yeleaf(Yenoxel)
-- Link: https://github.com/Yenoxel/gealubi
-- First date: 2025-01-22
-- Time: 19:50
-- License: GPL-2.0
-- Adopted for linux OS, but with few tweaks can work on windows too. (And Mac?)
-- Dependencies: >= Geany 2.0; Luacheck 1.2.0-1 (Luarocks 5.3, LuaFileSystem 1.8.0-1, lanes 3.17.0-0, argparse 0.7.1-1)
-- Install luacheck in home directory. Like:
-- 		> luarocks --local install luacheck
-- 		sudo not need
-- Description: Auto popup anntations with described errors on each line where problem ocurrs.
-- Optional tweaks: Change verbosity variable (true/false) for enabling or disabling intermidiate data of script work.

-- ## Create file .luacheckrc:
-- ## Filename: .luacheckrc
-- ## Filepath: $HOME/.config/luacheck
-- ## Finalpath: /home/username/.config/luacheck/.luacheckrc
-- ## And put two lines below into that file. That config used for gealubi script, to be checked via luacheck.
-- max_line_length = 120
-- globals = {"geany"}

local gealubi = {}
gealubi.windows_luacheck_path = "C:\\app\\luacheck\\bin\\luacheck" --Example of absolute path to luacheck in windows os.
gealubi.gs = geany.scintilla
gealubi.st = geany.status
gealubi.verbosity = false -- On or off. For additional debug prints

function gealubi.clear_all_annotations()
	gealubi.gs("SCI_ANNOTATIONCLEARALL") -- Clear all annotations
	gealubi.gs("SCI_ANNOTATIONSETVISIBLE", 2) -- Choose boxed annotations style.
end

function gealubi.luacheck_report()
	local home_path = os.getenv("HOME") --> /home/username
	local app_path1 = ".luarocks"
	local app_path2 = "bin"
	local app_name = "luacheck"
	local dirsep = geany.dirsep -- Get directory separator symbol: '/' - for unix '\' - for MS-Windows
	local linter = string.format("%s%s%s%s%s%s%s",
			home_path,
			dirsep,
			app_path1,
			dirsep,
			app_path2,
			dirsep,
			app_name)
	local file_name = geany.filename() -- get filename with full path
	local no_color = "NO_COLOR=1 " -- Disable luacheck's ascii color codes, for clear output.
	local unix_luacheck = no_color .. linter .. " " .. file_name .. " --ranges"
	-- NOT TESTED. Needs windows user to test code below:
	local windows_luacheck = no_color .. gealubi.windows_luacheck_path .. " " .. file_name .. " --ranges"
	local windows_dirsep = "\\"
	local unix_dirsep = "/"
	if dirsep == unix_dirsep then -- If unix users.
		local output = io.popen(unix_luacheck , "r")
		-- Store each output messages from luacheck in table.
		local lines = {}
		for line in output:lines() do lines[#lines + 1] = line end
		output:close()
		return lines
	elseif dirsep == windows_dirsep then -- If MS-Windows users.
		local output = io.popen(windows_luacheck , "r")
		-- Store each output messages from luacheck in table.
		local lines = {}
		for line in output:lines() do lines[#lines + 1] = line end
		output:close()
		return lines
	end
end

function gealubi.print_luacheck_report()
	local lines = gealubi.luacheck_report()
	gealubi.st("extracted_lines_from_luacheck_report_start:")
	for i = 1, #lines do gealubi.st(lines[i]) end
	gealubi.st("extracted_lines_from_luacheck_report_end;")
end

function gealubi.extract_line_and_ranges()
	local lines = gealubi.luacheck_report()
	local issues_list = {}
	local raw_string_pattern = ":%d*:%d*-%d*"
	for i = 1, #lines do
		local pattern_check = string.match(lines[i], raw_string_pattern)
		if pattern_check then
			issues_list[#issues_list + 1] = pattern_check
		end
	end
	return issues_list
end

function gealubi.extract_exceptions_text()
	local lines = gealubi.luacheck_report()
	local exceptions_list = {}
	local raw_exception_text_pattern = ": (.*)" -- Extract all text after coordinates of exceptions.
	for i = 1, #lines - 1 do -- Skip last line, where total warnings shows
		local text_check = string.match(lines[i], raw_exception_text_pattern)
		exceptions_list[#exceptions_list + 1] = text_check
	end
	return exceptions_list
end

function gealubi.get_final_exceptions_coordinates()
	local issues_list = gealubi.extract_line_and_ranges()
	local final_coordinates = {}
	local line_pattern = ":%d*:"
	local column_start_pattern = ":%d*-"
	local column_end_pattern = "-%d*"
	-- Don't look at messy below, maybe later needs to optimize that? (Forgot about '(' and ')' usage for patterns.)
	for i = 1, #issues_list do
		local s = issues_list[i]
		local line = string.match(s, line_pattern )
		local column_start = string.match(s, column_start_pattern)
		local column_end = string.match(s, column_end_pattern)

		local l1, l2 = string.find(line, line_pattern)
		local n1, n2 = string.find(column_start, column_start_pattern)
		local j1, j2 = string.find(column_end, column_end_pattern)

		local final_line = tonumber(string.sub(line, l1+1, l2-1))
		local final_cs = tonumber(string.sub(column_start, n1+1, n2-1))
		local final_ce = tonumber(string.sub(column_end, j1+1, j2))

		final_coordinates[#final_coordinates +1] = {final_line, final_cs, final_ce}
	end
	return final_coordinates
end

function gealubi.get_problematic_lines()
	local line_pos = gealubi.get_final_exceptions_coordinates()
	local list_of_lines = {}
	for i = 1, #line_pos do
		list_of_lines[#list_of_lines + 1] = line_pos[i][1]
	end
	return list_of_lines
end

function gealubi.merge_lines_with_exceptions_text()
	local exceptions_text = gealubi.extract_exceptions_text()
	local list_of_lines = gealubi.get_problematic_lines()
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

function gealubi.print_merged_lines_with_exceptions_text()
	local exceptions_line_with_text = gealubi.merge_lines_with_exceptions_text()
	gealubi.st("print_merged_lines_with_exceptions_text_start:")
	for i = 1, #exceptions_line_with_text do
		local formated = string.format("[%s]: %s -|- %s",
			i,
			exceptions_line_with_text[i][1],
			exceptions_line_with_text[i][2])
		gealubi.st(formated)
	end
	gealubi.st("print_merged_lines_with_exceptions_text_end;")
end

function gealubi.draw_annotation(line, text)
	local ln = line - 1 -- Minus one, because indexing of lines starts from zero.
	gealubi.gs("SCI_AnnotationSetStyle", ln, 6) -- Yellow. But on differrent color schemes it's changes.
	gealubi.gs("SCI_AnnotationSetText", ln, text)
end

function gealubi.popup_all_annotations()
	local exceptions_line_with_text = gealubi.merge_lines_with_exceptions_text()
	for i = 1, #exceptions_line_with_text do
		local line = exceptions_line_with_text[i][1]
		local text = exceptions_line_with_text[i][2]
		gealubi.draw_annotation(line, text)
	end
end

function gealubi.print_extracted_exceptions_text()
	local exceptions_list = gealubi.extract_exceptions_text()
	gealubi.st("print_extracted_exceptions_text_start:")
	for i = 1, #exceptions_list do
		gealubi.st("["..i.."] "..exceptions_list[i])
	end
	gealubi.st("print_extracted_exceptions_text_end;")
end

function gealubi.print_problematic_lines()
	local list_of_lines = gealubi.get_problematic_lines()
	gealubi.st("print_problematic_lines_start:")
	for i = 1, #list_of_lines do
		gealubi.st(list_of_lines[i])
	end
	gealubi.st("print_problematic_lines_end;")
end

function gealubi.print_final_coordinates()
	local final_coordinates = gealubi.get_final_exceptions_coordinates()
	gealubi.st("print_final_coordinates_start:")
	gealubi.st("LN - Line number; CS - Column start; CE - Column end")
	for j = 1, #final_coordinates do
		local formated = string.format("LN:%d|CS:%d|CE:%d.",
		final_coordinates[j][1],
		final_coordinates[j][2],
		final_coordinates[j][3])
		gealubi.st(formated)
	end
	gealubi.st("Total number of coordinates: " .. #final_coordinates)
	gealubi.st("print_final_coordinates_end;")
end

function gealubi.print_extracted_line_and_ranges()
	local issues_list = gealubi.extract_line_and_ranges()
	gealubi.st("print_extracted_line_and_ranges_start:")
	gealubi.st("[n] - issue number; :a:b-c - issue char positions")
	for i = 1, #issues_list do
		gealubi.st("Issue number: [" .. i .. "]" .. issues_list[i] .. " ")
	end
		gealubi.st("print_extracted_line_and_ranges_end;")
end

function gealubi.tell_me_more(verbosity)
	if not gealubi.verbosity then gealubi.st("gealubi.verbosity setted to false. Skiping debug information(faster)") end
	if gealubi.verbosity then
		gealubi.st("START==================================================================VERBOSITY")
		gealubi.print_luacheck_report()
		gealubi.print_extracted_line_and_ranges()
		gealubi.print_final_coordinates()
		gealubi.print_extracted_exceptions_text()
		gealubi.print_problematic_lines()
		gealubi.print_merged_lines_with_exceptions_text()
		gealubi.st("END====================================================================VERBOSITY")
	end
end

function gealubi.lua_source_file()
	local file_info = geany.fileinfo() -- Get information of current saved file.
	local file_extension = file_info.ext -- Get extension of that file (e.g.: .lua, .txt, e.t.c.)
	local lua_ext = ".lua"
	if file_extension == lua_ext then
		gealubi.st("OK: File extension is: ("..file_extension..") gealubi can do job.")
		return true
	else
		gealubi.st("NOT OK! File extension is: ("..file_extension..") but (.lua) was expected.")
		return false
	end
end

function gealubi.run()
	if gealubi.lua_source_file() then
		gealubi.tell_me_more(gealubi.verbosity)
		-- Clear old annotations to set new if warnings occurs.
		gealubi.clear_all_annotations()
		gealubi.popup_all_annotations()
	end
end

return gealubi
