#ifndef BANANA_H
#define BANANA_H

#include <stdio.h>
#include <stdint.h>

#ifdef _MSC_VER
    #ifdef BANANA_LIB
        #define BANANA_API __declspec(dllexport)
    #else
        #define BANANA_API __declspec(dllimport)
    #endif
    #if _MSC_VER < 1900
        #define inline __inline
    #endif
#else
    #define BANANA_API extern
#endif

#define println(format, ...) printf(format "\n", ##__VA_ARGS__)

#ifdef BANANA_ENABLE_LOG
    #define BANANA_LOG(format, ...) printf("[LOG] %s(%d)%s: " format "\n", __FILE__, __LINE__, __FUNCTION__, ##__VA_ARGS__)
    #define BANANA_WARNING(format, ...) printf("[WARNING] %s(%d)%s: " format "\n", __FILE__, __LINE__, __FUNCTION__, ##__VA_ARGS__)
#else
    #define BANANA_LOG(format, ...) (void)0
    #define BANANA_WARNING(format, ...) (void)0
#endif

#define BANANA_ERROR(format, ...) fprintf(stderr, "[ERROR] %s(%d)%s: " format "\n", __FILE__, __LINE__, __FUNCTION__, ##__VA_ARGS__)

#define BANANA_MIN(x, y) (((x) < (y)) ? (x) : (y))
#define BANANA_MAX(x, y) (((x) > (y)) ? (x) : (y))
#define BANANA_BETWEEN(value, min, max) ((value) >= (min) && (value) < (max))
#define BANANA_ABS(x) (((x) > 0) ? (x) : -(x))

#define BANANA_SAFE_ALLOC(type, ptr, size)    \
    if (ptr) {                                \
        if ((size) > 0) {                     \
            ptr = (type)realloc(ptr, (size)); \
        } else {                              \
            free(ptr);                        \
            ptr = 0;                          \
        }                                     \
    } else {                                  \
        if ((size) > 0) {                     \
            ptr = (type)malloc((size));       \
        }                                     \
    }

#define BANANA_SAFE_FREE(ptr) \
    if (ptr) {                \
        free(ptr);            \
        ptr = 0;              \
    }

// 结构体字节对齐，用法:
// BANANA_PACKED_ALIGN_BEGIN
// typedef struct {
//     ...;
// } BANANA_PACKED_ALIGN ...;
// BANANA_PACKED_ALIGN_END
#ifdef _MSC_VER
    #define BANANA_PACKED_ALIGN_BEGIN __pragma(pack(push, 1))
    #define BANANA_PACKED_ALIGN_END __pragma(pack(pop))
    #define BANANA_PACKED_ALIGN
#endif
#ifdef __GNUC__
    #define BANANA_PACKED_ALIGN_BEGIN
    #define BANANA_PACKED_ALIGN_END
    #define BANANA_PACKED_ALIGN __attribute__((packed))
#endif

typedef enum {
    // 参数：int width, int height
    // 屏幕内容会尽最大可能保留，但是建议重新绘制
    // 初始化后不会发送，否则流程会紊乱，无屏幕尺寸->初始化过程中发送该事件但此时用户图形数据是空的->初始化之后再设置用户图形数据已经晚了
    BANANA_EVENT_SCREEN_SIZE_CHANGED,
    // 参数：int x, int y
    BANANA_EVENT_MOUSE_MOVE,
    // 参数：BANANA_MOUSE_BUTTON btn
    BANANA_EVENT_MOUSE_DOWN,
    // 参数：BANANA_MOUSE_BUTTON btn
    BANANA_EVENT_MOUSE_UP,
    // 参数：delta
    BANANA_EVENT_MOUSE_WHEEL,
} BANANA_EVENT;

typedef enum {
    BANANA_MOUSE_LEFT_BUTTON,
    BANANA_MOUSE_RIGHT_BUTTON,
} BANANA_MOUSE_BUTTON;

typedef enum {
    BANANA_MOUSE_WHEEL_UP,
    BANANA_MOUSE_WHEEL_DOWN,
} BANANA_MOUSE_WHEEL;

