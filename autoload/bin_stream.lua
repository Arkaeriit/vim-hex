--[[------------------------------------------]
|This module transform an hex dump into binary|
|data in a stream fashion. It is used to take |
|lines of hexdumped data and return lines of  |
|binary data.                                 |
[--------------------------------------------]]

-- Remove position and content hints from a line of hexdump. After that, the
-- white-space is also removed.
local function remove_hints_and_ws(line)
    local no_pos_hint = line:gsub("^[^|]*|", "")
    local no_hint = no_pos_hint:gsub("|.*$", "")
    return no_hint:gsub("%s", "")
end

-- Ensure that a line of raw hexdump does not contains anything else than
-- hex digits and have a pairs of them. Should be applied to the output of
-- `remove_hints_and_ws`. Returns a string with an error message if any or nil.
local function check_good_raw_dh(line)
    local no_digits = line:gsub("[a-fA-F0-9]", "")
    if #no_digits ~= 0 then
        return "The line contains bad chars (non hex digits)."
    end
    if #line % 2 ~= 0 then
        return "The line contains an odd number of digits"
    end
    return nil
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


-- From a string of text, splits it into a table of each line of the text.
local function split_line(txt)
    local ret = {}
    local last_i = 1
    for i=1,#txt do
        if txt:sub(i,i) == "\n" then
            ret[#ret+1] = txt:sub(last_i, i-1)
            last_i = i+1
        end
    end
    if last_i <= #txt then
        ret[#ret+1] = txt:sub(last_i, #txt)
    elseif last_i == #txt + 1 then
        ret[#ret+1] = ""
    else
        error("Unexpected behavior in split_line")
    end
    return ret
end

local new_stream_binarize = function()
    local stream_bin = {}
    stream_bin.lines = {}
    stream_bin.old_line_end = ""
    stream_bin.finished = false

    stream_bin.check_finished = function(stream)
        if stream_bin.finished then
            error("Using a stream_bin that have already been finished")
        end
    end

    stream_bin.stream_dump = function(stream, dump)
        local lines = split_line(dump)
        for i=1,#lines do
            local err = stream:stream_line(lines[i])
            if err then
                return err
            end
        end
        return nil
    end

    stream_bin.stream_line = function(stream, line)
        stream:check_finished()
        local clean = remove_hints_and_ws(line)
        local err = check_good_raw_dh(clean)
        if err then
            return err
        end
        local raw = binarize_hd(clean)
        local lines = split_line(stream.old_line_end..raw)
        for i=1,(#lines-1) do
            stream.lines[#stream.lines+1] = lines[i]
        end
        stream.old_line_end = lines[#lines]
        return nil
    end

    stream_bin.finish = function(stream)
        stream:check_finished()
        stream.lines[#stream.lines+1] = stream.old_line_end
        stream.finished = true
    end

    return stream_bin
end

return new_stream_binarize

