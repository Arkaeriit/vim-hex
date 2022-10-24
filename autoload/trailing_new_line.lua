-- Read all the content in a file. Aware of different Lua verison.
local function read_all(f)
    local major = tonumber(_VERSION:sub(5,5))
    local minor = tonumber(_VERSION:sub(7,7))
    if major > 5 or minor > 2 then
        return f:read("a")
    else
        return f:read("*a")
    end
end

-- Set b:vim_hex_trailing to 1 if the last char in b:vim_hex_filename is a new
-- line and false otherwise.
local f = io.open(vim.eval("b:vim_hex_filename"), "r")
local content = " "
if f then
    content = read_all(f)
    f:close()
end
local last_char = content:sub(#content)
if last_char == "\n" then
    vim.command("let b:vim_hex_trailing = 1")
else
    vim.command("let b:vim_hex_trailing = 0")
end

