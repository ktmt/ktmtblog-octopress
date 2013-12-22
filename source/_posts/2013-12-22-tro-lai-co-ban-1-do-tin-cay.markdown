---
layout: post
title: "Trở lại cơ bản - Độ tin cậy"
date: 2013-12-22 20:36
comments: true
categories: system, failure, dependability
---

### Giới thiệu

Các bạn là fan của [tính toán phân tán][] chắc hẳn đều biết [Werner Vogels][] (CTO của amazon) cũng như trang blog [All Things Distributed][] của ông. Một trong những loạt bài viết mà cá nhân tôi rất thích là loạt bài viết có tựa đề: Back-to-Basic của Vogels. Trong loạt bài viết này, Vogels giới thiệu những paper nổi tiếng mà những người làm tính toán phân tán cần đọc và tất cả đều hết sức cơ bản. 

Lấy cảm hứng từ trùm bài viết đấy, mình quyết định sẽ viết trùm bài có tựa đề "Trở lại cơ bản" tổng hợp lại những kiến thức cơ bản, trước hết là để cho bản thân và sau đấy để là để chia sẻ cho mọi người (có những thứ bạn nghĩ là cơ bản nhưng không phải ai cũng biết ;) ).

Bài viết tuần này sẽ nêu khái lược khái niệm độ tin cậy, cách tính độ tin cậy.

[tính toán phân tán]: http://en.wikipedia.org/wiki/Distributed_computing
[Werner Vogels]: http://en.wikipedia.org/wiki/Werner_Vogels
[All Things Distributed]: www.allthingsdistributed.com

### Độ tin cậy là gì?

Độ tin cậy có thể hiểu là độ bền của sản phẩm hoặc dịch vụ . Sản phẩm (dịch vụ) của bạn càng bền, chạy càng lâu mà không hỏng hóc gì, thì độ bền của sản phẩm càng cao, và do đó độ tin cậy vào sản phẩm của bạn nói riêng và của người dùng nói chung vào sản phẩm càng cao. Đối với dịch vụ (cloud, website) thì độ tin cậy có thể đo bằng thời gian hệ thống sẵn sàng phục vụ bạn (không bị dừng vì sự cố hay hỏng hóc).

Với cách hiểu trên, một vấn đề đặt ra là làm thế nào **cân đo đong đếm** độ tin cậy. Ví dụ khi một hãng phần cứng bán cho bạn 1 chiếc ổ cứng và họ bảo đảm với bạn rằng phần cứng của họ có độ tin cậy cao, thì họ dựa vào điều gì để nói như vậy?

Các hãng bán máy tính đều đưa ra chế độ bảo hành cho sản phẩm của họ, với lời quảng cáo rằng trong thời gian bảo hành họ sẵn sàng thay thế sản phầm của họ nếu sản phẩm của họ bị lỗi. Độ tin cậy như vậy có thể đo bằng thời gian bảo hành. Qua thời gian bảo hành, sản phẩm có thể bị hỏng hóc và hãng sẽ không chịu trách nhiệm cho những hỏng hóc đó. Ví dụ máy tính apple thường có thời gian bảo hành 1 năm.

Đối với các sản phẩm là dịch vụ trên internet, người ta thường đưa ra các [Service Level Agreements (SLA)][] hoặc **Service Level Objectives (SLO)** để quảng cáo cho độ tin cậy của dịch vụ, và họ sẵn sàng bồi thường cho khách hàng nếu sản phẩm của họ không đáp ứng được những "đồng ý" này. Amazon EC2 cam kết trong [Amazon SLA][] rằng họ đảm bảo EC2 99.95% có uptime   thời gian trong 1 tháng. Nếu họ không đáp ứng điều kiện này, họ sẽ có chính xác bồi thường cho người dùng. Giống như vậy, các công ty dịch vụ cloud khác nhưng rackspace cũng đều có [Rackspace SLA][] của riêng họ. Ngược lại việc hãng cloud như heroku không có một đảm bảo SLA nào ngoài [Heroku Promise][], làm cho độ tin tưởng vào sản phẩm của họ giảm hẳn.

[Amazon SLA]: http://aws.amazon.com/ec2-sla/
[Service Level Agreements (SLA)]: http://en.wikipedia.org/wiki/Service-level_agreement
[Rackspace SLA]: http://www.rackspace.com/information/legal/cloud/sla
[Heroku Promise]: https://www.heroku.com/policy/promise

### Đo độ tin cậy thế nào?

Chắc chắn amazon sẽ không ngu gì đưa ra 1 cam kết không tưởng 100% uptime, nhưng họ cũng không thể đưa ra con số quá thấp được vì điều đó sẽ làm giảm khả năng cạnh tranh với các công ty khác. Apple cũng không dại gì đưa ra số năm bảo hành cao hơn vì nó sẽ làm giảm lợi nhuận của họ. Vậy các hãng đưa ra các con số trên như thế nào?

