---
layout: post
title: "Định luật Amdahl"
date: 2014-05-19 21:35
comments: true
categories: parallel computing
---


### Giới thiệu

Có 1 người bạn gần đây  bắt đầu lập trình với threads và thiết kế chương trình như sau.

Chương trình có đầu vào là một mảng gồm một số phần tử (khoảng vài chục). Chương trình làm nhiệm vụ duyệt từng phần tử trong mảng, tính toán và trả về kết quả đối với từng phần tử. Bạn mình thiết kế chương trình bằng cách với mỗi phần tử trong mảng, bạn tạo một thread và cho thread thực hiện tính toán với phần tử đó.

Khi mình hỏi tại sao bạn lại thiết kế chương trình như thế thì bạn trả lời: các thread sẽ chạy song song nên về lý thuyết càng nhiều thread thì chương trình chạy càng nhanh!

Mình nhận ra bạn mình có về không biết định luật Amdahl, tuy đơn giản nhưng lại là một định luật rát quan trọng trong tính toán song song. Khi hiểu định luật này chắc chắn bạn sẽ có cái nhìn tổng quan hơn về hệ thống máy tính nói chung, và cụ thể là lập trình multithread nói riêng. Trong bài viết này, mình muốn giới thiệu định luật Amdahl. 


### Định luật Amdahl

Giả sử bạn thay CPU mới có tốc độ cao hơn CPU cũ.

[Định luật Amdahl][] nói rằng sự tằng tốc nhờ cải thiện hiệu năng của CPU = thời gian chạy toàn bộ tác vụ khi sử dụng CPU cũ / thời gian chạy toàn bộ tác vụ khi sử dụng CPU mới.

Độ tăng tốc phụ thuộc vào 2 thừa số:

- Tỉ lệ chương trình có thể cải thiện nhờ CPU mới. Ví dụ chương trình của bạn có 60 tính toán, 20 tính toán có thể được chuyển qua CPU mới (ví dụ CPU mới cung cấp tập lệnh mà CPU không có) như vậy tỉ lệ này là 20/60. Tỉ lệ này luôn nhỏ hơn hoặc bằng 1.
- Độ Tăng tốc thu được thu được từ CPU mới. Ví dụ 20 tính toán ở ví dụ trên ở CPU cũ hết 5s, CPU mới hết 2s, độ tăng tốc sẽ là 5/2 


Thời gian chạy với CPU mới = Thời gian chạy CPU cũ * (1 - tỉ lệ chương trình có thể cải thiện nhờ CPU mới + tỉ lệ chương trình có thể cải thiện nhờ CPU mới / độc tăng tốc thu được từ CPU mới).

     Độ tăng tốc tổng thể = Thời gian chạy trên CPU cũ / Thời gian chạy trên CPU mới     
                          = 1 / (1 - tỉ lệ chương trình cải thiện nhờ CPU mới + tỉ lệ chương trình cải thiện nhờ CPU mới / độ tăng tốc thu được từ CPU mới)

#### Ví dụ 1:
Bạn thay CPU cho máy chủ web. CPU mới chạy nhanh hơn CPU cũ 10 lần. Chương trình web của bạn giả sử tốn 60% cho SQL (I/O) và 40% tính toán (nhận kết quả từ cơ sở dữ liệu, render page). Hỏi tốc độ cải thiện từ việc thay CPU là bao nhiêu?

Giải:

- Tỉ lệ chương trình có thể cải thiện nhờ CPU mới = 0.4
- Độ tăng tốc = 10

  Độ tăng tốc tổng thể = 1 / (0.6 + 0.4/10) = 1 / 0.64 = 1.56

Vậy dù rằng CPU có tính nhanh 10 lần thì tốc độ của cả hệ thống chỉ được cải thiện 1.56 lần.


#### Ví dụ 2:
Hàm căn bậc hai của một số thực được sử dụng rất nhiều trong đồ hoạ máy tính. Giả sử tính toán căn bậc 2 chiếm 20% tổng thời chạy của thao tác đồ hoạ. Bạn muốn tăng tốc độ của hệ thống đồ hoạ của bạn. Có 2 lựa chọn sau đây:

- Mua card đồ hoạ mới với chip tính toán nhanh hơn 10 lần.
- Tăng tốc độ của các thao tác số thực khác lên 1.6 lần (ngoài thao tác tính căn bậc 2). Giả sử tổng số thao tác số thực là 50% (50% tính toán của bạn liên quan đến số thực).

Bạn sẽ đầu tư tiền hay bỏ thời gian và trí não cải thiện các thao tác còn lại.

Giải:

Trường hợp 1, độ tăng tốc = 1 / (0.8 + 0.2 / 10) = 1 / 0.82 = 1.22

Trường hợp 2, độ tăng tốc = 1 / (0.5 + 0.5 / 1.6) = 1.23

Như vậy lựa chọn 2 cho kết quả tốt hơn 1 chút!


#### Quan sát

Nếu thử quan sát, bạn sẽ thấy từ công thức Amdahl có thể rút ra là độ tăng tốc phụ thuộc cả vào bản chất bài toán. Nếu tỉ lệ có thể tăng tốc được không cao, việc bạn thêm song song cũng không giải quyết vấn đề gì. Nói cách khác nếu tỉ lệ cải thiện nhờ CPU mới = 0 thì độ tăng tốc tổng thể sẽ là 1 / (1 + 0/10) = 1 tức không thay đổi. 


#### Bạn mình sai lầm ở đâu?

Quay trở lợi vấn đề của bạn mình, tại sao mình lại nghĩ việc tăng số thread lên không giải quyết được tốc độ?

