#include <lua.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <lualib.h>
#include <lauxlib.h>

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

static int process(lua_State* L){
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

static const struct luaL_Reg helper[] = {
    {"process", process},
    {NULL, NULL},
};

int luaopen_hex_stream_helper(lua_State *L) {
    luaL_newlib(L, helper);
    return 1;
}


