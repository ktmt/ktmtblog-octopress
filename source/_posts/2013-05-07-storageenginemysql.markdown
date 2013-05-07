---
layout: post
title: "Giới thiệu một số storage engine của Mysql"
date: 2013-05-07 16:53
comments: true
categories: database, mysql, storage engine
---

# Giới thiệu

MySQL là một trong những hệ thống cơ sở dữ liệu quan hệ phổ biến số một thế giới, được sử dụng bởi hầu hết các website lớn. Do vậy, việc nắm vững MySQL là yêu cầu không thể thiếu đối với một webmaster.

Kiến trúc logic của MySQL nhìn tổng quan có thể được mô tả như hình dưới đây

{% img /images/logical_mysql_architecture.jpeg %}

Ta có thể thấy MySQL có các component cơ bản như ở dưới đây

* Connection/thread handling
* Query cache
* Parser
* Optimizer
* Storage engine

Việc nắm rõ từng chức năng và nhiệm vụ của từng thành phần là điều không thể thiếu trong việc sử dụng MySQL một cách hiệu quả. Bài viết sẽ tập trung giới thiệu về thành phần dưới cùng trong mô hình trên: Storage engine (Máy lưu trữ)

# Storage Engine (Máy lưu trữ)

Storage Engine thực chất là cách MySQL lưu trữ dữ liệu trên đĩa cứng. MySQL lưu mỗi database như là một thư mục con nằm dưới thư mục data. Khi một table được tạo ra, MySQL sẽ lưu định nghĩa bảng ở file đuôi .frm và tên trùng với tên của bảng được tạo. Việc quản lý định nghĩa bảng là nhiệm vụ của MySQL server, dù rằng mỗi storage engine sẽ lưu trữ và đánh chỉ mục (index) dữ liệu khác nhau. 

Ví dụ: mình chỉ định --datadir là /usr/local/mysql/data và định nghĩa bảng users trong database tên là test như sau

{% highlight bash %}
create table users (
    id int not null auto_increment, 
    name varchar(30), 
    password varchar(20), 
    primary key(id)
);
{% endhighlight %}

thì trong thư mục /usr/local/mysql/data sẽ có thư mục con là test, và dưới test sẽ có các file 

{% highlight bash %}
-rw-rw----  1 _mysql  wheel   8624  5  7 17:35 users.frm
-rw-rw----  1 _mysql  wheel  98304  5  7 17:35 users.ibd
{% endhighlight %}

Để xem loại storage engine của bảng hiện tại, bạn có thể dùng câu lệnh *SHOW DATABASE STATUS* 

{% highlight bash %}
mysql> show table status like 'users' \G
*************************** 1. row ***************************
           Name: users
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 2
 Avg_row_length: 8192
    Data_length: 16384
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: 3
    Create_time: 2013-05-07 17:35:09
    Update_time: NULL
     Check_time: NULL
      Collation: latin1_swedish_ci
       Checksum: NULL
 Create_options:
        Comment:
1 row in set (0.01 sec)
{% endhighlight %}

Cụ thể trong trường hợp này: 
    storage engine          : innodb
    loại row                : compact
    Số lượng row dữ liệu    : 2
    giá trị auto increment tiếp theo: 3
    ...

## Tổng quan các engine    
    
### 1. MyISAM engine

#####Đặc điểm
* full-text indexing
* compression.
* spatial functions (GIS)
* Không hỗ trợ transactions 
* Không hỗ trợ row-level lock. 

#####Lưu trữ

MyISAM lưu mỗi bảng dữ liệu trên 2 file: .MYD cho dữ liệu và .MYI cho chỉ mục. Row có 2 loại: dynamic và static (tuỳ thuộc bạn có dữ liệu thay đổi độ dài hay không). Số lượng row tối đa có thể lưu trữ bị giới hạn bởi hệ điều hành, dung lượng đĩa cứng. MyISAM mặc định sử dụng con trỏ độ dài 6 bytes để trỏ tới bản ghi dữ liệu, do vậy giới hạn kích thước dữ liệu xuống 256TB.

#####Tính năng: 
* MyISAM lock toàn bộ table. User (MySQL server) chiếm shared-lock khi đọc và chiếm exclusive-lock khi ghi. Tuy vậy, việc đọc ghi có thể diễn ra đồng thời!
* MyISAM có khả năng tự sửa chữa và phục hồi dữ liệu sau khi hệ thống crashed.
* Dùng command check table / repair table để kiểm tra lỗi và phục hồi sau khi bị lỗi.
* MyISAM có thể đánh chỉ mục full-text, hỗ trợ tìm kiếm full-text.
* MyISAM không ghi dữ liệu ngay vào ổ đĩa cứng, mà ghi vào 1 buffer trên memory (và chỉ ghi vào đĩa cứng sau 1 khoảng thời gian), do đó tăng tốc độ ghi. Tuy vậy, sau khi server crash, ta cần phải phục hồi dữ liệu bị hư hỏng bằng myisamchk.
* MyISAM hỗ trợ nén dữ liệu, hỗ trợ tăng tốc độ đọc dữ liệu. Mặc dù vậy dữ liệu sau khi nén không thể cập nhật được. 

