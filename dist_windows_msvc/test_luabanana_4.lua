require "luabanana"
-- require "unifont"

--[[
    恭喜发财
    やめて
    😀🤣😅😊😍😁😃😆😋😘😂😄😉😎🥰👌👍👎
    🈹🈶🈚🈺🈷🈸🆚🉑🉐㊙㊗🈴🈵🈲🅰🅱🆎🆑🅾🆘
    🚫🔇🔕🚭🚷🚯🚳🚱🔞📵💯❓❗🕳
]]
local lines = {}
local numlines = 0
for l in io.lines(arg[0]) do
    table.insert(lines, l)
    numlines = numlines + 1
end

local screen_width, screen_height
local start = 1

local function fg(cp)
    if
        (cp >= 0x21 and cp <= 0x2f) or (cp >= 0x3a and cp <= 0x40) or (cp >= 0x5b and cp <= 0x60) or
            (cp >= 0x7b and cp <= 0x7e)
     then
        return 0xff00ff00
    elseif cp >= 0x30 and cp <= 0x39 then
        return 0xffffff00
    elseif cp > 0xffff then
        return 0xffff0000
    else
        return 0xff999999
    end
end

local function write()
    local bg = 0xff000033
    banana_fill_whole_screen(bg)
    local y = 0
    -- for i = start, numlines do
    --     local line = lines[i]
    --     local x = 0
    --     for cp in extract_utf8str(line) do
    --         local w = write_unichar_to_screen(cp, bg, fg(cp), x, y)
    --         x = x + w
    --         if x > screen_width then
    --             break
    --         end
    --     end
    --     i = i + 1
    --     y = y + 16
    --     if y > screen_height then
    --         break
    --     end
    -- end
    for i = start, numlines do
        local line = lines[i]
        local x = 0
        for pos, cp in banana_next_unichar(line) do
            local w, h = banana_write_unichar_to(cp, bg, fg(cp), nil, x, y)
            x = x + w
            if x > screen_width then
                break
            end
        end
        i = i + 1
        y = y + 16
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
    elseif event == BANANA_EVENT_MOUSE_WHEEL then
        local delta = ...
        if delta == BANANA_MOUSE_WHEEL_UP then
            start = math.max(start - 6, 1)
        else
            start = math.min(start + 6, numlines)
        end
        write()
    end
end

banana_initialize(event_handler, unpack(arg))
screen_width, screen_height = banana_get_screen_size()
write()
banana_loop()
