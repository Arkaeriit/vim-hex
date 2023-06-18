#include <lua.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <lualib.h>
#include <lauxlib.h>

/* ------------------------------- Bin to hex ------------------------------- */

static void reduced_hd(char* dest, const char* src, size_t src_size) {
    char* d = dest;
    for (size_t i=0; i<src_size; i++) {
        d += sprintf(d, "%02hhx ", src[i]);
    }
    *d = 0;
}

static void show_byte_array(char* dest, const char* src, size_t src_size) {
    char* d = dest;
    for (size_t i=0; i<src_size; i++) {
        char s = src[i];
        if (s == 0x00) {
            d += sprintf(d, "␀");
        } else if (s <= 0x06) {
            d += sprintf(d, "○");
        } else if (s == 0x07) {
            d += sprintf(d, "⍾");
        } else if (s == 0x08) {
            d += sprintf(d, "⇤");
        } else if (s == 0x09) {
            d += sprintf(d, "⇥");
        } else if (s == 0x0A) {
            d += sprintf(d, "↵");
        } else if (s <= 0x0C) {
            d += sprintf(d, "○");
        } else if (s == 0x0D) {
            d += sprintf(d, "↵");
        } else if (s <= 0x1F) {
            d += sprintf(d, "○");
        } else if (s <= 0x7E) {
            *d++ = s;
        } else {
            d += sprintf(d, "·");
        }
    }
    *d = 0;
}

static inline int full_hd_buffer_size(int offset_size) {
    return 
        offset_size + // offset
        10 +          // decorations and 0
        (16 * 3) +    // Hexdump
        (16 * 4);     // content hint
}

static void full_hd(char* dest, int offset, int offset_size, const char* content) {
    char* d = dest;
    d += sprintf(d, "%0*x | ", offset_size, offset);
    reduced_hd(d, content, 16);
    d += 16 * 3;
    d += sprintf(d, "| ");
    show_byte_array(d, content, 16);
}

static int process_bin_to_hex(lua_State* L){
    int offset = luaL_checkinteger(L, 1);
    int offset_size = luaL_checkinteger(L, 2);
    const char* unprocessed_data = luaL_checkstring(L, 3);
    int data_size = luaL_len(L, 3);

    int number_of_lines = data_size / 16;
    lua_createtable(L, number_of_lines, 0);
    char* hd_buff = malloc(full_hd_buffer_size(offset_size) + 10000);
    hd_buff[full_hd_buffer_size(offset_size)-1] = 0;

    for (int i=0; i<number_of_lines; i++) {
        full_hd(hd_buff, offset + i, offset_size, unprocessed_data + (16 * i));
        lua_pushinteger(L, i+1);
        lua_pushstring(L, hd_buff);
        lua_rawset(L, -3);
    }

    char left_unprocessed[17] = {0};
    memcpy(left_unprocessed, unprocessed_data + (16 * number_of_lines), data_size - (16 * number_of_lines));
    lua_pushstring(L, left_unprocessed);

    free(hd_buff);

    return 2;
}

/* ------------------------------- Hex to bin ------------------------------- */

/*
 * Remove position and content hints from a line of hexdump. After that, the
 * white-space is also removed.
 */
static void remove_hints_and_ws(char* dest, const char* src) {
    // Removing position hint
    const char* no_pos_hint = src;
    for (size_t i=0; i<strlen(src); i++) {
        if (src[i] == '|') {
            no_pos_hint = src + i + 1;
            break;
        }
    }

    // Removing whitespace and stopping before content hint
    char* used_dest = dest;
    for (size_t i=0; i<strlen(no_pos_hint); i++) {
        char c = no_pos_hint[i];
        if (c == '|') {
            break;
        } else if (c == ' ' || c == '\t') {
            // Ignoring whitespace
        } else {
            *used_dest++ = c;
        }
    }
    *used_dest = 0;
}

/*
 * Ensure that a line of raw hexdump does not contains anything else than
 * hex digits and have a pairs of them. Should be applied to the output of
 * `remove_hints_and_ws`. Returns a string with an error message if any or NULL.
 */
const char* check_good_raw_df(const char* line) {
    for (size_t i=0; i<strlen(line); i++) {
        char c = line[i];
        if ('0' <= c && c <= '9' && 'a' <= c && c <= 'f' && 'A' <= c && c <= 'F') {
            return "The line contains bad chars (non hex digits).";
        }
    }
    if (strlen(line) % 2) {
        return "The line contains an odd number of digits";
    }
    return NULL;
}

/*
 * From a line of raw hexdump, returns a string of the binary value.
 */
static int binarize_hd(char* dest, const char* line) {
    char* d = dest;
    int ret = 0;
    for (size_t i=0; i<strlen(line)/2; i++) {
        char number[3] = {
            line[i*2],
            line[i*2+1],
            0};
        long converted = strtol(number, NULL, 16);
        *d++ = (char) (converted);
        ret++;
    }
    return ret;
}

static int process_hex_to_bin(lua_State* L) {
    const char* hex_line = luaL_checkstring(L, 1);
    const char* leftover_char = luaL_checkstring(L, 2);
    int leftover_len = luaL_len(L, 2);

    // Preparing binary buffer
    char tmp[strlen(hex_line)];
    remove_hints_and_ws(tmp, hex_line);
    const char* err = check_good_raw_df(tmp);
    char* converted_hd = malloc(strlen(hex_line) + leftover_len);
    memcpy(converted_hd, leftover_char, leftover_len);
    int converted_chars = binarize_hd(converted_hd + leftover_len, tmp);

    // Cutting the buffer in lines
    int ret_table_index = 1;
    lua_createtable(L, converted_chars+leftover_len, 0);
    char* str_start = converted_hd;
    for (int i=0; i<converted_chars+leftover_len; i++) {
        if (converted_hd[i] == '\n') {
            lua_pushinteger(L, ret_table_index);
            lua_pushlstring(L, str_start, converted_hd + i - str_start);
            lua_rawset(L, -3);
            str_start = converted_hd + i + 1;
            ret_table_index++;
        }
    }
    lua_pushinteger(L, ret_table_index);
    lua_pushlstring(L, str_start, converted_hd + converted_chars + leftover_len - str_start);
    lua_rawset(L, -3);

    // Pushing error message
    lua_pushstring(L, err);

    return 2;
}


/* ------------------------------ Lua interface ----------------------------- */

static const struct luaL_Reg helper[] = {
    {"process_bin_to_hex", process_bin_to_hex},
    {"process_hex_to_bin", process_hex_to_bin},
    {NULL, NULL},
};

int luaopen_stream_helper(lua_State *L) {
    luaL_newlib(L, helper);
    return 1;
}


