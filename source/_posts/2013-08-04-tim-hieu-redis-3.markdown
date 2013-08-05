---
layout: post
title: "Tìm hiểu redis (phần 3): đối tượng trong redis (redis objects)"
date: 2013-08-04 21:05
comments: true
categories: system linux
---

## 1. Giới thiệu 
Trong các bài viết trước mình đã trình bày về [cách redis sao lưu dữ liệu][] cũng như [framework lập trình hướng sự kiện của redis][]. Trong bài viết này mình trình bày về các đối tượng và kiểu dữ liệu trong redis.

[cách redis sao lưu dữ liệu]: http://ktmt.github.io/blog/2013/07/02/tim-hieu-redis/
[framework lập trình hướng sự kiện của redis]: http://ktmt.github.io/blog/2013/07/16/tim-hieu-redis-2/

## 2. Khái quát
Redis là một hệ thống cơ sở dữ liệu key-value - mỗi giá trị được quản lý bởi 1 cặp khóa và giá trị (key-value). Khi ghi dữ liệu, ta phải chỉ định rõ cặp khóa và giá trị. Khi đọc dữ liệu, ta phải chỉ ra ta muốn đọc dữ liệu của khóa nào. Trong Redis, khóa (key) có thể là một chuỗi. **giá trị của dữ liệu** (value) có thể là một trong một số kiểu dữ liệu thông dụng 

* tập hợp (set)
* tập hợp đã sắp xếp (sorted set)
* chuỗi (string)
* danh sách (list)

Để hỗ trợ các kiểu dữ liệu ở trên, đồng thời đảm bảo tính mở rộng (phát triển thêm các kiểu dữ liệu mới) cũng để dễ dàng quản lý đối tượng trong phần core db, redis thêm 1 layer mô tả dữ liệu trung gian gọi là robj. Các thao tác của core db (đọc, ghi, hash, encoding...) sẽ được thao tác trực tiếp với robj. Các kiểu dữ liệu người dùng ở trên sẽ được chuyển đổi (convert) qua lại đến robj. Nói cách khác, phần core db chỉ biết đến sự tồn tại của robj, các kiểu dữ liệu ở trên muốn được quản lý bởi coredb cần phải được chuyển qua robj.

Về mặt tổ chức mã, bạn có thể tham khảo sơ đồ dưới đây: 

	╒===============╕
	|  t_hash.c     |
	|  t_list.c     |		╒============╕		╒=====================╕
	|  t_set.c      |	<=>	|  object.c  |	<=>	|  db.c (robj -> sds) |	
	|  t_string.c   |		╘============╛		╘=====================╛
	|  t_zset.c     |
	╘===============╛

## 3. Chi tiết về robj

Chi tiết về cấu trúc của robj được khai báo trong file [redis.h][]

[redis.h]: https://github.com/antirez/redis/blob/unstable/src/redis.h

{% codeblock robj.c %}
/* A redis object, that is a type able to hold a string / list / set */

/* The actual Redis Object */
#define REDIS_LRU_CLOCK_MAX ((1<<21)-1) /* Max value of obj->lru */
#define REDIS_LRU_CLOCK_RESOLUTION 10 /* LRU clock resolution in seconds */
typedef struct redisObject {
    unsigned type:4;
    unsigned notused:2;     /* Not used */
    unsigned encoding:4;
    unsigned lru:22;        /* lru time (relative to server.lruclock) */
    int refcount;
    void *ptr;
} robj;

/* Macro used to initialize a Redis object allocated on the stack.
 * Note that this macro is taken near the structure definition to make sure
 * we'll update it when the structure is changed, to avoid bugs like
 * bug #85 introduced exactly in this way. */
#define initStaticStringObject(_var,_ptr) do { \
    _var.refcount = 1; \
    _var.type = REDIS_STRING; \
    _var.encoding = REDIS_ENCODING_RAW; \
    _var.ptr = _ptr; \
} while(0);
{% endcodeblock %}

Qua đó ta có thể thấy robj gồm có các trường như: 

