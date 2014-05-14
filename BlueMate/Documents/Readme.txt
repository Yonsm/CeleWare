一、如何编译？

  直接用最新的 Xcode 编译即开。

二、代码结构

  1. Classes 是此项目专用的实现代码

    1). Model 是数据模型实现

      DataLoader 是数据装载和解析的代码，负责所有业务数据的装载解析，和通用的错误处理（与服务端打交道的都在这里实现了）。

      PullDataLoader 是带下拉组件的数据装载器。

    2). View 项目专用的UI组件。

    3). Controller 是相关UI页面的实现。

        Base 目录中的 Conroller 是基类，派生结构如下：

          BaseController （页面基类，实现了页面统计等常规页面逻辑）
           |<-TableController （列表页面） 
           |    |<-PullTableController（下拉列表，支持数据装载器）
           |         |<-PagingTableController （带分页功能）
           |
           |<-WizardController （提供众多的快速添加UI元素的方法） 
                |<-AutoWizardController（自动隐藏键盘、键盘弹出隐藏时自动滚动界面到合适位置、自动下一个输入项）
                     |<-PullWizardController （支持下拉数据装载器）

        其它的页面 Controller 都派生自以上的其中一个 Controller。其中重复性条目多的页面可从 TableController 或其子类中继承；重复条目有限的页面可以从 WizardController或其子类继承，在 loadPage 中实现添加 UI 元素即可。

  2. Sources 是通用代码，不属于项目业务逻辑的一部分。此目录中的文件会定期归并整理，保持一份最新的实现。

    Main.mm 是程序入口，不需要修改。

    Prefix.pch 是整个项目的预编译头文件，引入了不常更改的头文件（Sources 中的头文件引入只要在此文件中打开注释即可，Classes 中的文件不需要直接引入相关头文件）。另外项目相关的全局宏定义也可以放在这个文件里。

    CelePrefix.pch 用于将当前项目编译到其他项目中时防止符号重复（Object C/C++ 不支持 namespace 真坑爹啊），可按需启用。

    Util

     NSUtil 基本的实用函数，大部分都是 static inline 的，用了 class 来包装（实际上是用来区别命名空间，只是没有直接用 namespace 而已）这些功能需要 Object C++ 特性支持，使用 .mm 为扩展名才能使用其中的函数。

     UIUtil 是 UI 相关的实用函数，和 NSUtil 类似。
  
    其它部分相关代码描述待续……

  3. Resources 是项目资源（非代码的部分）：

    1). 信息文件：Info.plist

    2). 程序图标：Icon*.png

    3). 启动画面：Default*.png

    4). 语言字符串文件：*.string

        另有一个 GenString 小程序，可以自动从所有源代码中提取语言字符串，生成英文、简体中文、繁体中文的语言文件，请在代码中使用 NSLocalizedStrin(English，中文) 来标记语言字符串）

    5). 程序内用到的资产文件；

        所有程序内用到的非特定命名的资源文件的放在这个目录中，比如图片或其他程序用到的资源，只要直接在 Finder 中放入次文件夹即可，不需要在 Xcode 中添加了。

        代码中使用 UIUtil::Image(图片名) 来使用图片文件（其中图片只需要提供 @2x 即可，自动能支持非 retina 的）；非图片文件使用 NSUtil::AssetPath(文件名) 来获取文件路径。

  4. Documents 是程序文档

    Xcode 仲可以直接看到，带不会编译到最终结果中。

  5. Frameworks

  6. Products


