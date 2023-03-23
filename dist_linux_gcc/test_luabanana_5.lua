require "luabanana"
require "unifont"

local screen_width, screen_height, numcols, numrows
local bg, fg = {[0] = 0xff333300, [1] = 0xff003333}, {[0] = 0xffcccc00, [1] = 0xff00cccc}
local start = 0
local background, tooltip, output
local tooltip_width, tooltip_height = 128, 32
local tooltip_left, tooltip_top
local mouse_x, mouse_y

local function update_background()
    numcols = math.floor(screen_width / 16)
    if numcols == 0 then
        return
    end
    numrows = math.floor(screen_height / 16)
    if numrows == 0 then
        return
    end
    banana_fill_whole_block(0xff000000, background)
    local cp = start
    for row = 0, numrows - 1 do
        for col = 0, numcols - 1 do
            local x, y = col * 16, row * 16
            local i = (col + row) % 2
            write_unichar_to_block(cp, bg[i], fg[i], background, x, y)
            cp = cp + 1
        end
    end
    banana_overlay_block_on_block(background, 0, 0, screen_width, screen_height, BANANA_BLENDING_MODE_REPLACE, output, 0, 0)
    banana_write_whole_block_to_screen(output, 0, 0)
    banana_flush_whole_screen()
end

local function event_handler(event, ...)
    if event == BANANA_EVENT_SCREEN_SIZE_CHANGED then
        screen_width, screen_height = ...
        banana_reallocate_block(background, screen_width, screen_height)
        banana_reallocate_block(output, screen_width, screen_height)
        update_background()
    elseif event == BANANA_EVENT_MOUSE_WHEEL then
        local delta = ...
        local i = numcols * math.ceil(numrows * 2 / 3)
        if delta == BANANA_MOUSE_WHEEL_UP then
            start = math.max(start - i, 0)
        else
            start = start + i
        end
        update_background()
    elseif event == BANANA_EVENT_MOUSE_DOWN then
        local button = ...
        if button == BANANA_MOUSE_RIGHT_BUTTON then
            start = 0
            update_background()
        end
    elseif event == BANANA_EVENT_MOUSE_MOVE then
        mouse_x, mouse_y = ...
        local dirty_left, dirty_top, dirty_width, dirty_height
        if tooltip_left and tooltip_top then
            -- 抹掉原先的
            banana_overlay_block_on_block(background, tooltip_left, tooltip_top, tooltip_width, tooltip_height, BANANA_BLENDING_MODE_REPLACE, output, tooltip_left, tooltip_top)
            dirty_left, dirty_top = tooltip_left, tooltip_top
        end
        tooltip_left, tooltip_top = mouse_x + 16, mouse_y + 16
        if tooltip_left + tooltip_width > screen_width then
            tooltip_left = mouse_x - tooltip_width - 16
        end
        if tooltip_top + tooltip_height > screen_height then
            tooltip_top = mouse_y - tooltip_height - 16
        end
        if dirty_left then
            dirty_width = tooltip_width + math.abs(tooltip_left - dirty_left)
            dirty_height = tooltip_height + math.abs(tooltip_top - dirty_top)
            dirty_left = math.min(dirty_left, tooltip_left)
            dirty_top = math.min(dirty_top, tooltip_top)
        else
            dirty_left, dirty_top, dirty_width, dirty_height = tooltip_left, tooltip_top, tooltip_width, tooltip_height
        end
        -- 绘制tooltip
        local tooltip_bg = 0xccff0000
        banana_fill_whole_block(tooltip_bg, tooltip)
        local col = math.floor(mouse_x / 16)
        local row = math.floor(mouse_y / 16)
        local cp = row * numcols + col + start
        write_utf8str_to_block(string.format("码点：%X", cp), tooltip_bg, 0xffffffff, tooltip, 8, 8)
        -- 叠加
        banana_overlay_block_on_block(tooltip, 0, 0, tooltip_width, tooltip_height, BANANA_BLENDING_MODE_NORMAL, output, tooltip_left, tooltip_top)
        -- 写屏
        banana_write_block_to_screen(output, dirty_left, dirty_top, dirty_width, dirty_height, dirty_left, dirty_top)
        banana_flush_screen(dirty_left, dirty_top, dirty_width, dirty_height)
    end
end

banana_initialize(event_handler, unpack(arg))
screen_width, screen_height = banana_get_screen_size()
background = banana_allocate_block(screen_width, screen_height)
output = banana_allocate_block(screen_width, screen_height)
tooltip = banana_allocate_block(tooltip_width, tooltip_height)
update_background()
banana_loop()