- kiểu dữ liệu type 
- loại encoding: kiểu dữ liệu type có thể hiểu là kiểu dữ liệu người dùng, còn encoding có thể hiểu là kiểu dữ liệu ở backend được quản lý ở  core db của redis để đảm bảo hiệu năng. 
- lru ([least-recently used][]): là trường đại diện cho thời gian tồn tại tương đối của redis object. Redis hỗ trợ 1 tính năng đối với các đối tượng được ghi vào cơ sở dữ liệu redis: [expire][]. Các đối tượng quá thời gian chỉ  định trước sẽ được loại bỏ khỏi cơ sở dữ liệu. Trường này dùng để quản lý **thời gian hết hiệu lực** này. 
- refcount: là một biến kiểu số nguyên, đại diện cho số lượng reference đến robj này. Mỗi lần có một truy cập đến robj, đại lượng reference sẽ được tăng lên 1, và sẽ bị giảm đi 1 mỗi khi đối tượng **expired** hoặc không được tiếp tục tham chiếu.
- *ptr: con trỏ trỏ trực tiếp đến dữ liệu 
- notused??

Ở đây, ta gặp một kiểu khai báo **rất lạ** đặt ra nhiều câu hỏi. Thay vì khai báo unsigned type tác giả sử dụng unsigned type:4, điều này có ý nghĩa là gì? Sử dụng cả trường notused và lru:22 có ý nghĩa là gì?

Thực chất khai báo :số nguyên sau kiểu dữ liệu unsigned trong C biểu thị số bit mà trường này muốn sử dụng. Như vậy kiểu type ở trên có độ dài 4 bits. Tương tự như vậy độ dài của encoding là 4 bits. Với độ dài này, redis có thể hỗ trợ tối đa 2^4 = 16 kiểu dữ liệu khác nhau! LRU có độ dài 22 bits. Thực chất trường LRU này đại diện cho thời gian tương đối tính từ [server.lruclock][]. Thời gian này được tính bằng số phút theo thời gian tương đối này. Để ý với 4 bits cho type, 4 bits cho encoding và 22 bits cho lru, ta mới dùng có 30 bits cho cấu trúc robj này. Do các hệ thống x86 thường căn chỉnh cấu trúc dữ liệu theo bội số của 16 (liên quan đến cơ chế làm việc của CPU cache) nên ta cần padding thêm 2 bits và việc padding 2 bits này chính là nhiệm vụ của notused! 

Mã của robj khá gọn gàng, trong sáng, ngắn gọn và dễ hiểu. Bạn có thể tham khảo tại file [object.c][]. Ở đây tôi sẽ trình bày 2 điểm quan trọng về robj:

* Tại sao phải encode **robj**
* Vai trò của refcount.

**Tại sao phải encode robj?** Như trong danh sách các kiểu dữ liệu người dùng ở trên, ta thấy có chuỗi là kiểu dữ liệu cơ bản. Các kiểu dữ liệu còn lại (hast, set, list) đều là kiểu dữ liệu xoay quanh chuỗi, số nguyên hoặc các kiểu dữ liệu khác. Bản thân chuỗi thường có nhiều ký tự lặp lại, vì vậy bằng việc encoding chuỗi dữ liệu ta sẽ tiết kiệm được lượng bộ nhớ mà redis sử dụng. Encoding ở đây thực chất là làm giảm kích thước các object. Thuật toán encode chuỗi có thể tham khảo thủ tục [tryObjectEncoding][] và và các thủ tục trong file [util.c][]. Thử tưởng tượng bạn có 1 key trỏ đến danh sách gồm 100 chuỗi, mỗi chuỗi chỉ cần tiết kiệm được 1 byte, thì việc encode này sẽ giúp bạn tiết kiệm được 100 bytes bộ nhớ. Lượng bộ nhớ tiết kiệm này sẽ có ý nghĩa khi bạn có hàng triệu key và value!

**Vai trò của refcount** Refcount thường được dùng để chia sẻ dữ liệu giống nhau của các đối tượng khác nhau. Ví dụ bạn có 2 xâu a, b cùng giá trị "Chào Thế giới!" thì không việc gì ta phải có 2 chuỗi "Chào Thế giới!" trong bộ nhớ. Chuỗi a và b có thể cùng trỏ tới 1 chuỗi trên bộ nhớ và chỉ thật sự cần có 1 bản copy riêng khi mà 2 chuỗi khác nhau. Đây là cách sử dụng thường gặp của "[**reference count idiom**][]". Tuy vậy ở redis hiếm khi ta thấy 2 object cùng chia sẻ giá trị như trường hợp ở trên. Vậy vai trò của reference count ở đây là gì? 

