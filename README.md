# OSH小组大作业

- [OSH小组大作业](#osh小组大作业)
    - [项目简介](#项目简介)
    - [小组成员介绍](#小组成员介绍)
    - [现有的成果](#现有的成果)
        - [小组讨论](#小组讨论)
        - [调研报告](#调研报告)
        - [可行报告](#可行报告)
        - [SIMD](#SIMD)
        - [ceph搭建](#ceph搭建)
        - [编码](#编码)
        - [ectest](#ectest)
        - [test](#test)
        - [日志](#日志)
        - [终期报告](#终期报告)
## 项目简介
在ceph的平台上对纠删码模块进行改进，使用柯西矩阵进行编码，使用intel的SIMD指令集机型矩阵计算的加速，对于数据进行增量的方式修改，对于不同的数据进行分层的管理，达到更好的容错性和可用性。我们会使用日志的方式达到分布式中的一致性和速度方面的提升。在项目的最后阶段，我们也会对我们实验内容的性能进行测试。
- 在老师和助教的不断交流中，我们也会不断进行修改和改进我们对项目的内容的理解。
## 小组成员介绍

张灏文： 组长，主要负责ceph的搭建，协调各种工作，还有各个阶段的报告的撰写，了解各方面的知识

陈云开： 主要负责编码方式的代码了解和ppt的制作。

毕超： 主要负责纠删码写入方式的了解和ppt的制作。

刘硕 ：主要负责SIMD方面的大妈了解，后续的测试代码和ceph相关知识的了解。

张铭哲 ： 主要负责ceph的搭建，后续的测试代码和ceph相关知识的了解。

## 现有的成果

### [小组讨论](https://github.com/OSH-2019/x-Distributed-System-based-on-ceph/tree/master/discussions)

### [调研报告](https://github.com/OSH-2019/x-Distributed-System-based-on-ceph/blob/master/docs/research.md)
### [可行报告](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph-/blob/master/docs/feasibility.md)

### [SIMD](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/SIMD)
### [ceph搭建](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/ceph%20install)
### [编码](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/interface_plugin)
### [ectest](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/ceph-erasure-code-test)
### [test](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/test)
### [日志](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/ceph日志)
### [终期报告](https://github.com/OSH-2019/x-Erasure-Code-Improvement-based-on-ceph/tree/master/docs/终期报告)
