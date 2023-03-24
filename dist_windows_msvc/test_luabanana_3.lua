require "luabanana"
-- require "unifont"

local f = io.open(arg[0], "rb")
local text = f:read("*a")
f:close()
local screen_width, screen_height

local function write()
    local bg, fg = 0xff003300, 0xff33ff66
    banana_fill_whole_screen(bg)
    local x, y = 0, 0
    -- for cp in extract_utf8str(text) do
    --     local w, h = get_unichar_size(cp)
    --     if x + w > screen_width then
    --         x, y = 0, y + h
    --     end
    --     if y + h > screen_height then
    --         break
    --     end
    --     write_unichar_to_screen(cp, bg, fg, x, y)
    --     x = x + w
    -- end
    for pos, cp in banana_next_unichar(text) do
        local w, h = banana_write_unichar_to(cp, bg, fg, nil, x, y)
        x = x + w
        if x > screen_width then
            x, y = 0, y + h
        end
        if y > screen_height then
            break
        end
    end
    banana_flush_whole_screen()
end

local function event_handler(event, ...)
    if event == BANANA_EVENT_SCREEN_SIZE_CHANGED then
        screen_width, screen_height = ...
        write()
    end
end

banana_initialize(event_handler, unpack(arg))
screen_width, screen_height = banana_get_screen_size()
write()
banana_loop()