Giả sử bạn CPU bạn có 4 cores (Ví dụ Corei7 MQ). Chương trình của bạn sẽ được lập lịch bởi kernel. Nếu bạn dùng 2 threads, tại thời điểm CPU được cấp cho process của bạn, 2 cores sẽ được sử dụng để chạy chương trình. Giả sử chương trình bạn dùng CPU để tính toán 50% thời gian, 50% thời gian còn lại được chia đều cho các cores.

Nếu không dùng thread, chương trình của bạn là 1 chương trình liên tục bình thường, tốc độ sẽ cải thiện sẽ là:

    Độ tăng tốc = 1 / (0.5 + 0.5 / 1) = 1 (không tăng tí nào!)

Nếu bạn dùng 2 threads:

Độ tăng tốc = 1 / (0.5 + 0.5 / 2) = 1.33 (Tăng 33%!)

Nếu bạn dùng 4 threads:

    Độ tăng tốc = 1 / (0.5 + 0.5 / 4) = 1.6 (Tăng 60%!)

Nếu dùng 8 threads, bạn mong chờ tốc độ tăng tốc là 1.7! Sai lầm!
Lý do: giống như quan sát ở trên, bản thân việc chia việc cho CPU không phải là việc làm song song được. Nói cách khác CPU chỉ thực hiện được cùng 1 lúc 4 tác vụ. Nếu có nhiều hơn 4 tác vụ, tỉ lệ thực hiện song song (số task thực hiện đồng thời không đổi, nhưng só task phải thực hiện tăng lên) sẽ giảm khiến hiệu năng toàn hệ thống giảm xuống.

Ví dụ ta có 4 threads, thì số task có thể tận dụng được CPU là 100%. Khi ta có 5 threads, số threads có thể tận dụng được CPU sẽ giảm xuống 80%. Ta có thể xem sự thay đổi về hiệu năng so sánh tương đối với trường hợp 1 thread như sau:

4 threads:
        Độ tăng tốc = 1 / (0 + 1 / 4) = 4

5 threads:
        Độ tăng tốc = 1 / (0.2 + 0.8 / 4) = 1 / 0.4 = 2.5

Như vậy độ tăng tốc tương đối với trường hợp chỉ sử dụng 1 thread đã giảm từ 4 lần xuông còn 2.5 lần.

Nói cách khác, khi tất cả các cores đã làm việc thì việc tăng threads sẽ chỉ làm tăng thêm phần không thể tính song song, khiến hiệu năng hệ thống giảm. Ngoài ra còn có các chi phí khác mà ta chưa kể đến như: tạo một thread cũng tốn thời gian, bộ nhớ v.v. Nói cách khác việc tăng thread không làm tăng tốc độ chương trình mà nhiều trường hợp còn làm giảm tốc độ chạy. Suy nghĩ lúc đầu của bạn mình là sai lầm!

### Design nhờ định luật Amdahl

Như ở ví dụ 2 ở trên, bạn thấy rằng việc mua card đồ hoạ mới không làm tăng hiệu năng tổng thể như việc tối ưu chương trình. Như vậy ta hoàn toàn có thể thay đổi thiết kế chương trình để làm tăng hiệu năng. Ta xét bài toán ví dụ sau đây:

Nhập n. In ra tất cả các số nhỏ hơn n mà là số nguyên tố.

Dưới góc độ thread, ta có 2 cách design hệ thống (Giả định hệ thống có CPU 4 cores)

- Chia n ra làm 4 phần, mỗi thread thực hiện tìm số nguyên tố trong 1 phần.
- Một biến đếm từ 3 -> n, bước nhảy 2, cho mỗi thread đang rảnh lần lượt kiểm tra xem số hiện tại có phải là số nguyên tố không.

Bạn sẽ chọn cách nào?

Thoạt nhìn có vẻ 2 cách không có gì khác nhau, nhưng nếu để ý sẽ nhận ra là mật độ số nguyên tố không giống nhau. Nói cách khác nếu làm theo cách 1, sẽ có thread rất nhanh hoàn thành (thread phải xử lý vùng ít số nguyên tố), và có những thread phải làm việc rất vất vả (thread phải xử lý vùng có nhiều số nguyên tố). Nói cách khác cách design 1 có tỉ lệ tính toán có thể cải thiện không cao.

Cách 2 thoạt nhìn có vẻ chậm nhưng lại là cách cho tỉ lệ xử lý song song cao hơn, vì việc xử lý từng số một không phụ thuộc và phân bố của số nguyên tố!

Vậy ta nên thiết kế chương trình theo cách 2!


### Tổng kết
Bài viết giới thiệu định luật Amdahl, làm rõ ý nghĩa định luật cũng qua 2 ví dụ đồng thời áp dụng định luật Amdahl vào việc thiết kế bài toán đơn giản. Hy vọng qua bài viết bạn hiểu phần nào về đột tăng tốc trong tính toán song song, cũng như biết cách tính toán định lượng để đánh giá các thiết kế (Nhiều khi mua máy mới không hắn đã là tốt!).

### Quiz

1. Lý giải tại sao các hệ thống lại thiết kế dùng worker queue!
2. mysql có biến innodb_read_io_threads. Bạn sẽ thiết lập giá trị biến này là bao nhiêu?


### Tài liệu tham khảo

1. [Định luật Amdahl][]
2. [Computer Architecture, A Quantitative Approach][]

[Định luật Amdahl]: http://en.wikipedia.org/wiki/Amdahl's_law
[Computer Architecture, A Quantitative Approach]: http://www.amazon.com/Computer-Architecture-Quantitative-Approach-Edition/dp/0123704901
