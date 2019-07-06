# ceph虚拟机搭建
## 创建虚拟机
在同一台机器上创建三台准备3台centos的主机。并且配置他们的ip地址

|    IP地址      | 主机名（Hostname)    |  作用  |  
| --------   | -----   | ---- |  
| 192.168.1.103       | admin-node     |  该主机用于管理，后续的ceph-deploy工具都在该主机上进行操作，同时作为监控节点    |  
| 192.168.1.104        | osd        |  osd节点    |  
| 192.168.1.105        |client-node    |  客服端，主要利用它挂载ceph集群提供的存储进行测试   |  
## 修改admin-node节点/etc/hosts文件，增加一下内容
|    IP地址      | 主机名（Hostname)    |
| --------   | -----:   |
| 192.168.1.103       | admin-node     |   
| 192.168.1.104        | osd        |  
| 192.168.1.105        |client-node    | 
## 修改用户权限
分别为3台主机存储创建用户ceph:(使用root权限，或者具有root权限)  
创建用户  
	sudo adduser -d /home/ceph -m ceph  
设置密码  
	sudo passwd ceph 
设置账户权限
	echo "ceph ALL=(root)NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ceph
	sudo chmod 0440 /etc/sudoers.d/ceph 
 
执行命令visudo修改suoders文件：
把Defaults    requiretty这一行修改为修改  Defaults：ceph  ！requiretty
如果不进行修改ceph-depoy利用ssh执行命令将会出错
## 配置admin-node与其他节点ssh无密码root权限访问其它节点。
第一步：在admin-node主机上执行命令：  
   
	ssh-keygen  
说明：（为了简单点命令执行时直接确定即可） 
第二步：将第一步的key复制至其他节点
   
	ssh-copy-id    ceph@osd
	ssh-copy-id   ceph@client-node
同时修改~/.ssh/config文件增加一下内容：
  
	host  admin-node
	hostname 192.168.1.103
	user  ceph
	 
	host    osd
	hostname   192.168.1.104
	user             ceph
	 
	host    client-node
	hostname   192.168.1.105
	user             ceph
## 为admin-node节点安装ceph-deploy
### 第一步：增加 yum配置文件
	sudo vim /etc/yum.repos.d/ceph.repo
添加以下内容：

	[ceph-noarch]
	name=Ceph noarch packages
	baseurl=http://ceph.com/rpm-firefly/el7/noarch
	enabled=1
	gpgcheck=1
	type=rpm-md
	gpgkey=https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc
 
 
第二步：更新软件源并按照ceph-deploy，时间同步软件

	sudo yum update && sudo yuminstall ceph-deploy
	sudo yum install ntp ntpupdate ntp-doc
 
 
 
4、关闭所有节点的防火墙以及安全选项(在所有节点上执行）以及其他一些步骤

	sudo systemctl   stopfirewall.service
	sudo  setenforce   0
	sudo yum install yum-plugin-priorities
 
总结：经过以上步骤前提条件都准备好了接下来真正部署ceph了。
 
 
5、以前面创建的ceph用户在admin-node节点上创建目录

	mkdir  my-cluster
	cd my-cluster
 
6、创建集群
 
节点关系示意图：admin-node作为监控节点，osd作为osd节点，admin-node作为管理节点，其关系如下图所示： 

![](./ceph搭建.png)

第一步：执行以下命令创建以admin-node为监控节点的集群。

	ceph-deploy   new  admin-node
执行该命令后将在当前目录生产ceph.conf文件，打开文件并增加一下内容：

	osd pool default size = 2
 
第二步：利用ceph-deploy为节点安装ceph
ceph-deploy  install admin-node  osd client-node
超时解决方法：

1、 每个节点执行安装ceph：yum –y install ceph

	执行yum -y install redhat-lsb #解决/etc/init.d/ceph:line 15: /lib/lsb/init-functions: No such file or directory问题
 
第三步：初始化监控节点并收集keyring：

	ceph-deploy mon create-initial
 
6、为存储节点osd进程分配磁盘空间：

	ssh osd
	sudo mkdir  /var/local/osd0
	exit
 
 
接下来通过admin-node节点的ceph-deploy开启其他节点osd进程，并激活。

	ceph-deploy osd prepareosd:/var/local/osd0
	ceph-deploy osd activateosd:/var/local/osd0
 
把admin-node节点的配置文件与keyring同步至其它节点：

	ceph-deploy admin admin-node osdclient-node
	sudo chmod +r/etc/ceph/ceph.client.admin.keyring
 
最后通过命令查看集群健康状态：

	ceph health
如果成功将提示：HEALTH_OK
 
