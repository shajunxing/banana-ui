# An extremely simple minimal ISO C compatible cross-platform GUI infrastructure

# 一个极简极小的ISO C兼容的跨平台的图形用户界面基础架构

[Watch video](https://user-images.githubusercontent.com/1294264/227157679-5ae997e0-90c9-47d7-beae-6c2432c939d8.webm)

A minimalist ISO C compatible cross -platform graphical user interface infrastructure

The realization of computer engineering should be simple. For example, the graphic interface of many people talked about, the more deeper research. The more you feel, is it necessary to be so complicated? The main graphics interface is not the screen, mouse, and keyboard three ax? I like to come from scratch. If my energy allows me to even want to bite my CPU, my own programming language, my own compiler, and the next, use C language to define a set of minimum operations, including reading and writing pixels, including reading and writing pixels, including reading and writing pixels, including reading and writing pixels. The mouse keyboard event, corresponding to different software and hardware platforms, the minimum requirement is to implement these functions and compile them. Advanced, such as reading and writing pixels is too slow, so can I read and write wholeheartedly? No problem, these are called optional operations. The implementation is OK. It is not realized. I also have the default version of reading and writing pixels, and even if the mouse keyboard event is not needed, it can not be implemented. The pictures, fonts, windows, controls, input methods, etc. on the bottom layer are all written in C, or exported to the script language such as Lua.

Of course, the goal is very large. An extremely streamlined screen display/mouse/keyboard core, theoretically few code can be expanded to any platform. In order to improve performance and make most of the functional platforms, the mixed operations of the layer are all the layers of mixed operations are all. Use pure C code to operate in memory, and finally Flush to the device. Well, the graphics interface, software graphics interface, game, etc. of the operating system can all, such as implementing a set of common functions under Framebuffer, which can completely replace the Linux text interface, just like the previous dosshell.

At present, basic functions have been implemented in Windows GDI, Linux Framebuffer, and Xorg environment, including: pixels read and write on the screen; mouse events; custom rectangular areas (I call it "block"); pixel read and write; The alpha hybrid operation between the blocks; the block read and write of the screen; the wide -point formation such as the unifont is used, and the scope can be customized. If it contains the complete Plane 1 and 2 Image files; and export all the above functions to the LUA 5.1 environment.

The following functions are to be realized: Chinese input method; UI architecture similar to World of Warcraft in LUA 5.1; realize some Dosshell semi -graphical programs.

计算机工程实现应该是大道至简的，比如很多人津津乐道的Linux的图形界面，越深入研究，越感觉到，有必要搞那么复杂吗？图形界面主要不就是屏幕、鼠标、键盘三板斧？我喜欢从头来，如果精力能力允许我甚至都想撸自己的CPU、自己的编程语言、自己的编译器，退而求其次，就用C语言定义一组最小操作集合吧，包括读写像素，鼠标键盘事件，对应不同软硬件平台，最低要求是把这几个函数实现，就能编译通过。高级点的，比如读写像素太慢，那么能不能整块读写？没问题，这些叫可选操作，实现也行，不实现，我也有读写像素的默认版本，甚至鼠标键盘事件如果不需要也可以不实现。底层之上的图片、字体、窗口、控件、输入法等，统统用C写，或者导出到脚本语言比如Lua里写，怎么方便怎么来。

目标当然很远大，一个极度精简的屏显/鼠标/键盘的核，理论上极少的代码就能扩展到任意平台，为了提高性能以及让绝大部分功能平台无关，图层的混合操作都是用纯C代码在内存操作的，最后再flush到设备。用途嘛，操作系统的图形界面、软件的图形界面、游戏等，都可以，比如Framebuffer下实现一组常用的功能，完全可以替换Linux文本界面，就像以前Dosshell那样。

目前已经在Windows GDI、Linux Framebuffer、Xorg环境下实现了基本功能，包括：对屏幕的像素读写；鼠标事件；自定义矩形区域（我称之为“块”）；对块的像素读写；块之间的Alpha混合操作；对屏幕的块读写；内嵌Unifont等宽点阵字体，可定制范围，如果包含完整的Plane 1和2，那么编译后的尺寸大概2M左右；支持读TGA格式的图片文件；以及将以上所有功能导出到Lua 5.1环境。

以下功能待实现：中文输入法；在Lua 5.1下面实现类似魔兽世界的开放的UI架构；实现一些类似Dosshell的半图形程序。
