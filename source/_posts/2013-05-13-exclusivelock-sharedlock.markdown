---
layout: post
title: "Exclusive Lock - Shared Lock"
date: 2013-05-13 04:52
comments: true
categories: concurrency database storage
---

## 1. Mở đầu

Nhân tiện trả lời thắc mắc của bạn kiennt về *shared lock* và *exclusive lock* được nhắc đến trong bài viết [Giới Thiệu Một Số Storage Engine Của Mysql][], mình viết bài này để giải thích khái niệm và ý nghĩa của exclusive lock, shared lock, MVCC cũng như làm rõ một số điểm chưa rõ ràng trong bài viết trên.

## 2. Cơ chế và ý nghĩa của Lock và MVCC

### 2.1 Khái niệm và ý nghĩa của lock

[Lock][] (khóa) là *cơ chế đồng bộ* và *giới hạn truy cập* đến *tài nguyên đươc chia sẻ* trong một môi trường có *nhiều luồng xử lý cùng truy cập*. 

Nói một cách hình tượng, lock giống một cái cờ tuyên bố chủ quyền đối với tài nguyên máy tính. Mỗi luồng xử lý (thread) khi truy cập tài nguyên dùng chung nào đó sẽ phải "dựng cờ lên" để báo cho các luồng xử lý khác biết tài nguyên đó đang được xử dụng và "hạ cờ xuống" khi hoàn thành xử lý trên tài nguyên đó. Các luồng xử lý khác bằng việc quan sát trạng thái của cờ này mà sẽ chiếm tài nguyên cho xử lý của mình, hay chờ đợi cho đến khi luồng xử lý khác kết thúc. Có thể nói lock là một phương tiện khẳng định quyền sở hữu đối với 1 loại tài nguyên. Nhờ cơ chế lock này mà tại mỗi thời điểm chỉ có duy nhất 1 luồng xử lý truy cập tài nguyên dùng chung..

*Shared lock*, hay còn gọi là read-only lock (khóa chỉ đọc) là lock mà một luồng xử lý phải chiếm hữu khi muốn đọc từ một vùng nhớ được chia sẻ.

*Exclusive lock*, hay còn gọi là read-write lock (khóa đọc ghi) là lock mà một luồng xử lý phải chiếm hữu khi muốn cập nhật một vùng nhớ được chia sẻ.

### 2.2 Tại sao phải cần lock

#### a. Tác dụng của exclusive lock

Xét bài toán ta có 2 luồng xử lý A, B cùng thao tác trên 2 biến a, b. 
Giá trị hiện tại của các biến

* a = 0
* b = 0

Nhiệm vụ của 2 luồng xử lý:

* Luồng xử lý A đọc giá trị 2 biến, tăng giá trị của a lên 1, và cập nhật giá trị cả 2 biến vào bộ nhớ.
* Luồng xử lý B đọc giá trị 2 biến, tăng giá trị của b lên 1, và cập nhật giá trị cả 2 biến vào bộ nhớ.

Giả sử A thực hiện trước, đọc giá trị của a và b (a=0, b=0) và tăng a lên 1. Lúc này giá trị của a đang là 1, của b là 0. Tuy nhiên, chính tại thời điểm này, hệ điều hành quyết định dừng A, và thực hiện B. B đọc giá trị 2 biến a và b và tăng b lên 1 rồi cập nhật cả 2 biến vào bộ nhớ. Do A chưa cập nhật giá trị 2 biến, giá trị của a lúc này vẫn là 0, của b là 1 (a=0,b=1 do A chưa hoàn thành). Vì vậy, tại thời điểm B kết thúc a = 0, b = 1. Đến đây hệ điều hành thực hiện chạy A ở bước cuối cùng, cập nhật giá trị 2 biến (a = 1, b = 0) vào bộ nhớ, ghi đè giá trị b = 1 được cập nhật bởi B. Kết quả cuối cùng (a = 1, b = 0) sai so với kết quả mong đợi (a = 1, b = 1).

        Luồng A            |  Luồng B
        -------------------|-------------------------
        Đọc a, b (a=0, b=0)|	
        a = 1, b = 0       |
                           |  Đọc a, b (a=0, b=0)
                           |  a = 0, b = 1
                           |  Ghi a, b (a = 0, b = 1)
        Ghi a, b (a=1, b=0)|

	
	Trạng thái cuối cùng (a=1, b=0)
	Kết quả mong chờ: (a=1, b=1)


Để giải quyết bài toán này, người ta dùng một exclusive lock. Luồng A, B muốn cập nhật giá trị a, b phải trước tiên chiếm lock, rồi mới thực hiện xử lý của mình. Các bước thực hiện giờ sẽ như sau:

* Chiếm lock. Nếu như chiếm được lock thì tiến hành xử lý tiếp theo. Nếu không, chờ đến khi chiếm được lock
* Đọc a, b
* Cập nhật a (hoặc b)
* Ghi a, b
* Thôi chiếm lock

