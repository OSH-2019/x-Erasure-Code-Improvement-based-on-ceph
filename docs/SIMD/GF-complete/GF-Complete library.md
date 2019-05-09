# GF-Complete library

[TOC]

## 1.介绍：

​	这个库支持w≤32和w=64、128的伽罗华域上的单值乘除运算，也支持对w为任意值的两个字节区域的加法，支持在*GF(24), GF(28), GF(216), GF(232), GF(264) ,GF(2128)这些域上实现字节区域乘以常数。*

## 2.这个库的各个文件

### 2.1 头文件：

#### 2.1.1 gf_complete.h:

​	这个头文件是应用必须要加入的。这里面定义了gf_t，gf_t包括了在GF(2^w)上进行各种运算所需要的数据。同时，这个库定义了全部的算法操作类型。要想使用这个库，首先把这个库include到工程中，然后再和src/libgf_complete.la库一起编译。

#### 2.1.2 gf_method.h:	

​	如果想修改默认的执行设定，可以在unix命令行里使用这个文件提供的helper函数。

#### 2.1.3 gf_general.h:

​	这个文件有helper程序可以对任意合法的w值在相应的伽罗华域上做基本的伽罗华域计算。问题的关键是对于*w* ≤ 32, *w* = 64 和*w* = 128，这个库使用了三种不同的数据结构这是这个文件做的不好的地方，尽管已经尽量来弥补这种缺陷了。这三种分别是gf_mult,gf_unit和gf_time。但是大部分程序不会用这些，因为大多是只用w≤ 32。

#### 2.1.4 gf_rand.h:

​	srand48()和所有类似的函数都不被c的各种发型版本支持，因此这个文件定义了一些随机数的生成来帮助测试程序。这个随机数生成器叫做“mather of all”，这种方法没有任何专利问题。gf_unit和gf-time都用了这些随机数生成器。

#### 2.1.5 gf_int.h:

​	这是个许多源文件都会用到的内置头文件，这个不应该被其他工程所include。

#### 2.1.6 config.xx 和 stamp-h1:

​	这是被autoconf创建的文件，可以忽略。

### 2.2 “src”“directory”里面的源代码文件：

​	接下来这些c文件组成了gf_complete.a，并且在“src”“directory”目录下。

#### 2.2.1 gf_.c:

​	用来执行**gf_complete.h**和**gf_int.h**里面的所有程序。

#### 2.2.2 gf_w4(x).c:

​	特定地用来执行GF(2^4)（GF(2^x)）域上的算法。x=4,8,16,32,64,128；

#### 2.2.3 gf_wgen.c:	

​	特定地用来执行GF(2^w)域上的算法，其中，w在1和31之间。

#### 2.2.4 gf_general.c:

​	用来控制全局的变量值，无论w等于多少。（gf_general.h中定义的程序）	

#### 2.2.5 gf_rand.c:

​	"the mother of all"随机数生成器。（gf_rand.h中定义的程序）	

### 2.3 “tools”库里面的工具文件

​	下面的函数是用来帮助你了解伽罗华域算法和使用库函数的，他们在本手册的其他部分会被更详细地介绍。

#### 2.3.1 **gf_mult.c, gf_ div.c** and **gf_ add**：

​	这是用来做单数的乘除法和加法的命令行工具。

#### 2.3.2 **gf_time.c:**

​	一个用来对任意给定的w和运算操作的程序进行测试时间的程序。

#### 2.3.3 **time_tool.sh:**

​	一个用来对在GF-complete上进行各种乘除和字节区域计算的过程粗略计时的脚本。

#### 2.3.4 **gf_methods.c:** 

​	一个枚举GF-Complete支持的大多数实现方法的程序。

#### 2.3.5 **gf_poly.c:**

​	在常规和复合伽罗瓦域中识别不可约多项式的程序。

### 2.4 “test”库里面的测试单元：

#### 2.4.1 gf_unit.c：

​	后面再详细介绍 6.3

### 2.5 “examples”库里面的示例程序：

#### 2.5.1 gf_example x.c

​	有七个示例程序可以帮助您了解GF-Complete的各个方面。它们位于examples目录中的文件gf_example x.c中。4.2到4.5和7.9解释。

## 3 编译执行：

​	从修订版1.02开始，这个过程使用autoconf。旧的“flag tester”目录现已消失，因为它已不再使用。

​	要编译和安装，执行下面大多数开源Unix代码执行的标准操作：

```bash
./configure 
make 
sudo make install
```

​	如果执行安装，则头文件，源文件，工具和库文件将移动到系统位置。特别是，您可以通过链接标志-lgf_complete（？？？）来编译库，并且可以使用全局可执行目录（例如/ usr / local / bin）中的工具。如果不执行安装，则头文件和工具文件将位于各自的目录中，库将位于src / libgf_complete.la中。如果您的系统支持各种Intel SIMD指令，编译器将找到它们，GF-Complete将默认使用它们。

## 4 一些新手可以利用的工具和测试样例：

### 4.1 三种简单的命令行工具：gf_mult, gf_div and gf_add

​	在深入研究库之前，使用命令行工具探索Galois Field算法可能会有所帮助：gf_mult，gf_div和gf_add。它们对GF（2^w）中的元素执行乘法，除法和加法。如果系统上没有安装这些，那么可以在tools目录中找到它们。他们的语法是：

```c
gf_mult a b w // Multiplies a and b in GF(2w)
gf_div a b w // Divides a by b in GF(2w )
gf_add a b w // Adds a and b in GF(2w )
```

​	您可以使用1到32之间以及64、128之中的任何值。默认情况下，这些值以十进制形式读取和打印;但是，如果向w后面添加h，则a，b和结果将以十六进制打印。对于w = 128，'h'是必需的，所有值都将以十六进制打印。

​	下面是使用例子的结果展示：

```bash
UNIX> gf_mult 5 4 4 
7 
UNIX> gf_div 7 5 4 
4 
UNIX> gf_div 7 4 4 
5 
UNIX> gf_mult 8000 2 16h 
100b 
UNIX> gf_add f0f0f0f0f0f0f0f0 1313131313131313 64h 
e3e3e3e3e3e3e3e3 
UNIX> gf_mult f0f0f0f0f0f0f0f0 1313131313131313 64h 
8da08da08da08da0 
UNIX> gf_div 8da08da08da08da0 1313131313131313 64h 
f0f0f0f0f0f0f0f0 
UNIX> gf_add f0f0f0f0f0f0f0f01313131313131313 1313131313131313f0f0f0f0f0f0f0f0 128h 
e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3 
UNIX> gf_mult f0f0f0f0f0f0f0f01313131313131313 1313131313131313f0f0f0f0f0f0f0f0 128h 
786278627862784982d782d782d7816e 
UNIX> gf_div 786278627862784982d782d782d7816e f0f0f0f0f0f0f0f01313131313131313 128h 
1313131313131313f0f0f0f0f0f0f0f0 
UNIX> 
```

