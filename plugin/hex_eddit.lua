local module = {}

-------------------------------- Dumping to hex --------------------------------

-- Serialize a binary string in a succesion of bytes separated by spaces
local function reduced_hd(content)
    local ret = ""
    for i=1,#content do
        ret = ret .. string.format("%02x ", content:byte(i,i))
    end
    return ret:sub(1, #ret-1)
end

-- Add spaces to s until of the right size.
local function pad_left(s, size)
    while #s < size do
        s = s .. " "
    end
    return s
end

-- From a binary string, return a string that shows its content.
local function show_byte_array(content)
    local ret = ""
    for i=1,#content do
        local byte = content:byte(i,i)
        if byte == 0 then
            ret = ret .. "␀"
        elseif byte <= 0x6 then
            ret = ret .. "○"
        elseif byte == 0x7 then
            ret = ret .. "⍾" -- Not great
        elseif byte == 0x8 then
            ret = ret .. "⇤"
        elseif byte == 0x9 then
            ret = ret .. "⇥"
        elseif byte == 0xA then
            ret = ret .. "↵"
        elseif byte <= 0xC then
            ret = ret .. "○"
        elseif byte == 0xD then
            ret = ret .. "↵"
        elseif byte <= 0x1F then
            ret = ret .. "○"
        elseif byte <= 0x7E then
            ret = ret .. content:sub(i,i)
        else
            ret = ret .. "·"
        end
    end
    return ret
end

-- Return a string of hexdumped value. The offset is used for the hint and
-- should be an integer. The content should be a binary string of at most 16
-- bytes. Offset_size is an int telling the number of ex digits in offset.
local function full_hd(offset, offset_size, content)
    if #content > 16 then
        error("Content of full_hd too long")
    end
    local offset_fmt = string.format("%%0%dx", offset_size)
    return string.format(offset_fmt .. " | %s | %s", offset, pad_left(reduced_hd(content), 16 * 3 - 1), show_byte_array(content))
end

-- Cut the buffer in 16 bytes chunks and hd them all.
module.hd_buffer = function(content)
    local offset_size = math.ceil(math.log(#content+1, 16))
    local ret = ""
    for i=0,math.ceil(#content/16) do
        ret = ret .. full_hd(i * 16, offset_size, content:sub(i*16+1, (i+1)*16)) .. "\n"
    end
    return ret
end

--------------------------------- Hex to binary --------------------------------

-- Remove position and content hints from a line of hexdump. After that, the
-- whitespace is also removed.
local function remove_hints_and_ws(line)
    local no_pos_hint = line:gsub("^[^|]*|", "")
    local no_hint = no_pos_hint:gsub("|.*$", "")
    return no_hint:gsub("%s", "")
end

-- Ensure that a line of raw hexdump does not contains anything else than
-- hex digits and have a pairs of them. Should be applied to the output of
-- `remove_hints_and_ws`.
local function check_good_raw_dh(line)
    local no_digits = line:gsub("[a-fA-F0-9]", "")
    if #no_digits ~= 0 then
        print(line)
        error("Input of check_good_raw_dh contains bad chars.")
    end
    if #line % 2 ~= 0 then
        print(line)
        error("Input of check_good_raw_dh contains an odd number of digits")
    end
end

-- From a line of raw hexdump, returns a string of the binary value.
local function binarize_hd(line)
    local ret = ""
    for i=1,#line/2 do
        byte = line:sub((i-1)*2+1, i*2)
        ret = ret .. string.char(tonumber(byte, 16))
    end
    return ret
end

-- From a string of text, splits it inti a table of each line of the text.
local function split_line(txt)
    local ret = {}
    local last_i = 1
    for i=1,#txt do
        if txt:sub(i,i) == "\n" then
            ret[#ret+1] = txt:sub(last_i, i-1)
            last_i = i+1
        end
    end
    return ret
end

-- Binarize a whole text of hexdump text.
module.binarize_buffer = function(content)
    local ret = ""
    local lines = split_line(content)
    for i=1,#lines do
        local raw = remove_hints_and_ws(lines[i])
        check_good_raw_dh(raw)
        ret = ret .. binarize_hd(raw)
    end
    return ret
end

return module

