---
layout: post
title: "Nâng phiên bản mysql 5.6"
date: 2013-08-26 22:06
comments: true
categories: mysql
---

## 1. Giới thiệu

Trong quá trình vận hành 1 website chúng ta thường có các task như nâng phiên bản máy chủ web, nâng phiên bản cơ sở dữ liệu (vì mục đích nâng cao hiệu năng hoặc đảm bảo bảo mật). Với những hệ thống sẵn có, quản lý lượng dữ liệu lớn, tác vụ này thường không hề đơn giản, đòi hỏi 1 trình tự hơp lý. Bài viết này tổng kết là trình tự nâng cấp mysql từ phiên bản 5.0.x lên phiên bản 5.6.x và những vấn đề mình gặp phải trong quá trình nâng cấp này.

## 2. Bài toán

Website sử dụng hệ thống cơ sơ dữ liệu mysql, dưới mô hình master/slave. Cả master/slave đều đang chạy mysql 5.0. Ta cần nâng cấp mysql lên phiên bản 5.6. 

#### Điều kiện
Mọi bài toán đều không có gì khó nếu như không có giới hạn gì. Ở đây ta bắt gặp 1 vài giới hạn cần chú ý như sau: 

- Các query được dùng trong website có thể không tương thích với mysql phiên bản mới.
- Nâng cấp master đồng thời với slave sẽ có rủi ro khi mà cả 2 gặp lỗi. 
- Dung lượng ổ cứng: khi dung lượng ổ cứng sao lưu không cho phép, ta sẽ phải thực hiện các thao tác công phu hơn 1 chút.

Do vậy, cách tốt nhất là nâng cấp lần lượt slave -> master. Tức là slave sẽ chạy mysql5.6 và master sẽ chạy mysql5.0

#### Phương pháp

Có 2 cách nâng cấp mysql.

- [Cách truyền thống][] như được viết trong tài liệu hướng dẫn nâng cấp. Cụ thể ta nâng cấp dần dần qua các phiên bản trung gian bằng script mysql_upgrade.
- Cách ngắn gọn: dump toàn bộ dữ liệu ở phiên bản cũ và import lại vào phiên bản mới.

[Cách truyền thống]: http://dev.mysql.com/doc/refman/5.6/en/upgrading.html

Mỗi cách có ưu nhược điểm riêng; cụ thể cách 1 đảm bảo khả năng thành công cao, tuy vậy lại có nhược điểm là chuẩn bị môi trường cho các phiên bản rườm rà, tốn thời gian. Với khoảng cách 2 phiên bản lớn (5.0 -> 5.6: qua 5.1, 5.5) thì việc upgrade khá tốn thời gian.

Cách 2 có ưu điểm nhanh, tuy vậy lại có nhược điểm là tính tương thích giũa 2 phiên bản không tốt, dẫn đến khả năng lỗi sau khi upgrade cao.

Bài viết sẽ trình bày quy trình upgrade theo cách 2.

## 3. Quy trình:

#### Bước 1: dump toàn bộ dữ liệu
Ta có thể dump toàn bộ dữ liệu từ slave hoặc master hiện tại. 

a. Dump dữ liệu từ slave
{% highlight bash %}
mysql> stop slave
mysql> show slave status;
{% endhighlight %}

Ghi nhớ các thông tin: master_host, master_port, replication_user, relay_master_log_file, 

{% highlight bash %}
$ mysqldump -u username -p --all-database --single-transaction | gzip -f > dumpfile.gz
{% endhighlight %}

{% highlight bash %}
mysql> start slave;
{% endhighlight %}

b. Dump dữ liệu từ master

{% highlight bash %}
mysql> flush tables with read lock;
mysql> show master status;
{% endhighlight %}

{% highlight bash %}
mysqldump -u username -p --all-database --single-transaction | gzip -f > dumpfile.gz
{% endhighlight %}

{% highlight bash %}
mysql> unlock tables;
{% endhighlight %}

#### Bước 2: Cài đặt mysql phiên bản 5.6
{% highlight bash %}
$ /etc/init.d/mysql stop                 # stop mysql-5.0
$ cd /usr/local
$ wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.13-linux-glibc2.5-x86_64.tar.gz/from/http://cdn.mysql.com/
 
$ tar xfz mysql-5.6.13-linux-glibc2.5-x86_64.tar.gz
$ mv mysql-5.6.13-linux-glibc2.5-x86_64 mysql-5.6.13
 