Quy trình bây giờ tăng 2 bước (chiếm lock hoặc chờ đến khi nào chiếm được lock và nhả lock). Các bước chạy ở  trên giờ sẽ như sau:
A chiếm lock thành công (do chưa có luồn nào chiếm lock) và tiến hành đọc và cập nhật a (a=1, b=0). Tại thời điểm A bị dùng, B được chạy và thử chiếm lock nhưng do A đang nắm giữ lock nên B sẽ *phải* chờ. Lúc này A thực hiện nốt bước cuối cùng ghi giá trị vào bộ nhớ (a=1, b=0) và nhả lock. B lúc này thấy lock bị nhả và nắm giữ lock, đọc giá trị từ bộ nhớ (a=1, b=0!!), cập nhật b (a=1, b=1) và ghi dữ liệu vào bộ nhớ (a=1, b=1) đồng thời nhả lock. Kết quả cuối cùng như mong đợi (a=1, b=1)
        Luồng A             | Luồng B
        --------------------|--------------------------------
        Chiếm lock          |
        Đọc a, b            |	
        a = 1, b = 0        |
                            | Chiếm lock (không thành công)
        Ghi a, b (a=1, b=0) |
        Nhả lock            |
                            | Chiếm lock (thành công)
                            | Đọc a, b (a=1, b=0)
                            | a = 1, b = 1
                            | Ghi a, b (a = 1, b = 1)
                            | Nhả lock

	Trạng thái cuối cùng (a=1, b=1)
	Kết quả mong chờ: (a=1, b=1)!!!!

Ta có thể thấy nhờ có lock, mà tại mỗi thời điểm chỉ có 1 luồng xử lý truy cập a, b. Các luồng khác khi không chiếm được lock sẽ phải chờ đến lượt.

*Kết luận*: exclusive lock được sử dụng để đồng bộ 2 xử lý ghi đồng thời.

#### b. Tác dụng của shared lock

Để hiểu ý nghĩa shared lock, ta xét bài toán tương tự như ở trên. Lần này, thay vì 2 luồng cùng cập nhật vùng nhớ chung, 1 luồng sẽ đọc, còn một luồng sẽ cập nhật. Giả sử A đọc và B cập nhật, và giá trị ban đầu là a=0, b=0.

A tiến hành đọc a (a=0) và bị hệ điều hành *cho nghỉ* để B thực hiện. B đọc a, b (a=0, b=0) và thực hiện cập nhật b (a=0, b=1) và ghi kết quả lên bộ nhớ. A đọc nốt giá trị còn lại b (b=1). 

Kết quả cuối cùng đối với A rõ ràng không như mong đợi (Mong chờ: a=0, b=0 nhưng nhận về a=0, b=1).

        Luồng A     | Luồng B
        ------------|-------------------------
        Đọc a (a=0) |
                    | Đọc a, b (a=0, b=0)
                    | a = 0, b = 1
                    | Ghi a, b (a = 0, b = 1)
        Đọc b (b=0) |

	Kết quả cuối cùng (a=0, b=1)
	Kết quả mong chờ: (a=0, b=0)

Để giải quyết bài toán này, ta dùng shared-lock. Luồng A muốn đọc sẽ cần phải chiếm shared-lock. Luồng B muốn ghi sẽ phải nhìn xem shared-lock có bị chiếm hay không. Nếu shared-lock đang bị chiếm. B phải đợi cho đến khi tất cả shared-lock được giải phóng mới tiến hành cập nhật. Luồng chạy sau bây giờ sẽ như sau:

A chiếm shared-lock và tiến hành đọc a (a=0). A được *cho nghỉ* và B được *đưa vào sân*. Do A đang chiếm shared lock nên B không được quyền cập nhật và được *cho nghỉ*. A thực hiện nốt việc đọc b (b=0) và nhả shared-lock. B không thấy shared-lock và tiến hành cập nhật b (b=1) như bình thường.
        Luồng A           | Luồng B
        ------------------|-----------------------------
        Chiếm shared-lock |
        Đọc a (a=0)       |
                          | Nhìn thấy shared-lock. Nghỉ
        Đọc b (b=0)       |
        Nhả shared-lock   |
                          | Chiếm exclusive lock
                          | Đọc a, b (a=0, b=0)
                          | a = 0, b = 1
                          | Ghi a, b (a = 0, b = 1)
                          | Nhả exclusive lock.

	Kết quả cuối cùng (a=0, b=0)
	Kết quả mong chờ: (a=0, b=0)

*Kết luận*: shared-lock được sử dụng để đồng bộ 2 xử lý đọc ghi đồng thời.

#### c. Tại sao cần chiếm shared lock khi đọc dữ liệu

Đến đây ta có thể dễ dàng trả lời câu hỏi thứ nhất của kiennt! Khi tiến hành đọc dữ liệu, nếu không chiếm shared-lock, dữ liệu đó có thể bị cập nhật bởi 1 thread khác, dẫn tới giá trị đọc được bị thay đổi một phần, không bảo đảm tính toàn vẹn.

