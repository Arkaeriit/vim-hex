#!/usr/bin/env lua

local hex_edit = require("hex_edit")

local arr = ""
for i=0,299 do
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

