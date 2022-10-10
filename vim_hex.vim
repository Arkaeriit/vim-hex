
let g:vim_hex_dir = expand('<sfile>:p:h')

function OpenHex()
    echom "lol"
    echom "lol"
    let l:py_script = g:vim_hex_dir . "/vim_open_hex.py"
    let l:python_exec_cmd = 'py3file ' . l:py_script
    execute l:python_exec_cmd
endfunction