Tuy vậy có một điểm trong bài viết cần được làm rõ như sau: Trong câu nói "MyISAM lock toàn bộ table. User (MySQL server) chiếm shared-lock khi đọc và chiếm exclusive-lock khi ghi. Tuy vậy, việc đọc ghi có thể diễn ra đồng thời!", thì câu nói: "Tuy vậy, việc đọc ghi có thể diễn ra đồng thời!" là không đúng. 

Nói một cách chính xác hơn: việc *đọc và cập nhật (SELECT và UPDATE)* không được tiến hành đồng thời (Do tại thời điểm chiếm exclusive lock, không shared-lock nào được phép tồn tại). Tuy nhiên, việc *ghi mới* dữ liệu có thể được tiến hành mà không gây ảnh hưởng gì đến tính toàn vẹn của dữ liệu được đọc (vì chúng khác nhau!). Nói cách khác việc *đọc và ghi mới (SELECT và INSERT)* có thể được tiến hành đồng thời, và thực tế đây cũng là một tính năng của MyISAM. 

### 2.2 MVCC (Multiversion concurrency control)

MVCC được đặt ra để giải quyết vấn đề đọc và ghi đồng thời. Rõ ràng ở giải pháp shared-lock trình bày ở trên, việc A phải chiếm shared lock là rất mất thời gian; B phải chờ đợi A hoàn thành xử lý đọc mới được cập nhật cũng hoàn toàn không hiệu quả. MVCC giải quyết sự không hiệu quả này bằng nhận xét: *Thao tác đọc không cập nhật dữ liệu* vì vậy nếu ta duy trì 2 version của dữ liệu (1 cũ - 1 mới) và chỉ tiến hành ghi đè dữ liệu mới vào cũ khi A hoàn thành việc đọc, thì ta không cần shared-lock. B sẽ cập nhật và *version mới* thay vì phải chờ A hoàn thành việc đọc.

MVCC lưu timestamp và transaction ID để duy trì tính tính nhất quán của dữ liệu.

Để hiểu cách MVCC hoạt động, ta xét ví dụ sau (Copy từ Wikipedia :D)
        Thời gian       | Object 1      | Object 2
        ----------------|---------------|------------
        0               | Foo           | Bar
        1               | Hello (T1)    | 

Tại thời điểm 0, Object 1 có giá trị Foo, Object 2 có giá trị Bar. Tại thời điểm 1, thread T1 cập nhật giá trị Object 1 thành Hello. Như vậy trước khi T1 commit dữ liệu, bất cứ xử lý đọc nào cũng cho kết quả Object 1 và 2 tại thời điểm 0 (Foo-Bar). Khi T1 commit dữ liệu, xử lý đọc sẽ trả về giá trị Hello-Bar.

Giả sử tại thời điểm T1 chưa commit, T2 lại cập nhật Object 2 như sau:
        Thời gian       | Object 1      | Object 2
        ----------------|---------------|------------
        0               | Foo           | Bar
        1               | Hello (T1)    | 
        2               |               | World (T2)

Lúc này, mọi thao tác đọc sẽ vẫn trả về Foo-Bar. Khi T2 commit, dữ liệu đọc tiếp theo sẽ là Hello-Bar. Và khi T2 commit, dữ liệu đọc sẽ là Hello-World. Nói cách khác, tại mỗi thời điểm ta nhìn thấy 1 phiên bản dữ liệu, các cập nhật bởi thread khác sẽ được lưu tại một version khác.

Chính nhờ cách quản lý nhiều version dữ liệu này, mà việc đọc không cần lock shared-lock vẫn đảm bảo được tính toàn vẹn của dữ liệu được đọc.

## 3. Tổng kết
Bài viết đã giải thích phần nào hiểu hơn ý nghĩa của exclusive lock và shared-lock cũng như tác dụng và sự cần thiết của chúng. Đồng thời, bài viết cũng làm rõ những điểm được nói đến trong viết trong bài [Giới Thiệu Một Số Storage Engine Của Mysql][] cũng như giải đáp những thắc mắc của bạn kiennt.

## 4. Tham khảo:
1. [MVCC][]
2. [Lock][]
3. [Exclusive lock & shared lock][]
4. [High performance MySQL][]

[Giới Thiệu Một Số Storage Engine Của Mysql]: http://ktmt.github.io/blog/2013/05/07/storageenginemysql/
[MVCC]: http://en.wikipedia.org/wiki/Multiversion_concurrency_control
[Lock]: http://en.wikipedia.org/wiki/Lock_%28computer_science%29
[High performance MySQL]: http://www.amazon.com/High-Performance-MySQL-Optimization-Replication/dp/1449314287
[Exclusive lock & shared lock]: http://stackoverflow.com/questions/11837428/whats-the-difference-between-an-exclusive-lock-and-a-shared-lock

