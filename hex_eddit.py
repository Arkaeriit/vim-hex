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
import re

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
            ret += "⍾" # Not great
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
    offset_size = math.ceil(math.log(len(content), 16))
    if not isinstance(content, bytearray):
        raise TypeError("Input to hd_buffer should be a bytearray")
    ret = ""
    for i in range(math.ceil(len(content)/16)):
        ret += f"{full_hd(i * 16, offset_size, content[i*16:(i+1)*16])}\n"
    return ret

# ------------------------------- Hex to binary ------------------------------ #

def remove_hints_and_ws(line):
    """Remove position and content hints from a line of hexdump. After that, the
    whitespace is also removed."""
    no_pos_hint = re.sub(r"^[^|]*\|", "", line)
    no_hint = re.sub(r"\|.*$", "", no_pos_hint)
    return re.sub(r"\s", "", no_hint)

def check_good_raw_dh(line):
    """Ensure that a line of raw hexdump does not contains anything else than
    hex digits and have a pairs of them. Should be applied to the output of
    `remove_hints_and_ws`."""
    if re.sub(r"[a-fA-F0-9]", "", line) != "":
        raise ValueError("Input of check_good_raw_dh contains bad chars.")
    if len(line) % 2 != 0:
        raise ValueError("Input of check_good_raw_dh contains an odd number of digits")

def binarize_hd(line):
    """From a line of raw hexdump, returns a bytearray of the binary value."""
    ret = bytearray(b"")
    for i in range(int(len(line)/2)):
        byte = line[i*2:(i+1)*2]
        ret.append(int(byte, 16))
    return ret

def binarize_buffer(content):
    "Binarize a whole text of hexdump text."
    if isinstance(content, bytearray):
        content = decode(content, "UTF-8")
    if not isinstance(content, str):
        raise TypeError("Input of binarize_buffer should be a string or a bytearray")
    ret = bytearray(b"")
    for line in content.split("\n"):
        raw = remove_hints_and_ws(line)
        check_good_raw_dh(raw)
        ret += binarize_hd(raw)
    return ret

# ---------------------------------- Testing --------------------------------- #

if __name__ == "__main__":
    arr = []
    for i in range(300):
        arr.append(i % 256)
    buff = hd_buffer(bytearray(arr))
    print(buff)
    if bytearray(arr) != binarize_buffer(buff):
        print(bytearray(arr))
        print("---")
        print(binarize_buffer(buff))
        print("---")
        print("Ho no, convert back does not works...")

