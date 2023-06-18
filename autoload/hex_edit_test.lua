#!/usr/bin/env lua

local hex_streamer = require("hex_stream")
local new_bin_streamer = require("bin_stream")

local arr = ""
for i=0,303 do
    arr = arr .. string.char(i % 256)
end


-- bin to hex
local hex_streamer = hex_streamer(300)
local buff = ""
for i=1,#arr do
    local new_lines = hex_streamer:process(arr:sub(i,i))
    for i=1,#new_lines do
        buff = buff .. new_lines[i] .. "\n"
    end
end
local new_lines = hex_streamer:finish()
for i=1,#new_lines do
    buff = buff .. new_lines[i] .. "\n"
end
print(buff)

-- hex to bin
local bin_streamer = new_bin_streamer()
local err = bin_streamer:stream_dump(buff)
if err then
    print(err)
end
bin_streamer:finish()
local arr_back = bin_streamer.lines[1]
for i=2,#bin_streamer.lines do
    arr_back = arr_back.."\n"..bin_streamer.lines[i]
end
if arr_back ~= arr then
    print(arr_back)
    print("---")
    print(arr)
end

