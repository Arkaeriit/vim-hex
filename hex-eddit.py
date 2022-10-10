#!/usr/bin/env python3

doc = """
This file contains function to read a binary data into readable hexdump format
and it can also write back hexdumps into binary data.

The format is the following:

Offset hint | 16 bytes of content | txt hint

When writing back, only the content if used. The offset and txt views are only
hints.
"""

import math

# ------------------------------ Dumping to hex ------------------------------ #

def full_hd(offset, offset_size, content):
    """Return a string of hexdumped value. The offset is used for the hint and
    should be an integer. The content should be a bytearray of at most 16 bytes.
    Offset_size is an int telling the number of ex digits in offset.
    """
    if not isinstance(offset, int) and not isinstance(offset_size, int) and not isinstance(content, bytearray):
        raise TypeError("Invalid input type for hd")
    if len(content) > 16:
        raise ValueError("Too many bytes in content")
    offset_fmt = f"0{offset_size}x"
    return f"{offset:{offset_fmt}} | {pad_left(reduced_hd(content), 16 * 3 - 1)} | {show_byte_array(content)}"
    
def reduced_hd(content):
    "Serialize a bytearray in a succesion of bytes separated by spaces"
    ret = ""
    for byte in content:
        ret = ret + f"{byte:02x} "
    return ret[0:-1]

def show_byte_array(content):
    "From a bytearray, return a string that shows its content."
    ret = ""
    for byte in content:
        if byte == 0:
            ret += "␀"
        elif byte <= 0x6:
            ret += "○"
        elif byte == 0x7:
            ret += "🕭" # Not great
        elif byte == 0x8:
            ret += "⇤"
        elif byte == 0x9:
            ret += "⇥"
        elif byte == 0xA:
            ret += "↵"
        elif byte <= 0xC:
            ret += "○"
        elif byte == 0xD:
            ret += "↵"
        elif byte <= 0x1F:
            ret += "○"
        elif byte <= 0x7E:
            ret += chr(byte)
        else:
            ret += "·"
    return ret

def pad_left(s, size):
    "Add spaces to s until of the right size."
    while len(s) < size:
        s += " "
    return s

def hd_buffer(content):
    "Cut the buffer in 16 bytes chunks and hd them all."
    offset_size = math.ceil(math.log2(len(content)))
    ret = ""
    for i in range(math.ceil(len(content)/16)):
        ret += f"{full_hd(i * 16, offset_size, content[i*16:(i+1)*16])}\n"
    return ret

# ---------------------------------- Testing --------------------------------- #

if __name__ == "__main__":
    arr = []
    for i in range(300):
        arr.append(i % 256)
    print(hd_buffer(bytearray(arr)))

