[Watch video](https://user-images.githubusercontent.com/1294264/227157679-5ae997e0-90c9-47d7-beae-6c2432c939d8.webm)

![test_luabanana_1](https://user-images.githubusercontent.com/1294264/227215277-10d72a0a-f65a-4d91-9745-f9e3f7e013ea.png)

![test_luabanana_2](https://user-images.githubusercontent.com/1294264/227215377-2ebc9a45-13ac-45bb-b34c-09c4b883461c.png)

![test_luabanana_3](https://user-images.githubusercontent.com/1294264/227215394-4d8ea91e-0760-4954-a35c-b85bdf7e4a69.png)

![test_luabanana_4](https://user-images.githubusercontent.com/1294264/227215420-dd02f425-8f55-4354-a08e-876cefff36b7.png)

![test_luabanana_6](https://user-images.githubusercontent.com/1294264/227215493-6852e626-a138-4d86-9d98-275e58641fbc.png)

![test_luabanana_7](https://user-images.githubusercontent.com/1294264/227215518-a2a3425f-9385-4899-b7ff-77c2175aae28.png)

# Banana UI：一个极简极小的ISO C兼容的跨平台的图形用户界面基础架构

计算机工程实现应该是大道至简的，比如很多人津津乐道的Linux的图形界面，越深入研究，越感觉到，有必要搞那么复杂吗？图形界面主要不就是屏幕、鼠标、键盘三板斧？我喜欢从头来，如果精力能力允许我甚至都想撸自己的CPU、自己的编程语言、自己的编译器，退而求其次，就用C语言定义一组最小操作集合吧，包括读写像素，鼠标键盘事件，对应不同软硬件平台，最低要求是把这几个函数实现，就能编译通过。高级点的，比如读写像素太慢，那么能不能整块读写？没问题，这些叫可选操作，实现也行，不实现，我也有读写像素的默认版本，甚至鼠标键盘事件如果不需要也可以不实现。底层之上的图片、字体、窗口、控件、输入法等，统统用C写，或者导出到脚本语言比如Lua里写，怎么方便怎么来。

目标当然很远大，一个极度精简的屏显/鼠标/键盘的核，理论上极少的代码就能扩展到任意平台，为了提高性能以及让绝大部分功能平台无关，图层的混合操作都是用纯C代码在内存操作的，最后再flush到设备。用途嘛，操作系统的图形界面、软件的图形界面、游戏等，都可以，比如Framebuffer下实现一组常用的功能，完全可以替换Linux文本界面，就像以前Dosshell那样。

目前已经在Windows GDI、Linux Framebuffer、Xorg环境下实现了基本功能，包括：对屏幕的像素读写；鼠标事件；自定义矩形区域（我称之为“块”）；对块的像素读写；块之间的Alpha混合操作；对屏幕的块读写；内嵌Unifont等宽点阵字体，可定制范围，如果包含完整的Plane 1和2，那么编译后的尺寸大概2M左右；支持读TGA格式的图片文件；以及将以上所有功能导出到Lua 5.1环境。以下功能待实现：中文输入法；在Lua 5.1下面实现类似魔兽世界的开放的UI架构；实现一些类似Dosshell的半图形程序。

源代码暂时不公开，以防止恶意Fork以及胡乱修改，等以后功能稳定了再说，有什么意见建议可以私聊。范例程序包括C语言和Lua的，命令行一般是这样的：“./xx <平台名> [[平台参数] ...]”，或者“./minlua xx.lua <平台名> [[平台参数] ...]”，minlua是去除了交互功能的Lua解释器，没有readline、curse等额外依赖。Linux下的平台名如果是“linux_xorg”，那么没有平台参数，如果是“linux_framebuffer”，那么需要指定的参数有framebuffer以及鼠标的设备文件名，比如：“./minlua test_luabanana_1.lua linux_framebuffer /dev/fb0 /dev/input/event2”，注意framebuffer是在控制台而非X Windows下面运行的，且用户需要有对应权限，最简单的方法是把用户加入video和input组。
