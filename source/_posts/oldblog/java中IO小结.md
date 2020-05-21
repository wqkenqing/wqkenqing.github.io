---

title: java中IO小结
date: 2019-07-16
tags:

---

此处简介

<!--more-->

### java中IO小结
#### File
File类,相关api
* createNewFiles();
* mkdir();
* mkdirs()

---
### IO流
按方向，分输入，输出流in、out
流当中有缓冲区，即stream.read(),可以一次性读取stream.read(Byte[]byte);
针对缓冲流还有两个方法
mark与reset
markSupported 判断该输入流能支持mark 和 reset 方法。

mark用于标记当前位置；在读取一定数量的数据(小于readlimit的数据)后使用reset可以回到mark标记的位置。

FileInputStream不支持mark/reset操作；BufferedInputStream支持此操作；

mark(readlimit)的含义是在当前位置作一个标记，制定可以重新读取的最大字节数，也就是说你如果标记后读取的字节数大于readlimit，你就再也回不到回来的位置了。

通常InputStream的read()返回-1后，说明到达文件尾，不能再读取。除非使用了mark/reset。

#### 流的类型
+  FileInputStream
+  ObjectInputStream
+  DataInputStream
+  BufferedInputStream
+  BufferedReader
+  ByteArrayInputStream
+  CharArrayReader
+  Console
+  FileReader
+  PipedInputStream
+  PipedReader
+  PushbackInputStream
+  StringReader

| 流的名称  | 说明|
| :-------- | --------: |
| FileInputStream    | FileInputStream 从文件系统中的某个文件中获得输入字节。 |
| ObjectInputStream  | ObjectInputStream 对以前使用 ObjectOutputStream 写入的基本数据和对象进行反序列化。 |
| DataInputStream    | 数据输入流允许应用程序以与机器无关方式从底层输入流中读取基本 Java 数据类型。 |
| BufferedInputStream    | BufferedInputStream 为另一个输入流添加一些功能，即缓冲输入以及支持 mark 和 reset 方法的能力 |
| ByteArrayInputStream    | ByteArrayInputStream 包含一个内部缓冲区，该缓冲区包含从流中读取的字节。 |
| CharArrayReader    | 此类实现一个可用作字符输入流的字符缓冲区 |
| Console    | 此类包含多个方法，可访问与当前 Java 虚拟机关联的基于字符的控制台设备（如果有）。 |
| FileReader | 用来读取字符文件的便捷类 |
| PushbackInputStream | PushbackInputStream 为另一个输入流添加性能，即“推回 (push back)”或“取消读取 (unread)”一个字节的能力。 |
>Java I/O默认是不缓冲流的，所谓“缓冲”就是先把从流中得到的一块字节序列暂存在一个被称为buffer的内部字节数组里，然后你可以一下子取到这一整块的字节数据，没有缓冲的流只能一个字节一个字节读，效率孰高孰低一目了然。有两个特殊的输入流实现了缓冲功能，一个是我们常用的BufferedInputStream

---
#### 一些小结
**带array的流自带缓冲区。支持mark与reset方法**
**其他的要套缓冲流**

 存在readLine()方法的流

+ `BufferReader`

read(char[],0,len)的理解
将len从0位开始装入char[]中，然后通过String.valueOf(char[])转换成字符串