#!/usr/bin/env python3

from hex_eddit import hd_buffer, binarize_buffer
import vim

def hd_vim_buffer():
    print(vim.current.buffer.options["ff"])
    bin_buff = strlist_to_bytearray(vim.current.buffer[:])
    print(type(bin_buff))
    set_buf(hd_buffer(bin_buff))

def binarize_vim_buffer():
    hd_buff = strlist_to_bytearray(vim.current.buffer)
    vim.current.buffer = binarize_buffer(hd_buff)

def strlist_to_bytearray(lst):
    ret = bytearray(b"")
    for line in lst:
        for c in line:
            try:
                # print(c)
                pass
            except UnicodeEncodeError:
                pass
            try:
                ret += c.encode("ASCII")
            except UnicodeEncodeError:
                try:
                    ret += c.encode("ISO-8859-15")
                except UnicodeEncodeError:
                    ret += b"\0"
                    print("Ho, no")
        ret += b"\n"
    return ret[0:-1]

def set_buf(s):
    del vim.current.buffer[:]
    for line in s.split("\n"):
        vim.current.buffer.append(line)
    del vim.current.buffer[0]
    del vim.current.buffer[len(vim.current.buffer)-1]

