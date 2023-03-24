require "luabanana"

local screen_width, screen_height, numcols, numrows

local function update_background()
    banana_fill_screen(0xff000099, 0, 0, screen_width, screen_height)
    banana_fill_screen(0xff000000, 0, 0, screen_width, 17)
    banana_fill_screen(0xff999999, 0, 0, screen_width, 16)
    banana_write_utf8string_to(" File ", 0xff000000, 0xff999999, nil, 32, 0)
    banana_fill_screen(0xff000000, 25, 17, 128, 128)
    banana_fill_screen(0xff999999, 24, 16, 128, 128)
    banana_write_utf8string_to(" New ", nil, 0xff000000, nil, 32, 32)
    banana_write_utf8string_to(" Open ", nil, 0xff000000, nil, 32, 48)
    banana_write_utf8string_to(" Save ", nil, 0xff000000, nil, 32, 64)
    banana_write_utf8string_to(" Save As      ", 0xff000000, 0xff999999, nil, 32, 80)
    banana_write_utf8string_to(" Exit ", nil, 0xff000000, nil, 32, 112)
    banana_flush_whole_screen()
end

local function event_handler(event, ...)
    if event == BANANA_EVENT_SCREEN_SIZE_CHANGED then
        screen_width, screen_height = ...
        update_background()
    end
end

banana_initialize(event_handler, unpack(arg))
screen_width, screen_height = banana_get_screen_size()
update_background()
banana_loop()
