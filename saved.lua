-- Script name: gealubi (geany luacheck bindings)
-- Version 0.1
-- Author: Yeleaf
-- Date: 2025-01-22
-- Time: 19:50
-- License: GPL?
-- Adopted for linux OS
-- Dependencies: >= Geany 2.0; Luacheck 1.2.0-1 (Luarocks 5.3, LuaFileSystem 1.8.0-1, lanes 3.17.0-0, argparse 0.7.1-1)
-- Install luacheck in home directory. Like:
-- 		> luarocks --local install luacheck
-- 		sudo not need
-- Description: Auto popup anntations with described errors on each line where problem ocurrs.
-- Optional tweaks: Change verbosity variable (true/false) for enabling or disabling intermidiate data of script work.
-- If you need indicators, uncomment function call: 'indicate_all_exceptions()' P.S. may not work properly.

-- Create file .luacheckrc:
-- ## Filename: .luacheckrc
-- ## Filepath: $HOME/.config/luacheck
-- ## Finalpath: /home/username/.config/luacheck/.luacheckrc
-- ## And put two lines below into that file. That config used for gealubi script, to be checked via luacheck.
-- max_line_length = 120
-- globals = {"geany"}

local gs = geany.scintilla
local st = geany.status
local verbosity = false -- On or off additional debug prints
gs("SCI_ANNOTATIONSETVISIBLE", 2) -- Choose boxed annotations style.

-- Clear all indcitors in entire document.
local function clear_all_indicators()
	local last_char = geany.length()
	gs("SCI_INDICATORCLEARRANGE", 0, last_char)
end

local function clear_all_annotations()
	gs("SCI_ANNOTATIONCLEARALL") -- Clear all annotations
end