# symbolic link張替える
$ rm mysql
$ ln -sf mysql-5.6.13 mysql
$ cd mysql
$ chown -R mysql:mysql .
{% endhighlight %}

#### Bước 3: Khởi động mysql và import dữ liệu
{% highlight bash %}
$ cp /tmp/my.cnf /usr/local/mysql
 
# データ容量そろえる
$ cd /dbdata/data
$ rm -rf *
 
# 起動するため、テンポラリデータフォルダを作る
$ cd /usr/local/mysql
$ cd data                             # 空きフォルダか確認
$ ll 
$ cd ..
$ ./scripts/mysql_install_db --user=mysql
$ cp support-files/mysql.server /etc/init.d/mysql
$ /etc/init.d/mysql start
$ mysqladmin -u root password 'pass'
 
 
# data フォルダは /dbdata/dataにする
$ mv data data.bk
$ ln -sf /dbdata/data data

# import data file
$ mysql -u root -p < バックアップファイル
{% endhighlight %}

#### Bước 4: Khởi động lại mysql.
{% highlight bash %}
$ /etc/init.d/mysql stop
$ /etc/init.d/mysql start
{% endhighlight %}

#### Bước 5: Cài đặt sao chép (replication)
{% highlight bash %}

$ mysql -u root -p
mysql> show slave status¥G;   # replication されてない確認
 
....
 
mysql> change master to master_host='master ip',
         master_user='レプリケーションユーザ名',
         master_password='パスワード',
         master_log_file='mysql-bin.000003',
         master_log_pos=73;
  Query OK, 0 rows affected (0.03 sec)
mysql>
mysql> show slave status¥G
*************************** 1. row ***************************
             Slave_IO_State:
                Master_Host: master ip
                Master_User: レプリケーションユーザ名
                Master_Port: 3306
              Connect_Retry: 60
            Master_Log_File: mysql-bin.001378
        Read_Master_Log_Pos: 348578503
             Relay_Log_File: mysqld-relay-bin.000001
              Relay_Log_Pos: 4
      Relay_Master_Log_File: mysql-bin.001378
           Slave_IO_Running: No
          Slave_SQL_Running: No
            Replicate_Do_DB:
        Replicate_Ignore_DB:
         Replicate_Do_Table:
     Replicate_Ignore_Table:
    Replicate_Wild_Do_Table:
Replicate_Wild_Ignore_Table:
                 Last_Errno: 0
                 Last_Error:
               Skip_Counter: 0
        Exec_Master_Log_Pos: 348578503
            Relay_Log_Space: 98
            Until_Condition: None
             Until_Log_File:
              Until_Log_Pos: 0
         Master_SSL_Allowed: No
         Master_SSL_CA_File:
         Master_SSL_CA_Path:
            Master_SSL_Cert:
          Master_SSL_Cipher:
             Master_SSL_Key:
      Seconds_Behind_Master: NULL
1 row in set (0.00 sec)
  
mysql> start slave;
{% endhighlight %}


#### Bước 6: Kiểm tra cài đặt replication.
{% highlight bash %}
mysql> show slave status¥G
*************************** 1. row ***************************
             Slave_IO_State:
                Master_Host: master ip
                Master_User: レプリケーションユーザ名
                Master_Port: 3306
              Connect_Retry: 60
            Master_Log_File: mysql-bin.001378
        Read_Master_Log_Pos: 348578503
             Relay_Log_File: mysqld-relay-bin.000001
              Relay_Log_Pos: 4
      Relay_Master_Log_File: mysql-bin.001378
           Slave_IO_Running: No
          Slave_SQL_Running: No
            Replicate_Do_DB:
        Replicate_Ignore_DB:
         Replicate_Do_Table:
     Replicate_Ignore_Table:
    Replicate_Wild_Do_Table:
Replicate_Wild_Ignore_Table:
                 Last_Errno: 0
                 Last_Error:
               Skip_Counter: 0
        Exec_Master_Log_Pos: 348578503
            Relay_Log_Space: 98
            Until_Condition: None
             Until_Log_File:
              Until_Log_Pos: 0
         Master_SSL_Allowed: No
         Master_SSL_CA_File:
         Master_SSL_CA_Path:
            Master_SSL_Cert:
          Master_SSL_Cipher:
             Master_SSL_Key:
      Seconds_Behind_Master: NULL
1 row in set (0.00 sec)
  
mysql> start slave;
{% endhighlight %}

## 4. Các lỗi có thể có

