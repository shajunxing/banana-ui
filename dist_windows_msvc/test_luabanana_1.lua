require "luabanana"

local zoom = 1
local screen_width, screen_height

local function draw()
    for x = 1, screen_width do
        for y = 1, screen_height do
            local color = x * y * zoom + 0xff000000
            banana_write_pixel_to_screen(color, x, y)
        end
    end
    banana_flush_whole_screen()
end

local function event_handler(event, ...)
    if event == BANANA_EVENT_SCREEN_SIZE_CHANGED then
        screen_width, screen_height = ...
        draw()
    elseif event == BANANA_EVENT_MOUSE_WHEEL then
        local delta = ...
        if delta == BANANA_MOUSE_WHEEL_UP then
            zoom = zoom / 1.99
        else
            zoom = zoom * 1.99
        end
        draw()
    elseif event == BANANA_EVENT_MOUSE_DOWN then
        local button = ...
        if button == BANANA_MOUSE_RIGHT_BUTTON then
            zoom = 1
            draw()
        end
    end
end

banana_initialize(event_handler, unpack(arg))
screen_width, screen_height = banana_get_screen_size()
draw()
banana_loop()
