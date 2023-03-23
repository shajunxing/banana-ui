require "luabanana"

local output, background, button
local screen_width, screen_height
local button_width, button_height = 150, 100
local button_left, button_top = 10, 10
local mouse_x, mouse_y, is_dragging

local function fill_style_1(block, width, height)
    local x, y, r, g, b, color
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            color = x * y + 0xff000000
            banana_write_pixel_to_block(color, block, x, y)
        end
    end
end

local function fill_style_2(block, width, height)
    local x, y, r, g, b, color
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            r = 255 * x / width
            g = 255 * y / height
            b = 0
            color = banana_argb_to_color(128, r, g, b)
            banana_write_pixel_to_block(color, block, x, y)
        end
    end
end

local function fill_style_3(block, width, height)
    local x, y, r, g, b, color
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            r = 255 * y / height
            g = 0
            b = 255 * x / width
            color = banana_argb_to_color(128, r, g, b)
            banana_write_pixel_to_block(color, block, x, y)
        end
    end
end

local function event_handler(event, ...)
    if event == BANANA_EVENT_SCREEN_SIZE_CHANGED then
        screen_width, screen_height = ...
        banana_reallocate_block(background, screen_width, screen_height)
        fill_style_1(background, screen_width, screen_height)
        banana_reallocate_block(output, screen_width, screen_height)
        banana_overlay_block_on_block(background, 0, 0, screen_width, screen_height, BANANA_BLENDING_MODE_REPLACE, output, 0, 0)
        banana_overlay_block_on_block(button, 0, 0, button_width, button_height, BANANA_BLENDING_MODE_NORMAL, output, button_left, button_top)
        banana_write_whole_block_to_screen(output, 0, 0)
        banana_flush_whole_screen()
    elseif event == BANANA_EVENT_MOUSE_MOVE then
        local x, y = ...
        if is_dragging then
            dx, dy = x - mouse_x, y - mouse_y
            left = math.min(button_left, button_left + dx)
            top = math.min(button_top, button_top + dy)
            width = button_width + math.abs(dx)
            height = button_height + math.abs(dy)
            button_left = button_left + dx
            button_top = button_top + dy
            banana_overlay_block_on_block(background, left, top, width, height, BANANA_BLENDING_MODE_REPLACE, output, left, top)
            banana_overlay_block_on_block(button, 0, 0, button_width, button_height, BANANA_BLENDING_MODE_NORMAL, output, button_left, button_top)
            banana_write_block_to_screen(output, left, top, width, height, left, top)
            banana_flush_screen(left, top, width, height)
        end
        mouse_x, mouse_y = x, y
    elseif event == BANANA_EVENT_MOUSE_DOWN then
        local b = ...
        if b == BANANA_MOUSE_LEFT_BUTTON and mouse_x >= button_left and mouse_x < (button_left + button_width) and mouse_y >= button_top and mouse_y < (button_top + button_height) then
            is_dragging = true
            fill_style_3(button, button_width, button_height)
            banana_overlay_block_on_block(background, button_left, button_top, button_width, button_height, BANANA_BLENDING_MODE_REPLACE, output, button_left, button_top)
            banana_overlay_block_on_block(button, 0, 0, button_width, button_height, BANANA_BLENDING_MODE_NORMAL, output, button_left, button_top)
            banana_write_block_to_screen(output, button_left, button_top, button_width, button_height, button_left, button_top)
            banana_flush_screen(button_left, button_top, button_width, button_height)
        end
    elseif event == BANANA_EVENT_MOUSE_UP then
        b = ...
        if b == BANANA_MOUSE_LEFT_BUTTON then
            is_dragging = false
            fill_style_2(button, button_width, button_height)
            banana_overlay_block_on_block(background, button_left, button_top, button_width, button_height, BANANA_BLENDING_MODE_REPLACE, output, button_left, button_top)
            banana_overlay_block_on_block(button, 0, 0, button_width, button_height, BANANA_BLENDING_MODE_NORMAL, output, button_left, button_top)
            banana_write_block_to_screen(output, button_left, button_top, button_width, button_height, button_left, button_top)
            banana_flush_screen(button_left, button_top, button_width, button_height)
        end
    end
end

banana_initialize(event_handler, unpack(arg))
screen_width, screen_height = banana_get_screen_size()
background = banana_allocate_block(screen_width, screen_height)
fill_style_1(background, screen_width, screen_height)
button = banana_allocate_block(button_width, button_height)
fill_style_2(button, button_width, button_height)
output = banana_allocate_block(screen_width, screen_height)
banana_overlay_block_on_block(background, 0, 0, screen_width, screen_height, BANANA_BLENDING_MODE_REPLACE, output, 0, 0)
banana_overlay_block_on_block(button, 0, 0, button_width, button_height, BANANA_BLENDING_MODE_NORMAL, output, button_left, button_top)
banana_write_whole_block_to_screen(output, 0, 0)
banana_flush_whole_screen()
banana_loop()
