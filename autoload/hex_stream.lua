--[[--------------------------------------------]
|This module defines a stream hex encoder. It is|
|fed small chunks of binary data and returns the|
|hex-dumped version. As Vim likes to work with  |
|lines, it is more efficient that way.          |
[----------------------------------------------]]


-- Serialize a binary string in a succession of bytes separated by spaces
local function reduced_hd (content)
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
        error(string.format("Content of full_hd too long (%i/16)", #content))
    end
    local offset_fmt = string.format("%%0%dx", offset_size)
    return string.format(offset_fmt .. " | %s | %s", offset, pad_left(reduced_hd(content), 16 * 3 - 1), show_byte_array(content))
end

-- Module to process some text into a list of lines
-- A default version in Lua is implemented but we try to replace it with a
-- faster version written in C if it is available.
local helper = {process = function(offset, offset_size, unprocessed_data)
    local ret = {}
    local number_of_lines = math.floor(#unprocessed_data/16)
    for i=1,number_of_lines do
      ret[#ret+1] = full_hd(offset, offset_size, unprocessed_data:sub(1+((i-1)*16), (i)*16))
    end
    local left_unprocessed = unprocessed_data:sub(1+number_of_lines*16)
    return ret, left_unprocessed
end}
local so_lib_path = package.cpath:sub(0,#package.cpath-4).."hex_stream_helper.so"
local so = io.open(so_lib_path, "r")
if so ~= nil then
    so:close()
    helper = require("hex_stream_helper")
end

-- streamer object
-- Takes as input the estimated size of the total data
--
-- streamer:process(data) -> Add new data to process and return the last
--                           processed data as a list of lines.
-- streamer:finishes()    -> Process any leftover data and render the streamer
--                           unusable. The data is returned as a list of lines.
local new_stream_hexdumper = function(est_size)
    local stream_hd = {}
    stream_hd.unprocessed_data = ""
    stream_hd.line_count = 0
    stream_hd.finished = false
    stream_hd.offset_size = math.max(1, math.ceil(math.log(est_size)/math.log(16)))

    stream_hd.__add_data = function(stream, data)
        stream.unprocessed_data = stream.unprocessed_data .. data
    end

    stream_hd.__process = function(stream)
        local line_table, left_unprocessed = helper.process(stream.line_count * 16, stream.offset_size, stream.unprocessed_data)
        stream.line_count = stream.line_count + #line_table
        stream.unprocessed_data = left_unprocessed
        return line_table
    end

    stream_hd.__check_finished = function(stream)
        if stream.finished then
            error("Trying to use a finished stream")
        end
    end

    stream_hd.process = function(stream, data)
        stream:__check_finished()
        stream:__add_data(data)
        return stream:__process()
    end

    stream_hd.finish = function(stream, data)
        stream:__check_finished()
        local ret = stream:__process()
        ret[#ret+1] = full_hd(stream.line_count * 16, stream.offset_size, stream.unprocessed_data)
        stream.finished = true
        return ret
    end

    return stream_hd
end

return new_stream_hexdumper

