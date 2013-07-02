---
layout: post
title: "Tìm hiểu redis - phần 1"
date: 2013-07-02 23:38
comments: true
categories: system, linux
---

## 1. Giới thiệu
[Redis][] là hệ thống lưu trữ key-value với rất nhiều tính năng và được [sử dụng rộng rãi][]. Redis nổi bật bởi việc hỗ trợ nhiều cấu trúc dữ liệu cơ bản (hash, list, set, sorted set, string), đồng thời cho phép scripting bằng ngôn ngữ lua. Bên cạnh lưu trữ key-value trên RAM với hiệu năng cao, redis còn hỗ trợ lưu trữ dữ liệu trên đĩa cứng (persistent redis) cho phép phục hồi dữ liệu khi gặp sự cố. Ngoài tính năng replicatation (sao chép giữa master-client), tính năng cluster (sao lưu master-master) cũng đang được phát triển . Để sử dụng một cách hiệu quả những tính năng redis hỗ trợ cũng như vận hành redis với hiệu suất cao nhất thì việc am hiểu hệ thống lưu trữ này là điều không thể thiếu. Chính vì lý do này, mình quyết định tìm hiểu mã nguồn redis. Loạt bài viết về redis này tóm tắt những điều mình tìm hiểu được từ việc đọc mã nguồn của redis.

[sử dụng rộng rãi]: http://redis.io/topics/whos-using-redis
[redis]: www.redis.io

## 2. Khái quát

Bạn có thể clone mã nguồn redis về máy tính mình bằng câu lệnh dưới đây:

{% highlight bash %} 
git clone https://github.com/antirez/redis.git
{% endhighlight %}

Trước hết là một số thống kê nho nhỏ về redis (tại thời điểm bài viết):
* Số lượng file mã nguồn: 55
{% highlight bash %} 
ls *.c | wc -l
55
{% endhighlight %}
* Số lượng file header: 30
{% highlight bash %} 
ls *.h | wc -l
30
{% endhighlight %}
* Tổng số dòng code: 43829
{% highlight bash %} 
wc -l *.[ch]
341    adlist.c     197   pqsort.c            228   sha1.c          810   dict.c
93     adlist.h     40    pqsort.h            17    sha1.h          173   dict.h
435    ae.c         359   pubsub.c            169   slowlog.c       124   endianconv.c
130    ae_epoll.c   93    rand.c              47    slowlog.h       64    endianconv.h
315    ae_evport.c  38    rand.h              50    solarisfixes.h  52    fmacros.h
118    ae.h         1230  rdb.c               530   sort.c          759   help.h
132    ae_kqueue.c  114   rdb.h               144   syncio.c        483   intset.c
99     ae_select.c  683   redis-benchmark.c   57    testhelp.h      50    intset.h
441    anet.c       3008  redis.c             761   t_hash.c        295   lzf_c.c
60     anet.h       218   redis-check-aof.c   1149  t_list.c        150   lzf_d.c
1178   aof.c        768   redis-check-dump.c  913   t_set.c         100   lzf.h
47     asciilogo.h  1556  redis-cli.c         459   t_string.c      159   lzfP.h
220    bio.c        1517  redis.h             2205  t_zset.c        279   memtest.c
41     bio.h        52    release.c           520   util.c          323   multi.c
412    bitops.c     3     release.h           41    util.h          1444  networking.c
2866   cluster.c    1658  replication.c       1     version.h       128   notify.c
1726   config.c     198   rio.c               1534  ziplist.c       580   object.c
195    config.h     104   rio.h               46    ziplist.h
88     crc16.c      1065  scripting.c         467   zipmap.c
191    crc64.c      732   sds.c               49    zipmap.h
8      crc64.h      99    sds.h               351   zmalloc.c
815    db.c         3160  sentinel.c          85    zmalloc.h
929    debug.c      261   setproctitle.c
43829  total
{% endhighlight %}

Một số thư viện được sử dụng: [jemalloc][], [linenoise][], [lua][]

[jemalloc]: http://www.canonware.com/jemalloc/
[linenoise]: https://github.com/antirez/linenoise
[lua]: http://www.lua.org/

## 3. Các modules

Redis bao gồm các module sau:

- Framework hỗ trợ xử lý bất đồng bộ, networking: ae, anet
- Mô tả dữ liệu: sds.c, t_hash.c, t_list.c, t_string.c, t_zset.c, object.c, notify.c (pub-sub)
- Lưu trữ dữ liệu, cơ sở dữ liệu: db.c, dict.c, ziplist.c, zipmap.c, adlist.c
- Module hỗ trợ IO/persistent redis: rdb.c, aof.c, bio.c, rio.c
- Utilities: crc16.c, crc64.c, pqsort.c, lzf_c.c, lzf_d.c

