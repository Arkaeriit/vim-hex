#!/usr/bin/env python3

from hex_eddit import hd_buffer, binarize_buffer
import vim

def hd_vim_buffer():
    bin_buff = bytearray(vim.vars["vim_hex_global"])[0:-1]
    set_buf(hd_buffer(bin_buff))

def binarize_vim_buffer():
    hd_buff = bytearray(vim.vars["vim_hex_global"])
    set_buf(binarize_buffer(hd_buff))

def set_buf(s):
    del vim.current.buffer[:]
    delimiter = "\n"
    if isinstance(s, bytearray):
        delimiter = b"\n"
    for line in s.split(delimiter):
        if isinstance(s, str):
            line = line.encode("UTF-8")
        vim.current.buffer.append(bytes(line))
    del vim.current.buffer[0]
    del vim.current.buffer[len(vim.current.buffer)-1]

