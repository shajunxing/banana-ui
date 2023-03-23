#include <stdlib.h>
#include <stdarg.h>
#include <math.h>
#include "banana.h"

BANANA_BLOCK *output, *background, *button;
int button_left = 10, button_top = 10;
int mouse_x = -1, mouse_y = -1, is_dragging = 0;
// BANANA_BLOCK *cursor;
// int cursor_width = 32, cursor_height = 64;

static void fill_style_1(BANANA_BLOCK *block) {
    int x, y, r, g, b;
    uint32_t color;
    for (x = 0; x < block->width; x++) {
        for (y = 0; y < block->height; y++) {
            r = 0;
            g = 255 * x / block->width;
            b = 255 * y / block->height;
            color = BANANA_ARGB_TO_COLOR(255, r, g, b);
            banana_write_pixel_to_block(color, block, x, y);
        }
    }
}

static void fill_style_2(BANANA_BLOCK *block) {
    int x, y, r, g, b;
    uint32_t color;
    for (x = 0; x < block->width; x++) {
        for (y = 0; y < block->height; y++) {
            r = 255 * x / block->width;
            g = 255 * y / block->height;
            b = 0;
            color = BANANA_ARGB_TO_COLOR(255, r, g, b);
            banana_write_pixel_to_block(color, block, x, y);
        }
    }
}

static void fill_style_3(BANANA_BLOCK *block) {
    int x, y, r, g, b;
    uint32_t color;
    for (x = 0; x < block->width; x++) {
        for (y = 0; y < block->height; y++) {
            r = 255 * y / block->height;
            g = 0;
            b = 255 * x / block->width;
            color = BANANA_ARGB_TO_COLOR(255, r, g, b);
            banana_write_pixel_to_block(color, block, x, y);
        }
    }
}

static int dr_empty = 1;
static int dr_left;
static int dr_top;
static int dr_width;
static int dr_height;

static void reset_dirty_region() {
    dr_empty = 1;
}

static void expand_dirty_region(int left, int top, int width, int height) {
    int l, t, r, b;

    if (width < 0) {
        width = -width;
        left = left - width;
    }
    if (height < 0) {
        height = -height;
        top = top - height;
    }
    if (dr_empty) {
        dr_empty = 0;
        dr_left = left;
        dr_top = top;
        dr_width = width;
        dr_height = height;

    } else {
        l = BANANA_MIN(dr_left, left);
        t = BANANA_MIN(dr_top, top);
        r = BANANA_MAX(dr_left + dr_width, left + width);
        b = BANANA_MAX(dr_top + dr_height, top + height);
        // BANANA_LOG("dr_left= %d, dr_top= %d, dr_width= %d, dr_height= %d", dr_left, dr_top, dr_width, dr_height);
        // BANANA_LOG("left= %d, top= %d, width= %d, height= %d", left, top, width, height);
        // BANANA_LOG("l= %d, t= %d, r= %d, b= %d", l, t, r, b);
        dr_left = l;
        dr_top = t;
        dr_width = r - l;
        dr_height = b - t;
    }
}

static void event_handler(BANANA_EVENT event, ...) {
    va_list args;
    int w, h, x, y, b, dx, dy;
    // int left, top, width, height;

    switch (event) {
    case BANANA_EVENT_SCREEN_SIZE_CHANGED:
        va_start(args, event);
        w = va_arg(args, int);
        h = va_arg(args, int);
        va_end(args);
        banana_reallocate_block(background, w, h);
        fill_style_1(background);
        banana_write_whole_block_to_screen(background, 0, 0);
        banana_write_whole_block_to_screen(button, button_left, button_top);
        banana_flush_whole_screen();
        break;
    case BANANA_EVENT_MOUSE_MOVE:
        va_start(args, event);
        x = va_arg(args, int);
        y = va_arg(args, int);
        va_end(args);
        if (mouse_x != -1) {
            reset_dirty_region();
            if (is_dragging) {
                dx = x - mouse_x;
                dy = y - mouse_y;
                // 计算刷新区域
                expand_dirty_region(button_left, button_top, button->width, button->height);
                button_left += dx;
                button_top += dy;
                expand_dirty_region(button_left, button_top, button->width, button->height);
            }
            // expand_dirty_region(mouse_x, mouse_y, cursor->width, cursor->height);
            // expand_dirty_region(x, y, cursor->width, cursor->height);
            // 按顺序写屏
            banana_write_block_to_screen(background, dr_left, dr_top, dr_width, dr_height, dr_left, dr_top);
            banana_write_whole_block_to_screen(button, button_left, button_top);
            // banana_write_whole_block_to_screen(cursor, x, y);
            // 刷新
            banana_flush_screen(dr_left, dr_top, dr_width, dr_height);
        }
        mouse_x = x;
        mouse_y = y;
        break;
    case BANANA_EVENT_MOUSE_DOWN:
        va_start(args, event);
        b = va_arg(args, int);
        va_end(args);
        if (b == BANANA_MOUSE_LEFT_BUTTON && mouse_x >= button_left && mouse_x < (button_left + button->width) && mouse_y >= button_top && mouse_y < (button_top + button->height)) {
            is_dragging = 1;
            fill_style_3(button);
            banana_write_whole_block_to_screen(background, 0, 0);
            banana_write_whole_block_to_screen(button, button_left, button_top);
            banana_flush_screen(button_left, button_top, button->width, button->height);
        }
        break;
    case BANANA_EVENT_MOUSE_UP:
        va_start(args, event);
        b = va_arg(args, int);
        va_end(args);
        if (b == BANANA_MOUSE_LEFT_BUTTON) {
            is_dragging = 0;
            fill_style_2(button);
            banana_write_whole_block_to_screen(background, 0, 0);
            banana_write_whole_block_to_screen(button, button_left, button_top);
            banana_flush_screen(button_left, button_top, button->width, button->height);
        }
        break;
    default:
        break;
    }
}

int main(int argc, char *argv[]) {
    int w, h;
    // char *args[] = {
    //     "linux_framebuffer",
    //     "/dev/fb0",
    //     "/dev/input/event3"
    // };

    // banana_initialize(event_handler, 3, &args[0]);
    banana_initialize(event_handler, argc - 1, &argv[1]);
    banana_get_screen_size(&w, &h);
    BANANA_LOG("banana_get_screen_size= %d, %d", w, h);
    background = banana_allocate_block(w, h);
    fill_style_1(background);
    banana_write_whole_block_to_screen(background, 0, 0);
    button = banana_allocate_block(150, 100);
    fill_style_2(button);
    banana_write_whole_block_to_screen(button, button_left, button_top);
    banana_flush_whole_screen();
    // cursor = banana_allocate_block(cursor_width, cursor_height);
    // banana_fill_whole_block(0xffffffff, cursor);
    banana_loop();
    return 0;
}