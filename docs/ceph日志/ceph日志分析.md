# ceph日志代码和分析
## 重要的工具类
### 日志模式

FileStore可以采用不同的日志模式。各种日志模式的不同之处在于：何时记录日志？何时通知？何时写入到磁盘？常用的日志模式是：writeback（ext4、xfs）以及parallel（btrfs）。其他的日志模式还有：No journal（不鼓励使用），Trailing（文档引述：废弃，不要使用）。

### No Journal

没有日志的情况下，IO事务会被立刻调度。在sync调用后，会触发oncommit回调。因此，当FileStore执行sync的时候，会触发大量的回调通知。
### Writeahead

先将事务记录到日志，日志提交后，才会将事务提交到应用队列，并触发回调函数通知客户端写入完成。这种模式是为像XFS和ext4之类写就绪文件系统准备的。在一个磁盘文件中存储了日志重做序列号commit_op_seq。该序列号在每次同步后都会递增，重放日志将从这个序列号标识的操作往后进行。
### Parallel

日志与事务调度同时执行。这种模式是为Btrfs这类写时复制文件系统而设计。它们提供了稳定的快照回滚机制。执行日志重做时，当前的脏文件系统会被回滚到前一个快照。快照加上日志会将文件系统恢复到一个一致性状态。
### Trailing


这种模式已经废弃，它先执行事务再提交日志。  

### 默认模式

下面的代码段摘自os/FileStore.cc：  

	// select journal mode?
	if (journal) {
 	   if (!m_filestore_journal_writeahead &&
        !m_filestore_journal_parallel &&
 	  	     !m_filestore_journal_trailing) {
   	     if (!backend->can_checkpoint()) {
         	   m_filestore_journal_writeahead = true;
       	     dout(0) << "mount: enabling WRITEAHEAD journal mode: checkpoint is not enabled" << dendl;
       	 } else {
           m_filestore_journal_parallel = true;
           dout(0) << "mount: enabling PARALLEL journal mode: fs, checkpoint is enabled" << dendl;
     	   }
   	} else {
       if (m_filestore_journal_writeahead)
          	 dout(0) << "mount: WRITEAHEAD journal mode explicitly enabled in conf" << dendl;
       if (m_filestore_journal_parallel)
          	 dout(0) << "mount: PARALLEL journal mode explicitly enabled in conf" << dendl;
       	if (m_filestore_journal_trailing)
       	   	 dout(0) << "mount: TRAILING journal mode explicitly enabled in conf" << dendl;
   	}
    	if (m_filestore_journal_writeahead)
       journal->set_wait_on_full(true);
	} else {
 	   dout(0) << "mount: no journal" << dendl;
	}

如果后端文件系统（backend）支持检查点，就采用Parallel模式。否则就是Writeahead模式。Trailing模式和No Journal模式需要在配置文件中直接设置。  

事务：应用/日志

事务通过os/FileStore.cc中实现的FileStore::queue_transactions接口进入到FileStore。该方法基于不同的日志模式处理事务。事务包含三种类型的回调指针。在事务被处理后，FileStore及日志会调用它们。在整个代码库中，它们的名称不总是一样。但它们的常用名称及含义如下表所示：    
通常oncommit/ondisk在事务提交到日志后被调用，在No Journal模式中是一个例外，它在同步磁盘数据后被调用。    
两组onapplied/onreadable回调的区别在于FileStore调用它们的方式。事务处理线程执行事务后立即调用同步onapplied_sync/onreadable_sync回调，并将异步onapplied/onreadable投递到finisher服务线程。
事务在Trailing模式下是另一个例外，它不在线程池中执行，而是首先调用_do_op,然后调用      _finish_op,onreadable回调在_finish_op中被调用。   

Parallel及Writeahead    

	if (journal && journal->is_writeable() && !m_filestore_journal_trailing) {
  	  	Op *o = build_op(tls, onreadable, onreadable_sync, osd_op);
  	  	op_queue_reserve_throttle(o, handle);
    	journal->throttle();
    	uint64_t op_num = submit_manager.op_submit_start();
    	o->op = op_num;
    if (m_filestore_do_dump)
        dump_transactions(o->tls, o->op, osr);
    if (m_filestore_journal_parallel) {
        dout(5) << "queue_transactions (parallel) " << o->op << " " << o->tls << dendl;
        _op_journal_transactions(o->tls, o->op, ondisk, osd_op);
        // queue inside submit_manager op submission lock
        queue_op(osr, o);
    } else if (m_filestore_journal_writeahead) {
        dout(5) << "queue_transactions (writeahead) " << o->op << " " << o->tls << dendl;
        osr->queue_journal(o->op);
        _op_journal_transactions(o->tls, o->op,
                           new C_JournaledAhead(this, osr, o, ondisk),
                           osd_op);
    } else {
        assert(0);
    }
    submit_manager.op_submit_finish(op_num);
    return 0;
	}	
 

### Parallel

先将事务放入日志队列，然后将磁盘IO操作放入另一个队列。

### Writeahead

用C_JournaledAhead封装ondisk回调。新的ondisk通过queue_op加入队列，原先的ondisk回调在之后被处理。

### No Journal

	if (!journal) {
	    Op *o = build_op(tls, onreadable, onreadable_sync, osd_op);
	    dout(5) << __func__ << " (no journal) " << o << " " << tls << dendl;
	    op_queue_reserve_throttle(o, handle);
	    uint64_t op_num = submit_manager.op_submit_start();
	    o->op = op_num;
	    if (m_filestore_do_dump)
	        dump_transactions(o->tls, o->op, osr);
	    queue_op(osr, o);
	    if (ondisk)
	        apply_manager.add_waiter(op_num, ondisk);
	    submit_manager.op_submit_finish(op_num);
	    return 0;
	}