Thực chất tác giả sử dụng refcount ở đây 1 cách khá sáng tạo (dù mình không biết là có thật sự là 1 cách dùng mới hay không). Thử tưởng tượng 1 trường hợp sau đây: 1 thread đang đọc giá trị của robj trong khi 1 thread khác đang gửi command del robj. Nếu command del được tiến hành ngay lập tức, thread đọc robj có thể bị lỗi và trả về giá trị không đúng (1 list có 10 phần tử nhưng phần tử nhưng khi đọc thì redis báo giá trị không tồn tại :-)). Nếu như command del không được thực thi, khóa trên sẽ vẫn tồn tại trong bộ nhớ, và kết quả thực hiện del sẽ thất bại. Chắc là bạn không muốn command del thất bại liên tục (khi số lượng đọc ghi cực lớn, khả năng xảy ra lỗi này là khá cao!). Để giải quyết bài toán trên, tác giả của redis sử dụng refcount. Khi một object được truy cập bởi nhiều thread, refcount của object sẽ được tăng lên 1 đơn vị và giảm 1 khi không được tham chiếu nữa. Như vậy command del sẽ chỉ giảm refcount của robj đi 1. Nếu như tại thời điểm này không có tham chiếu nào đến robj này, robj này sẽ bị thu hồi ngay lập tức. Tuy vậy nếu có 1 thread khác đang tham chiếu robj này, refcount của robj sẽ lớn hơn 1, và do đó tại thời điểm command del được thực thi, giá trị của refcount giảm xuống còn 1. Khi thread khác hoàn thành công việc, thread này sẽ giảm refcount xuống tiếp 1 đơn vị nữa, lúc này robj refcount sẽ về 0 và robj sẽ được giải phóng!

[least-recently used]: http://en.wikipedia.org/wiki/Cache_algorithms#Least_Recently_Used
[expire]: http://www.redis.io/commands/expire
[server.lruclock]: https://github.com/antirez/redis/blob/unstable/src/redis.h#L725
[object.c]: https://github.com/antirez/redis/blob/unstable/src/object.c
[tryObjectEncoding]: https://github.com/antirez/redis/blob/unstable/src/object.c#L339
[util.c]: https://github.com/antirez/redis/blob/unstable/src/util.c
[**reference count idiom**]: http://en.wikipedia.org/wiki/Reference_counting


## 4. Các cấu trúc dữ liệu người dùng
Tôi gọi các cấu trúc dữ liệu người dùng để phân biệt chúng với cấu trúc dữ liệu redis dùng để tăng hiệu năng ở core. Các cấu trúc dữ liệu này gồm list, hash, set và string được viết ở các file có tiền tố **t_** tương ứng. Như trình bày ở trên phần db core không biết gì ngoài robj vì vậy các cấu trúc dữ liệu này có nhiệm vụ là convert cách biểu diễn dữ liệu về robj. 

Nếu xem các file này, bạn sẽ thấy mỗi file đều có các hàm convert sang robj như: hashTypeConvert, listTypeConvert, ... Mỗi cấu trúc dữ liệu có cách viết khác nhau, nhưng đều cùng cấu trúc và khá ngắn gọn và đơn giản. Bạn có thể tham khảo từng file trên để  tìm hiểu rõ hơn về cách redis hỗ trợ các kiểu dữ liệu.

{% highlight bash %}
src git:(unstable) wc -l t_*.c
   761 t_hash.c
  1149 t_list.c
   913 t_set.c
   459 t_string.c
  2205 t_zset.c
  5487 total
{% endhighlight %}


## 5. Kết luận:

Bài viết trình bày về cách redis tổ chức các kiểu dữ liệu người dùng cũng như cách tổ chức phần "**frontend**" của redis db. Bài viết cũng trình bày chi tiết về robj, về ý nghĩa và vai trò của các trường trong robj cũng như vai trò của robj với backend db. Trong bài viết sau, mình sẽ cố gắng trình bày chi tiết về phần backend server.