typedef void (*BANANA_EVENT_HANDLER)(BANANA_EVENT event, ...);
extern BANANA_EVENT_HANDLER banana_event_handler;
#define BANANA_SEND_EVENT(event, format, ...)          \
    if (banana_event_handler) {                        \
        BANANA_LOG(#event ": " format, ##__VA_ARGS__); \
        banana_event_handler(event, ##__VA_ARGS__);    \
    }
#define BANANA_SEND_EVENT_NO_LOG(event, format, ...) \
    if (banana_event_handler) {                      \
        banana_event_handler(event, ##__VA_ARGS__);  \
    }

BANANA_API int banana_initialize(BANANA_EVENT_HANDLER handler, int argc, char *argv[]);
extern int banana_initialize_windows_gdi(int argc, char *argv[]);
extern int banana_initialize_linux_framebuffer(int argc, char *argv[]);
extern int banana_initialize_linux_xorg(int argc, char *argv[]);
// 平台实现
// 平台实现的函数全部设置成指针，以便可以合并编译多个平台，否则函数的多个实现会冲突
BANANA_API int (*banana_loop)();
// 平台实现
// 宽高暂时不用size_t，因为最好要检查输入的负值，而不能让它自动转换为正值
BANANA_API int (*banana_get_screen_size)(int *width, int *height);

#define BANANA_ARGB_TO_COLOR(a, r, g, b) ((((uint32_t)a << 24) & 0xFF000000) | (((uint32_t)r << 16) & 0x00FF0000) | (((uint32_t)g << 8) & 0x0000FF00) | ((uint32_t)b & 0x000000FF))
#define BANANA_COLOR_TO_A(color) (unsigned char)(((uint32_t)color & 0xFF000000) >> 24)
#define BANANA_COLOR_TO_R(color) (unsigned char)(((uint32_t)color & 0x00FF0000) >> 16)
#define BANANA_COLOR_TO_G(color) (unsigned char)(((uint32_t)color & 0x0000FF00) >> 8)
#define BANANA_COLOR_TO_B(color) (unsigned char)((uint32_t)color & 0x000000FF)

#define BANANA_COORDINATE_IN_RANGE(x, y, left, top, width, height) (BANANA_BETWEEN((x), (left), (left) + (width)) && BANANA_BETWEEN((y), (top), (top) + (height)))

// 平台实现
// 0xAARRGGBB, alpha值如何用由各平台自行决定
// 像素可以立即显示，也可以在flush之后再统一显示
// 如果坐标超出边界，什么都不做，返回false
// 64位linux的long是64位，会导致block覆写后右侧黑边（多写了32位0x00000000），此处修正为int32_t，windows的stdint.h另外下载
BANANA_API int (*banana_write_pixel_to_screen)(uint32_t color, int x, int y);
// 平台实现
// 所以flush必须在最后调用，即便是个空函数
BANANA_API int (*banana_flush_screen)(int left, int top, int width, int height);
// 平台可选实现
BANANA_API int (*banana_flush_whole_screen)();
// 平台实现
// 如果坐标超出边界，color=0，返回false
BANANA_API int (*banana_read_pixel_from_screen)(int x, int y, uint32_t *color);
// 平台可选实现
BANANA_API int (*banana_fill_screen)(uint32_t color, int left, int top, int width, int height);
// 平台可选实现
BANANA_API int (*banana_fill_whole_screen)(uint32_t color);

typedef struct {
    // 宽高禁止直接修改
    int width;
    int height;
    uint32_t *pixels;
} BANANA_BLOCK;
#define BANANA_BLOCK_PIXEL(block, x, y) (block->pixels[(x) + block->width * (y)])
#define BANANA_COORDINATE_IN_BLOCK(x, y, block) BANANA_COORDINATE_IN_RANGE(x, y, 0, 0, block->width, block->height)

BANANA_API BANANA_BLOCK *banana_allocate_block(int width, int height);
BANANA_API int banana_reallocate_block(BANANA_BLOCK *block, int width, int height);
BANANA_API int banana_free_block(BANANA_BLOCK *block);
BANANA_API int banana_write_pixel_to_block(uint32_t color, BANANA_BLOCK *block, int x, int y);
BANANA_API int banana_read_pixel_from_block(BANANA_BLOCK *block, int x, int y, uint32_t *color);
// 平台可选实现
BANANA_API int (*banana_write_block_to_screen)(BANANA_BLOCK *block, int left, int top, int width, int height, int x, int y);
// 平台可选实现
BANANA_API int (*banana_write_whole_block_to_screen)(BANANA_BLOCK *block, int x, int y);
// 平台可选实现
BANANA_API BANANA_BLOCK *(*banana_read_block_from_screen)(int left, int top, int width, int height);
BANANA_API int banana_fill_block(uint32_t color, BANANA_BLOCK *block, int left, int top, int width, int height);
BANANA_API int banana_fill_whole_block(uint32_t color, BANANA_BLOCK *block);

typedef enum {
    BANANA_BLENDING_MODE_REPLACE,
    BANANA_BLENDING_MODE_NORMAL
} BANANA_BLENDING_MODE;

BANANA_API int banana_overlay_block_on_block(BANANA_BLOCK *from, int left, int top, int width, int height, int mode, BANANA_BLOCK *to, int x, int y);

// 内嵌Unifont，可定制范围
BANANA_API int banana_write_unichar_to(uint32_t codepoint, uint32_t *bgcolor, uint32_t color, BANANA_BLOCK *block, int x, int y, int *width, int *height);
BANANA_API int banana_next_unichar(char *utf8string, uint32_t length, uint32_t *position, uint32_t *codepoint);
BANANA_API int banana_write_utf8string_to(char *utf8string, uint32_t *bgcolor, uint32_t color, BANANA_BLOCK *block, int x, int y, int *width, int *height);

// 读TGA文件
BANANA_API BANANA_BLOCK *banana_read_block_from_tgafile(const char *filename);

#endif