No Journal模式与上面两种模式相似，不同之处在于ondisk回调的处理方式。由于没有使用日志，要等到磁盘同步完成后事务才被看成是提交的。apply_manager.add_waiter(op_num, ondisk)就是用来干这个事。磁盘同步完成后ApplyManager会调用队列中的waiters。

### Trailing

	uint64_t op = submit_manager.op_submit_start();
	dout(5) << "queue_transactions (trailing journal) " << op << " " << tls << dendl;
	if (m_filestore_do_dump)
	    dump_transactions(tls, op, osr);
	apply_manager.op_apply_start(op);
	int r = do_transactions(tls, op);
	if (r >= 0) {
	    _op_journal_transactions(tls, op, ondisk, osd_op);
	} else {
	    delete ondisk;
	}
	// start on_readable finisher after we queue journal item, as on_readable callback
	// is allowed to delete the Transaction
	if (onreadable_sync) {
	    onreadable_sync->complete(r);
	}
	op_finisher.queue(onreadable, r);
	submit_manager.op_submit_finish(op);
	apply_manager.op_apply_finish(op);
	return r;
Trailing模式与其他模式有很大的不同，事务没有在线程池中执行，而是在当前线程中执行。事务完成后才提交到日志。最后会触发onreadable回调，在其他模式中该操作由sync_entry完成。
比与其他模式的明显区别更有意思的是，这种模式下事务的执行代码十分的简洁。例如调用submit_manager和apply_manager以及由finisher完成回调。

## 写日志

通过FileStore::submit_entry方法将日志项添加到日志。日志项首先被添加到FileJournal的writeq队列。除了IO数据外，oncommit回调被添加到另外一个队列并在日志完成时调用。日志的磁盘数据结构请查看后文的磁盘数据结构一节。
日志操作由一个独立的线程完成。线程函数是 FileJournal::write_thread_entry，它是一个循环。基于libaio的支持情况，最终的写操作由 do_write或者 do_aio_write完成。
尽管如此，在日志完成后还需要更新日志文件超级快中的journaled_seq并由finisher线程负责完成oncommit回调。
日志文件以 O_DIRECT及 O_DSYNC选项打开（Linux Man Page:open(2)）。

### FileStore 同步

同步在FileStore::sync_entry()中实现。它运行在一个独立的线程中并等待在条件变量sync_cond上。同步完成后，磁盘或者快照中的 committed_op_seq与日志中的 committed_up_to就一致。同步时，首先从ApplyManager获得需要同步的序列号。具体的同步与文件系统相关。如果文件系统支持检查点：（可以回头看看并行模式）

### 创建检查点
#### 同步检查点
写序列号到快照

否则调用fssync同步整个文件系统，如果文件系统支持sync就调用它同步。之后记录序列号。最后通过ApplyManager通知日志清除已经同步的日志项[译者注：事实上由于日志是循环使用的，类似于循环链表，只需移动头指针即可]。

#### 同步间隔

同步是周期性的，由事务或者日志满事件触发[译者注：事实上是日志半满，参见FileJournal::check_for_full]。同步间隔通过 filestore max sync interval及 filestore min sync interval配置。默认值分别是5s及0.01s。Ceph's documentation中对同步间隔的描述如下：
周期性地，FileStore需要停止写入并同步文件系统，以创建一致的提交点。之后才能释放提交点之前的日志项。同步得越频繁，同步所需要的时间就越短同时留在日志文件中的数据也就越少。同步得越不频繁，后端的文件系统就能够更好的聚合小IO写及优化元数据更新，可能带来更好的同步效率。

#### 日志刷新

日志刷新与FileStore同步是等效的。通过 FileJournal::committed_thru(uint64_t seq)方法通知日志刷新。seq参数需要大于上次的提交序列号。基于日志文件头中的start指针及序列号来丢弃老的日志项。如果支持TRIM，磁盘块数据也会被丢弃。

#### 日志重做

非常直观。日志重做在 JournalingObjectStore::journal_replay中实现。
总之：

#### 打开日志文件
- 读出日志项  
- 解析出事务  
- 将事务传递到 do_transactions中执行  

Mount调用中发起的日志重做是OSD初始化的一部分。如果文件系统支持检查点，它会将OSD回滚到最后一个一致性检查点。

#### 磁盘数据结构

在这一节，我将描述日志的数据结构。

## 日志


flags 只定义了一个标志：FLAG_CRC。每个新OSD的默认值。
fsid Ceph FSID
block_size 通常与页大小一致
alignment 通常与block_size一致
max_size 按block_size对齐的日志文件最大大小
start 第一个日志项的起始偏移
committed_up_to 已提交的最大日志序列号（该序列号之前的日志项都已经提交了）
start_seq 第一个日志项的序列号

### 日志项


seq 日志序列号
crc32c 数据部分的CRC32哈希值
pre_pad 数据前的填充区
post_pad 数据后的填充区
magic1 日志项存放位置
magic2 fsid与seq及len的异或值（fsid XOR seq XOR len）
每个日志项都有一个日志头和日志尾，实际上日志尾是日志头的一个拷贝。日志数据按照日志文件头中指定的方式对齐。

### 日志数据

一系列的事务被传递到日志。在日志处理过程中，首先用encoding.h中定义的编码函数编码这些事务。每种类型的事务都在ObjectStore.h中定义了自己的解码器。需要注意的是日志项中不仅包括元数据，还包含IO数据。也就是说，一个写事务包括了它的IO数据。事务编码后，传递到日志也就被当成一个不透明的数据块。
