" Global used to import Lua libs
let g:vim_hex_dir = expand('<sfile>:p:h')

function vim_hex#OpenHex()
    set nofixendofline
    set noeol
    call vim_hex#Auto()
    let b:vim_hex_filename = expand('%')
    call vim_hex#safekeeping("raw")
    call vim_hex#UpdateTrailing()
    let l:lua_script = g:vim_hex_dir . "/vim_open_hex.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

function vim_hex#SaveHex()
    let l:lua_script = g:vim_hex_dir . "/vim_save_hex.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

" Must be ran once when the file is opened for the first time.
" Used to tell how to handle any trailing new lines in the file.
function vim_hex#UpdateTrailing()
    let l:lua_script = g:vim_hex_dir . "/trailing_new_line.lua"
    let l:lua_exec_cmd = 'luafile ' . l:lua_script
    execute l:lua_exec_cmd
endfunction

" Generates non essential autocmds
function vim_hex#Auto()
    let b:vim_hex_error = 0 " Variable set to 1 one a file cannot be modified
    augroup VimHexAutoloaded
      au!
      au BufWritePost,FileWritePost * if &bin | call vim_hex#SaveHex() | endif
      au CmdlineLeave * if &bin | if b:vim_hex_error == 1 | set mod | endif | endif
    augroup END
endfunction

" Makes a copy of the text in a safekeeping variable
let b:vim_hex_buffer_copy_dic = {}
function vim_hex#safekeeping(key)
    let l:reg_save=@a
    silent normal ggVG"ay
    let b:vim_hex_buffer_copy_dic[a:key]=@a
    let @a=l:reg_save
endfunction

" Restore the buffer to the copy in the safekeeping variable
function vim_hex#restore(key)
    let l:reg_save=@a
    let @a=b:vim_hex_buffer_copy_dic[a:key]
    silent normal ggdG"apggdd
    let @a=l:reg_save
endfunction