Mình sẽ lần lượt giới thiệu các modules trong các bài viết sau. Ở bài viết này, mình sẽ tập trung vào module IO/persistent redis.

## 4. Persistent redis

Bên cạnh việc lưu key-value trên bộ nhớ RAM, Redis có 2 background threads chuyên làm nhiệm vụ định kỳ ghi dữ liệu lên đĩa cứng.

Có 2 loại file được ghi xuống đĩa cứng:
 
- RDB
- AOF

RDB lưu dữ liệu dưới dạng đã mã hóa. AOF lưu lại toàn bộ dưới liệu dưới dạng command, giống như command mà redis client gửi đến server để thao tác bằng cách ghi đè xuống cuối file.

File rdb có thể coi là một snapshot của cơ sở dữ liệu tại một thời điểm nhất định. File dữ liệu này được dùng với 2 mục đích

- Cho phép redis có thể phục hồi lại dữ liệu trên memory bằng việc đọc file 
- Bản thân dữ liệu được ghi ra file rdb sẽ được gửi đến các redis slave server, phục vụ mục đích sao lưu server.

Dữ liệu ghi ra file rdb được chỉnh sửa và mã hóa để giảm kích thước ghi trên đĩa, đồng thời tằng tốc độ replication. Cụ thể  định dạng của file rdb như sau. 

Với những key ngắn, việc dùng 32 bit để mô tả key là thừa thãi, do vậy redis quy định những key ngắn được mã hóa sử dụng 2 bit đầu tiên của 1 byte. Cụ thể:
	00|000000 => 00, độ dài dữ liệu mô tả  bởi 6 bit 
	01|000000 00000000 => 01, độ dài dữ liệu là 14 bit
	10|000000 [số 32 bit] => 1 chuỗi độ dài 32 bit sẽ theo sau
	11|000000 => obj được encode đặc biệt sẽ theo sau byte này. 6 bit sau sẽ xác định kiểu object.

Kiểu object ở đây cụ thể như sau:
{% codeblock rdb.c %}
/* When a length of a string object stored on disk has the first two bits
 * set, the remaining two bits specify a special encoding for the object
 * accordingly to the following defines: */
#define REDIS_RDB_ENC_INT8 0        /* 8 bit signed integer */
#define REDIS_RDB_ENC_INT16 1       /* 16 bit signed integer */
#define REDIS_RDB_ENC_INT32 2       /* 32 bit signed integer */
#define REDIS_RDB_ENC_LZF 3         /* string compressed with FASTLZ */
{% endcodeblock %}

Với AOF file, các command sẽ được nhóm thành các block. Các block được tổ chức dưới dạng danh sách liên kết. Mỗi block có độ lớn 10MB là vì trong trường hợp redis server chịu tải cao, số lượng key được cập nhật lớn, nếu kích thước buffer lớn, việc realloc buffer dùng cho các command với tốc độ lớn không đảm bảo. 

Trong trường hợp file rdb, redis fork 1 process con và thực hiện ghi dữ liệu xuống đĩa cứng sử dụng rio (stream IO).

Trong trường hợp file aof, việc thực hiện ghi dữ liệu là của background threads. Toàn bộ chức năng này được code trong file bio.c (background IO?). Thiết kế background IO này khá đơn giản. Môt loạt thread sẽ chia sẻ 1 job queue và thay nhau đợi việc từ job queue. Mỗi khi có job mới, thread sẽ chạy và thực thi job được mô tả. Có 2 loại job đơn giản:
 
- REDIS_BIO_CLOSE_FILE: đóng file
- REDIS_BIO_AOF_FSYNC: thực hiện việc flush dữ liệu từ buffer của kernel xuống buffer của đĩa cứng.

	process -> job 1 -> job2 -> ... background threads

Tạo ra các job là công việc của child process. Để thực hiện ghi dữ liệu ra đĩa cứng, redis sẽ fork ra 1 process con. Process con này sẽ tạo ra việc cho các background threads. Một đặc điểm cùa aof file đấy là dữ liệu trong các block mới sẽ không được ghi trực tiếp vào file aof hiện tại, mà sẽ được ghi vào file tạm thời. Khi việc ghi dữ liệu hoàn thành, redis mới tiến hành ghi đè file tạm lên file thật. Việc này đảm bảo trong trường hợp hệ thống có sự cố, file aof cũ vẫn được duy trì, giúp phục hồi phần nào dữ liệu.

