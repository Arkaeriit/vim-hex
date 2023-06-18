#!/usr/bin/env lua

local hex_edit = require("hex_edit")

local arr = ""
for i=0,303 do
    arr = arr .. string.char(i % 256)
end
local buff = hex_edit.hd_buffer(arr)
print(buff)
arr_back = hex_edit.binarize_buffer(buff)
if arr_back ~= arr then
    print(arr_back)
    print("---")
    print(arr)
end

-- compare the new stream implemenataion with the old one
local hex_streamer = require("hex_stream")
local streamer = hex_streamer(300)
local new_buff = ""
for i=1,#arr do
    local new_lines = streamer:process(arr:sub(i,i))
    for i=1,#new_lines do
        new_buff = new_buff .. new_lines[i] .. "\n"
    end
end
local new_lines = streamer:finish()
for i=1,#new_lines do
    new_buff = new_buff .. new_lines[i] .. "\n"
end
if new_buff ~= buff then
    print(new_buff)
    print("---")
    print(buff)
end

local new_bin_streamer = require("bin_stream")
local bin_streamer = new_bin_streamer()
local err = bin_streamer:stream_dump(new_buff)
if err then
    print(err)
end
bin_streamer:finish()

local new_arr_back = bin_streamer.lines[1]
for i=2,#bin_streamer.lines do
    new_arr_back = new_arr_back.."\n"..bin_streamer.lines[i]
end
if new_arr_back ~= arr_back then
    print(#new_arr_back, #arr_back)
    print("----")
    print(new_arr_back)
    print("<><><><>")
    print(arr_back)
    print("----")
end

