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
        
## 项目简介
- 我们小组在咨询老师之后决定把分布式存储作为我们主要研究的目标，现阶段的想法可能还不是很成熟，项目简介也会持续不断更新
### 现有想法
基于Ceph，实现纠删码的使用和改进。具体的实现如下：
在分块数量固定、每块512字节的存储格式上，使用柯西编解码方式，利用SIMD指令集加速数据的计算，实现类APFS以增量方式修改和写数据的功能，最后在有条件的情况下考虑文件的分布存储位置优化问题，通过冷热数据分层为其分配不同比例的数据块和校验块，实现更好的容错机制，从而达到对可用性的要求。
## 小组成员介绍

张灏文

陈云开

毕超

刘硕

张铭哲

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
