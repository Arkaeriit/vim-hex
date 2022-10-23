#!/usr/bin/env lua

local hex_eddit = require("hex_eddit")

local arr = ""
for i=0,299 do
    arr = arr .. string.char(i % 256)
end
local buff = hex_eddit.hd_buffer(arr)
print(buff)