Nếu làm mọi việc suôn sẻ, ta có thể hoàn thành thao tác nâng cấp ở bước 4. Tuy vậy tuỳ vào đặc tính dữ liệu, mà mọi việc có thể không suôn sẻ như vậy. Trong lần nâng cấp này, mình gặp 1 lỗi sau sau khi khởi động mysql.

{% highlight bash %}
2013-08-25 11:07:00 19807 [Note] Server socket created on IP: '0.0.0.0'.
02:07:00 UTC - mysqld got signal 11 ;
This could be because you hit a bug. It is also possible that this binary
or one of the libraries it was linked against is corrupt, improperly built,
or misconfigured. This error can also be caused by malfunctioning hardware.
We will try our best to scrape up some info that will hopefully help
diagnose the problem, but since we have already crashed,
something is definitely wrong and this may fail.

key_buffer_size=134217728
read_buffer_size=2097152
max_used_connections=0
max_threads=100
thread_count=0
connection_count=0
It is possible that mysqld could use up to
key_buffer_size + (read_buffer_size + sort_buffer_size)*max_threads = 542029 K  bytes of memory
Hope that's ok; if not, decrease some variables in the equation.

Thread pointer: 0xe57de70
Attempting backtrace. You can use the following information to find out
where mysqld died. If you see no messages after this, something went
terribly wrong...
stack_bottom = 7fffd70eced8 thread_stack 0x40000
/usr/local/mysql/bin/mysqld(my_print_stacktrace+0x35)[0x8fa385]
/usr/local/mysql/bin/mysqld(handle_fatal_signal+0x3e8)[0x66cfd8]
/lib64/libpthread.so.0[0x3a9300eb10]
/usr/local/mysql/bin/mysqld(_Z9get_fieldP11st_mem_rootP5Field+0x3c)[0x77b16c]
/usr/local/mysql/bin/mysqld[0x68c5bc]
/usr/local/mysql/bin/mysqld(_Z10acl_reloadP3THD+0x459)[0x68f059]
/usr/local/mysql/bin/mysqld(_Z8acl_initb+0x117)[0x6901c7]
/usr/local/mysql/bin/mysqld(_Z11mysqld_mainiPPc+0x543)[0x582e13]
/lib64/libc.so.6(__libc_start_main+0xf4)[0x3a9241d994]
/usr/local/mysql/bin/mysqld(__gxx_personality_v0+0x2e1)[0x5779e9]

Trying to get some variables.
Some pointers may be invalid and cause the dump to abort.
Query (0): is an invalid pointer
Connection ID (thread ID): 0
Status: NOT_KILLED

The manual page at http://dev.mysql.com/doc/mysql/en/crashing.html contains
information that should help you find out what is causing the crash.
130825 11:07:00 mysqld_safe Number of processes running now: 0
130825 11:07:00 mysqld_safe mysqld restarted
2013-08-25 11:07:01 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
2013-08-25 11:07:01 19847 [Note] Plugin 'FEDERATED' is disabled.
2013-08-25 11:07:01 19847 [Note] InnoDB: The InnoDB memory heap is disabled
2013-08-25 11:07:01 19847 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2013-08-25 11:07:01 19847 [Note] InnoDB: Compressed tables use zlib 1.2.3
2013-08-25 11:07:01 19847 [Note] InnoDB: Using Linux native AIO
2013-08-25 11:07:01 19847 [Note] InnoDB: Not using CPU crc32 instructions
2013-08-25 11:07:01 19847 [Note] InnoDB: Initializing buffer pool, size = 512.0M
2013-08-25 11:07:01 19847 [Note] InnoDB: Completed initialization of buffer pool
2013-08-25 11:07:01 19847 [Note] InnoDB: Highest supported file format is Barracuda.
130825 11:07:09 mysqld_safe mysqld from pid file /usr/local/mysql/data/nl-dbdev-slave.pid ended
{% endhighlight %}

mysql khởi động gặp bug về bộ nhớ (segmentation fault) và bị kill bởi signal 11. Mysql liên tục khởi động và bị kill.

Để tránh trường hợp này, sau khi import dữ liệu ta nên chạy mysql_upgrade 1 lần để script này sửa các bảng trong trạng thái lỗi trước khi khởi động lại để tránh lỗi ở trên.

## 5. Tổng kết

Bài viết tóm tắt quy trình nâng cấp phiên bản mysql cũng như cách dump toàn bộ dữ liệu trong mysql cũng như lỗi có thể gặp phải + cách giải quyết. Hy vọng với tóm tắt này, bạn sẽ không bở ngỡ khi phải backup hay nâng cấp phiên bản cho mysql.
