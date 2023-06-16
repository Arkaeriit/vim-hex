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
local new_streamer = require("hex_stream")
local streamer = new_streamer(300)
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

