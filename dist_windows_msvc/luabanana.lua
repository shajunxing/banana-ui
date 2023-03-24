-- https://stackoverflow.com/questions/295052/how-can-i-determine-the-os-of-the-system-from-within-a-lua-script
local lib_name = "luabanana.so"
if package.config:sub(1, 1) == "\\" then
    lib_name = "luabanana.dll"
end

local function import_symbols(...)
    for i = 1, select("#", ...) do
        local name = select(i, ...)
        _G[name] = package.loadlib(lib_name, "lua_" .. name)
        print(string.format("%-34s %s", name, tostring(_G[name])))
    end
end

import_symbols(
    "banana_initialize",
    "banana_loop",
    "banana_get_screen_size",
    "banana_argb_to_color",
    "banana_color_to_argb",
    "banana_write_pixel_to_screen",
    "banana_flush_screen",
    "banana_flush_whole_screen",
    "banana_read_pixel_from_screen",
    "banana_fill_screen",
    "banana_fill_whole_screen",
    "banana_allocate_block",
    "banana_reallocate_block",
    "banana_free_block",
    "banana_write_pixel_to_block",
    "banana_read_pixel_from_block",
    "banana_write_block_to_screen",
    "banana_write_whole_block_to_screen",
    "banana_read_block_from_screen",
    "banana_fill_block",
    "banana_fill_whole_block",
    "banana_overlay_block_on_block",
    -- Unifont
    "banana_write_unichar_to",
    "banana_next_unichar",
    "banana_write_utf8string_to",
    -- TGA
    "banana_read_block_from_tgafile"
)

local function enum(...)
    for i = 1, select("#", ...) do
        _G[select(i, ...)] = i - 1
    end
end

enum(
    "BANANA_EVENT_SCREEN_SIZE_CHANGED",
    "BANANA_EVENT_MOUSE_MOVE",
    "BANANA_EVENT_MOUSE_DOWN",
    "BANANA_EVENT_MOUSE_UP",
    "BANANA_EVENT_MOUSE_WHEEL"
)

enum("BANANA_MOUSE_LEFT_BUTTON", "BANANA_MOUSE_RIGHT_BUTTON")

enum("BANANA_MOUSE_WHEEL_UP", "BANANA_MOUSE_WHEEL_DOWN")

enum("BANANA_BLENDING_MODE_REPLACE", "BANANA_BLENDING_MODE_NORMAL")