###2. InnoDB engine

#####Đặc điểm
* Là engine phức tạp nhất trong các engine của MySQL
* Hỗ trợ transactions 
* Hỗ trợ phục hồi, sửa chữa tốt 

#####Lưu trữ

InnoDB lưu dữ liệu trên 1 file (thuật ngữ gọi là tablespace). 

#####Tính năng: 
* InnoDB hỗ trợ MVCC (Multiversion Concurrency Control) để cải thiện việc truy cập đồng thời và hỗ trợ chiến thuật next-key locking. 
* InnoDB được xây dựng dựa trên clustered index, do đó việc tìm kiếm theo primary key có hiệu năng rất cao. InnoDB không hỗ trợ sắp xếp index do vậy việc thay đổi cấu trúc bảng sẽ dẫn tới toàn bộ dữ liệu phải được đánh chỉ mục từ đầu (CHẬM với những bảng lớn). 

###3. Memory engine

#####Đặc điểm
* Còn được gọi là HEAP tables.


#####Lưu trữ

Tất cả dữ liệu đều nằm trên memory. 

#####Tính năng: 
* Sau khi server restart, cấu trúc bảng được bảo toàn, dữ liệu bị mất hết. 
* Memory engine sử dụng HASH index nên rất nhanh cho query lookup. 
* Memory engine dùng table-level locking do vậy tính concurrency không cao. 


###4. Archive engine

#####Đặc điểm
* Chỉ hỗ trợ Insert và Select.
* Không đánh chỉ mục
* Dữ liệu được buffer và nén bằng zlib nên tốn ít I/O, tốc độ ghi do đó cao. 

#####Tính năng: 
* Tốc độ ghi cao, phù hợp cho ứng dụng log.

###5. CSV engine

#####Đặc điểm
* Coi file CSV như là 1 table.
* Không hỗ trợ đánh chỉ mục

#####Tính năng: 
* Nếu bài toán là trích xuất thông tin từ file CSV và ghi vào cơ sở dữ liệu, đồng thời cần kết quả CSV ngay từ DB, engine này có vẻ thích hợp.

###6. Falcon engine

#####Đặc điểm
* Được thiết kế cho phần cứng hiện đại: server 64 bit, bộ nhớ "thênh thang"
* Vẫn còn khá mới, chưa có nhiều usercase

###7. Maria engine (Cơ sở dữ liệu liên quan: [MariaDB][])

#####Đặc điểm
* Được thiết kế bởi những chiến tướng dày dạn kinh nghiêm của MySQL, với mục đích thay thế MyISAM
* Hỗ trợ transactions theo lựa chọn
* Khôi phục lỗi
* Row-level locking và MVCC
* Hỗ trợ BLOB tốt hơn.

## Tiêu chí lựa chọn engine
* Transactions: Nếu ứng dụng yêu cầu transactions, InnoDB là lựa chọn duy nhất. Nếu không yêu cầu transactions, MyISAM là lựa chọn tốt. 
* Concurrency: Nếu yêu cầu chịu tải cao và không cần thiết transactions, MyISAM là lựa chọn số 1.
* Sao lưu: Các engine đều phần nào hỗ trợ sao lưu. Ngoài ra ta cần hỗ trợ sao lưu trên cả quan điểm thiết kế hệ thống. Ví dụ: bạn thiết kế database server gồm master và slave, master yêu cần transaction nên dùng innodb, slave cần sao lưu và đọc nên có thể dùng MyISAM. Cơ chế đồng bộ master-slave sẽ giúp bạn quản lý sự khác nhau giữa các engine nhưng đảm bảo tính sao lưu. Tiêu chí này có trọng số nhỏ. 
* Phục hồi sau crash: MyISAM có khả năng phục hồi sau crash kém hơn InnoDB.
* Tính năng theo yêu cầu hệ thống: Nếu yêu cầu là logging, MyISAM hoặc Archive là lựa chọn hợp lý. Nếu cần lưu trực tiếp CSV, CSV engine là lựa chọn đáng cân nhắc. Nếu ứng dụng không thay đổi dữ liệu mấy (ví dụ cơ sở dữ liệu sách), MyISAM và tính năng nén là lựa chọn phù hợp.

# Kết luận
Bài viết này đã giới thiệu tổng quan về storage engine, một thành phần quan trọng của hệ thống cơ sở dữ liệu. Một số engine tiêu biểu và tính năng đặc điểm cũng được đưa ra. Tiêu chí chọn lựa mỗi loại engine cũng được giới thiệu. 

Hy vọng qua bài viết, bạn có cái nhìn tổng quan về database storate engine nói chung, và MySQL storage engine nói riêng, đồng thời hiểu được tầm quan trọng của việc chọn lựa storage engine.

# Tham khảo

1. [High performance MySQL, 2ed][]
2. [Storage Engines][]
3. [Storage Engine Introduction][]

[High performance MySQL, 2ed]: http://shop.oreilly.com/product/9780596101718.do
[Storage Engines]: http://dev.mysql.com/doc/refman/5.7/en/storage-engines.html
[MariaDB]: https://mariadb.org/
[Storage Engine Introduction]: http://www.linux.org/article/view/an-introduction-to-mysql-storage-engines