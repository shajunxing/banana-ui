# Banana UI：一个极简极小的ISO C兼容的跨平台的图形用户界面基础架构

计算机工程实现应该是大道至简的，比如很多人津津乐道的Linux的图形界面，我越深入研究，越感觉厌烦，有必要搞那么复杂吗？图形界面主要不就是屏幕、鼠标、键盘三板斧？我想做自己喜欢的事情，把一切极简化，如果精力能力允许我甚至想设计自己的CPU、自己的编程语言、自己的编译器。那么根据我现在的能力，就用C语言定义一组最小操作集合吧，包括读写像素，鼠标键盘事件。对应不同软硬件平台，最低要求是把这几个函数实现，就能顺利编译运行。高级点的，比如读写像素太慢，那么能不能整块读写？没问题，这些是可选操作，即便不实现，我也有默认版本，甚至鼠标键盘事件如果不需要也可以不实现。底层之上的图片、字体、窗口、控件、输入法等，统统用C写，或者导出到脚本语言比如Lua里写，对每一件事情都选择最简洁的方法完成。

目标当然很远大，一个极度精简的屏显/鼠标/键盘的核，理论上极少的代码就能扩展到任意平台，为了提高性能以及让绝大部分功能平台无关，图层的混合操作都是用纯C代码在内存操作的，之后再flush到设备。谈到用途，操作系统的图形界面、软件的图形界面、游戏等都可以，比如Framebuffer下实现一组常用的功能，完全可以替换Linux文本界面，就像以前的DosShell那样。

目前已经在Windows GDI、Linux Framebuffer、X Window环境下实现了基本功能，包括：对屏幕的像素读写；鼠标事件；自定义矩形区域（我称之为“块”）；对块的像素读写；块之间的Alpha混合操作；对屏幕的块读写；内嵌Unifont等宽点阵字体，可定制范围，如果包含完整的Plane 1和2，那么编译后的尺寸大概2M左右；支持读TGA格式的图片文件；以及将以上所有功能导出到Lua 5.1环境。以下功能待实现：中文输入法；在Lua 5.1下面实现类似魔兽世界的开放的UI架构；实现一些类似Dosshell的半图形程序。

源代码暂时不公开，以防止恶意Fork以及胡乱修改，等以后功能稳定了再说，有什么意见建议可以私聊。范例程序包括C语言和Lua的，命令行一般是这样的：“./xx <平台名> [[平台参数] ...]”，或者“./minlua xx.lua <平台名> [[平台参数] ...]”，minlua是去除了交互功能的Lua解释器，没有readline、curse等额外依赖。Windows下的平台名是“windows_gdi”，没有平台参数，Linux下的平台名如果是“linux_xorg”，那么没有平台参数，如果是“linux_framebuffer”，那么需要指定的参数有framebuffer以及鼠标的设备文件名，比如：“./minlua test_luabanana_1.lua linux_framebuffer /dev/fb0 /dev/input/event2”，注意framebuffer是在控制台而非X Windows下面运行的，且用户需要有对应权限，最简单的方法是把用户加入video和input组。

绘图区域在该架构里称为“屏幕”，如果是framebuffer等无托管环境，那么就是整个屏幕；在Windows和X Windows下面使用单一窗口模拟“屏幕”，当然了，这也就天然适用于开发单窗口的应用程序了。至于在“屏幕”里面的所有内容，与Windows、X Window等不相干。

所有导出的函数参见banana.h，函数和变量名我习惯取自然语序的全名称，顾名思义很简单。程序的基本流程是：首先banana_initialize()初始化，参数需要指定事件回调函数（如不需要可置空）、平台名和平台参数，同上；然后是你自己的初始化工作，最后banana_loop()进入事件循环。事件回调函数响应屏幕、鼠标、键盘等事件，其中的BANANA_EVENT_SCREEN_SIZE_CHANGED意为屏幕尺寸发生变化，比如分辨率变化、Windows和X Windows下面窗口尺寸变化，此时程序需要重新绘制整个界面。Lua里的函数名一样，用法也类似。

其它说明详见源代码里的注释。