-- Iterate through all document(file) and get last visible(printable) character in each line.
local function get_last_char_in_lines()
	local char_positions = {}
	for i = 0, geany.height() - 1 do -- Minus one, for hiding last line duplicate.
		local line_end_pos = gs("GetLineEndPosition", i)
		char_positions[#char_positions + 1] = line_end_pos
	end
	return char_positions
end

-- Printing message in status bar [line number] == n; Where n is have number of last char in current line.
-- Each line corresponding to their last visible char.
local function print_last_chars_positions()
	local char_positions = get_last_char_in_lines()
	st("print_last_chars_positions_start:")
	for i = 1, #char_positions do
		st("[" .. i .."] == " .. char_positions[i])
	end
	st("print_last_chars_positions_end;")
end

local function draw_indicator(line, startpos, endpos)
	gs("SCI_SETINDICATORCURRENT", 1)
	gs("SCI_INDICSETSTYLE", 1, 1)
	-- Add few more colors: yellow for warnings, red for errors, purple for fatal?
	gs("SCI_INDICSETFORE", 1, 0xff00ffff) -- Yellow
	local char_positions = get_last_char_in_lines()
	if line == 1 then
		gs("SCI_IndicatorFillRange", startpos -1, endpos)
	elseif line > 1 then
		local ln = char_positions[line - 1]
		gs("SCI_IndicatorFillRange", ln + startpos , endpos)
	end
end

local function luacheck_report()
	local home_path = os.getenv("HOME") --> /home/username
	local app_path = "/.luarocks/bin/"
	local app_name = "luacheck"
	local file_name = geany.filename() -- get filename with full path
	local no_color = "NO_COLOR=1 " -- Disable luacheck's ascii color codes, for clear output.
	local luacheck = no_color .. home_path .. app_path .. app_name .. " " .. file_name .. " --ranges"
	local output = io.popen(luacheck , "r")
	-- Store each output messages from luacheck in table.
	local lines = {}
	for line in output:lines() do lines[#lines + 1] = line end
	output:close()
	return lines
end

local function print_luacheck_report()
	local lines = luacheck_report()
	st("extracted_lines_from_luacheck_report_start:")
	for i = 1, #lines do st(lines[i]) end
	st("extracted_lines_from_luacheck_report_end;")
end

local function extract_line_and_ranges()
	local lines = luacheck_report()
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

local function extract_exceptions_text()
	local lines = luacheck_report()
	local exceptions_list = {}
	local raw_exception_text_pattern = ": (.*)" -- Extract all text after coordinates of exceptions.
	for i = 1, #lines - 1 do -- Skip last line, where total warnings shows
		local text_check = string.match(lines[i], raw_exception_text_pattern)
		exceptions_list[#exceptions_list + 1] = text_check
	end
	return exceptions_list
end

local function get_final_exceptions_coordinates()
	local issues_list = extract_line_and_ranges()
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

local function get_problematic_lines()
	local line_pos = get_final_exceptions_coordinates()
	local list_of_lines = {}
	for i = 1, #line_pos do
		list_of_lines[#list_of_lines + 1] = line_pos[i][1]
	end
	return list_of_lines
end

local function merge_lines_with_exceptions_text()
	local exceptions_text = extract_exceptions_text()
	local list_of_lines = get_problematic_lines()
	local exceptions_line_with_text = {}
	-- Because exceptions_text and list_of_lines tables have same ammount of lines, can use any of them.
	local to_the_end = #exceptions_text
	for i = 1, to_the_end do -- Remake this to collect all exceptions text into one corresponding line.
		local line = list_of_lines[i]
		local previous_line = list_of_lines[i - 1]
		if line == previous_line then -- Try to concatinate warning strings on same line. If errorrs ocurrs on the same.
			-- Works for 2 errors only, if errors more than 2, last 2 warnings will be annotate
			local current_text = "\n"..exceptions_text[i]
			exceptions_line_with_text[#exceptions_line_with_text] = {list_of_lines[i], exceptions_text[i-1]..current_text}
		else
			exceptions_line_with_text[#exceptions_line_with_text + 1] = {list_of_lines[i], exceptions_text[i]}
		end
	end
	return exceptions_line_with_text
end

local function print_merged_lines_with_exceptions_text()
	local exceptions_line_with_text = merge_lines_with_exceptions_text()
	st("print_merged_lines_with_exceptions_text_start:")
	for i = 1, #exceptions_line_with_text do
		local formated = string.format("%s -|- %s",
			exceptions_line_with_text[i][1],
			exceptions_line_with_text[i][2])
		st(formated)
	end
	st("print_merged_lines_with_exceptions_text_end;")
end

local function draw_annotation(line, text)
	local ln = line - 1 -- Minus one, because indexing of lines starts from zero.
	gs("SCI_AnnotationSetStyle", ln, 6) -- Yellow. But on differrent color schemes it's changes.
	gs("SCI_AnnotationSetText", ln, "warning: "..text)
end

local function popup_all_annotations()
	local exceptions_line_with_text = merge_lines_with_exceptions_text()
	for i = 1, #exceptions_line_with_text do
		local line = exceptions_line_with_text[i][1]
		local text = exceptions_line_with_text[i][2]
		draw_annotation(line, text)
	end
end

local function print_extracted_exceptions_text()
	local exceptions_list = extract_exceptions_text()
	st("print_extracted_exceptions_text_start:")
	for i = 1, #exceptions_list do
		st("["..i.."] "..exceptions_list[i])
	end
	st("print_extracted_exceptions_text_end;")
end

local function print_problematic_lines()
	local list_of_lines = get_problematic_lines()
	st("print_problematic_lines_start:")
	for i = 1, #list_of_lines do
		st(list_of_lines[i])
	end
	st("print_problematic_lines_end;")
end

local function indicate_all_exceptions()
	local final_coordinates = get_final_exceptions_coordinates()
	for i = 1, #final_coordinates do
		local line = final_coordinates[i][1]
		local startpos = final_coordinates[i][2]
		local endpos = final_coordinates[i][3]

		if startpos == endpos then
			draw_indicator(line, startpos, 1)
		else
			draw_indicator(line, startpos, endpos)
		end
	end
end

local function print_final_coordinates()
	local final_coordinates = get_final_exceptions_coordinates()
	st("print_final_coordinates_start:")
	st("LN - Line number; CS - Column start; CE - Column end")
	for j = 1, #final_coordinates do
		local formated = string.format("LN:%d|CS:%d|CE:%d.",
		final_coordinates[j][1],
		final_coordinates[j][2],
		final_coordinates[j][3])
		st(formated)
	end
	st("Total number of coordinates: " .. #final_coordinates)
	st("print_final_coordinates_end;")
end

local function print_extracted_line_and_ranges()
	local issues_list = extract_line_and_ranges()
	st("print_extracted_line_and_ranges_start:")
	st("[n] - issue number; :a:b-c - issue char positions")
	for i = 1, #issues_list do
		st("Issue number: [" .. i .. "]" .. issues_list[i] .. " ")
	end
		st("print_extracted_line_and_ranges_end;")
end

local function tell_me_more(verbosity)
	if verbosity then
		st("START==================================================================VERBOSITY")
		print_luacheck_report()
		print_last_chars_positions()
		print_extracted_line_and_ranges()
		print_final_coordinates()
		print_extracted_exceptions_text()
		print_problematic_lines()
		print_merged_lines_with_exceptions_text()
		st("END====================================================================VERBOSITY")
	end
end
tell_me_more(verbosity)
-- Clear old indicators and annotations to set new if warnings occur.
clear_all_indicators()
clear_all_annotations()
--~ indicate_all_exceptions() -- Annotations more useful and informative rather then simple indicators.
popup_all_annotations()

--~ TODO: Proper naming for tables and other...
--~ TODO: Recolorize indicators by looking at currently active color scheme theme. (Dark or White)
--~ TODO: Pack entire script into module. For giving others scripts to work with it.
