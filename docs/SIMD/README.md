# SIMD在Ceph中的实现
## 关于工具：Jerasure Version 2.0
### 源代码地址：https://github.com/ceph/jerasure
### 简介：
&emsp;Jerasue这个库是由James S. Plank先生实现的，是一个实现纠删码的C语言仓库。并且，2.0版本在实现伽罗华域运算的后端时，采用了GF-Complete算法库，同时还采用了Intel SIMD指令集来加速RS编解码过程。
## 我们想做的
### Ceph纠删码实现中的SIMD加速
&emsp;目前只是在阅读Plank先生的代码，希望以后可以应用在ceph纠删码中。
<p align="right">作者：刘硕 </p>
