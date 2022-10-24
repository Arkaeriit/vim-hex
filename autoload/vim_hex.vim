" Global used to import Lua libs
let g:vim_hex_dir = expand('<sfile>:p:h')

" Save the current buffer into a temporary variable
function vim_hex#BufferToVar()
    let l:tmp_z = @z
    normal myggVG"zy'y
    let b:vim_hex_buffer_copy = @z
    let @z = l:tmp_z
endfunction

function vim_hex#OpenHex()
    call vim_hex#BufferToVar()
    let l:lua_script = g:vim_hex_dir . "/vim_open_hex.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

function vim_hex#SaveHex()
    let l:lua_script = g:vim_hex_dir . "/vim_save_hex.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