Mỗi công ty cung câp dịch vụ sẽ có nhiều chỉ số riêng để đánh giá và tính toán trước khi đưa ra con số của dịch vụ của họ, tuy vậy các tính toán đề dựa vào cách tính cơ bản trình bày dưới đây.

Để tính toán độ tin cậy, ta chia hệ thống làm 2 trạng thái tương ứng như được ghi trong SLA:

- Thời gian phục vụ như cam kết
- Thời gian dừng dịch vụ (do hỏng hóc)

Hệ thống thay đổi giữa 2 trạng thái này là: hỏng hóc và phục hồi. Để đo được độ tin cậy của hệ thống, ta cần đo được thời gian hệ thống ở 1 trong 2 trạng thái trên. Một hệ thống được xây dựng từ nhiều modules, do vậy độ tin cậy của hệ thống sẽ liên quan đến độ tin cậy của từng module trong hệ thống. Trước hết ta tìm hiểu các chỉ số tương ứng với 2 trạng thái trên.

Độ tin cậy của 1 thành phần (module) được đo bằng thời gian phục vụ liên tục từ lúc bắt đầu được sử dụng đến lúc hỏng hóc gọi là MTTF (Mean Time to Failure). Nghịch đảo của con số này chính là tỉ lệ hỏng hóc FIT (Failures in time) và thường được đo bằng số hỏng hóc / 1 tỷ giờ vận hành. 

Độ hỏng hóc (hỏng nặng hay nhẹ) được đo bằng MTTR (Mean Time To Repair) hay thời gian từ lúc hệ thống hỏng hóc cho đến lúc được phục hồi.

Thời gian giữa 2 lần hỏng hóc 

	MTBF (Mean Time Between Failures) = MTTF + MTTR

Tính sẵn sàng của 1 modules (Module availability) được đo bởi thời gian hoạt động cho đến lúc hỏng hóc trên tổng thời gian giữa 2 lần hỏng hóc:

	Module Availability = MTTF / (MTTF + MTTR)

Từ công thức trên, ta có thể đo được tính sẵn sàng của hệ thống dựa vào tính tin cậy của từng module dùng để xây dựng nên hệ thống.

### Áp dụng

Tính MTTF của 1 hệ thống
Giả sử ta có 1 hệ thống được xây dựng bởi

- 10 đĩa cứng, mỗi đĩa có MTTF 1000000 giờ 
- 1 bộ điều khiển [SCSI][] có MTTF 500000 giờ
- 1 bộ nguồn có MTTF 200000 giờ
- 1 quạt làm mát có MTTF 200000 giờ
- 1 cáp SCSI có MTTF 1000000 giờ.

Hãy tính MTTF của cả hệ thống.

Lời giải

Tỉ lệ hỏng hóc của toàn hệ thống:

	Failure rate = 10 / 1000000 + 1/500000 + 1/200000 + 1/200000 + 1/1000000
	             = (10 + 2 + 5 + 5 + 1) / 1000000 = 23 / 1000000 = 23000 / 1000000000

hệ thống sẽ có tỉ lệ hỏng hóc 23000FIT. MTTF của hệ thống sẽ bằng nghịch đảo con số trên

	MTTF = 1000000000 / 230000 = 43450 giờ (khoảng 5 năm)

Từ con số trên, ta có thể thấy mặc dù MTTF của từng module khá lớn, nhưng MTTF của cả hệ thống nói chung chỉ là 5 năm. MTTF của các module trong máy tính cá nhân có lẽ thấp hơn nhiều. Có lẽ vì vậy mà các công ty bán phần cứng không bao giờ đưa ra thời gian bảo hành lâu quá 2, 3 năm! Từ con số này các công ty làm dịch vụ internet cũng phải có cách lập kế hoạch bảo trì thay mới máy chủ để đảm bảo tính tin cậy của dịch vụ của mình. Trong trường hợp công ty mình, tất cả các máy chủ đều được thay mới sau 5 năm (Và giờ bạn đã hiều tại sao phải thay và con số 5 này từ đâu ra :) ).

[SCSI]: http://en.wikipedia.org/wiki/SCSI

### Kết luận

Qua bài viết này, chúng ta đã có thể lý giải và cân đong đo đếm được độ tin cậy của hệ thống dựa trên các chỉ số MTTF, MTTR, FIT, cũng như lý giải được ý nghĩa của SLA của 1 dịch vụ.

### Tham khảo

- [Computer Architecture A quantitative Approach][]

[Computer Architecture A quantitative Approach]: http://www.amazon.com/Computer-Architecture-Quantitative-Approach-Edition/dp/0123704901 
