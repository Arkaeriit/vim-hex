
let g:vim_hex_dir = expand('<sfile>:p:h')

function BufferToGlobal()
    normal myggVG"zy'y
    let g:vim_hex_global = @z
endfunction

function OpenHex()
    call BufferToGlobal()
    let l:py_script = g:vim_hex_dir . "/vim_open_hex.py"
    let l:python_exec_cmd = 'py3file ' . l:py_script
    execute l:python_exec_cmd
endfunction

function SaveHex()
    call BufferToGlobal()
    let l:py_script = g:vim_hex_dir . "/vim_save_hex.py"
    let l:python_exec_cmd = 'py3file ' . l:py_script
    execute l:python_exec_cmd
endfunction
