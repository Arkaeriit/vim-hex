let g:vim_hex_dir = expand('<sfile>:p:h')

function vim_hex#OpenHex()
    let l:lua_script = g:vim_hex_dir . "/vim_open_hex.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

function vim_hex#SaveHex()
    let l:lua_script = g:vim_hex_dir . "/vim_save_hex.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