Trong cả 2 trường hợp, redis sử dụng tính năng [Copy-on-Write][] của linux khi fork process con, do vậy hiệu năng không vì fork process con mà suy giảm.

Đến đây, sau khi tìm hiểu về định dạng của 2 files dữ liệu cũng như phương thức ghi dữ liệu của từng loại file, ta vẫn còn những câu hỏi mở về persistent redis như sau:

- Tần suất ghi dữ liệu là bao nhiêu?
- Ai chịu trách nhiệm fork process con.

Thực chất redis định nghĩa 1 giá trị gọi là tần số ghi: REDIS_DEFAULT_HZ với giá trị mặc định là 10 (redis.h). Như vậy trong 1s, redis sẽ thực hiện 10 lần việc gọi hàm fork. Toàn bộ thao tác ghi dữ liệu redis và thao tác với các key hết hạn được thực hiện bởi 1 hệ thống các "cron". Hàm cron thực hiện việc validate các key là: databaseCron. Hàm cron thực hiện ghi dữ liệu là serverCron. Hàm serverCron sẽ được gọi theo cơ chế bất đồng bộ (dùng thư viện bất đồng bộ của chính redis) với tần số 1/1000s. Với REDIS_DEFAULT_HZ là 10, cứ 100 lần gọi, serverCron sẽ thực hiện fork child process 1 lần để ghi dữ liệu xuống bộ đĩa cứng.

[Copy-on-Write]: http://en.wikipedia.org/wiki/Copy-on-write

## 5. Tại sao phải fsync

Đến đây chắc bạn đã hiểu phần nào về cơ chế persistent của redis. Tuy nhiên ta vẫn còn 1 câu hỏi nhỏ khá thú vị: tại sao phải flush liên tục như vậy (100ms / lần)? Tại sao không chỉ dùng hàm write/read của kernel và mặc định việc ghi dữ liệu xuống đĩa cứng cho kernel. Để trả lời câu hỏi nhỏ này, ta cần hiểu mối liên quan giữa OS - đĩa cứng - buffer của tầng ứng dụng. 

Về mặt trực quan tra có mô hình như sau:

	buffer ---(Write) --| (kernel buffer) ---> hard disk buffer ---> đĩa từ.

Một thao tác ghi dùng write/read api của kernel sẽ copy dữ liệu từ buffer tần ứng dụng xuống buffer của kernel. Đây là thao tác cơ bản của write api. Tại buffer của kernel, kernel có toàn quyền quyết định với buffer này như: khi nào ghi, ghi bao nhiêu bytes... Khi kernel ghi dữ liệu (sử dụng các hàm IO của đĩa), dữ liệu sẽ được ghi xuống hard disk buffer và được schedule ghi xuống đĩa từ. Do vậy nếu tại tầng kernel hệ thống gặp sự cố, dữ liệu vẫn có thể bị mất dù rằng write **thành công** (và tầng ứng dụng không có cách nào biết write không thành công). Bằng việc định kỳ gọi fsync, ứng dụng có thể  **thoát khỏi sử quản lý của kernel**, ghi thằng dữ liệu đang có ở buffer xuống hard disk buffer. Bằng việc gọi fsync, ta tránh khỏi được rủi ro mất dữ liệu do đổ vớ ở tầng ứng dụng. Tất nhiên dữ liệu hard disk vẫn chưa hoàn toàn an toàn (ví dụ trường hợp đĩa cứng bị hỏng).

Đây là cách làm chung của các hệ thống cơ sở dữ liệu RDMS hiện hành.

## 6. Kết luận
Bài viết giới thiệu khái quát các module redis, đồng thời trình bày cụ thể cơ chế ghi dữ liệu của redis. Bài viết cũng làm rõ hơn ý nghĩa của fsync cũng như quy trình ghi dữ liệu của hệ điều hành. Hy vọng qua bài viết, người đọc hiểu phần nào cơ chế, hành vi của redis, qua đó sử dụng công cụ này hiệu quả hơn.

## 7. Tham khảo
1. [persistent redis][]
2. [vm][]
3. [Understanding Virtual Memory][]
4. [redis book][]

[persistent redis]: http://redis.io/topics/persistence
[vm]: http://redis.io/topics/virtual-memory
[Understanding Virtual Memory]: http://www.redhat.com/magazine/001nov04/features/vm/
[redis book]: http://openmymind.net/redis.pdf


