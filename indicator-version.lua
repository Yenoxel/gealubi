local gs = geany.scintilla
local st = geany.status
local verbosity = false -- On or off additional debug prints

-- Clear all indcitors in entire document.
local function clear_all_indicators()
	local last_char = geany.length()
	gs("SCI_INDICATORCLEARRANGE", 0, last_char)
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

local function tell_me_more(verbosity)
	if verbosity then
		st("START==================================================================VERBOSITY")
		print_luacheck_report()
		print_last_chars_positions()
		st("END====================================================================VERBOSITY")
	end
end

tell_me_more(verbosity)
clear_all_indicators()
indicate_all_exceptions() -- Annotations more useful and informative rather then simple indicators.
