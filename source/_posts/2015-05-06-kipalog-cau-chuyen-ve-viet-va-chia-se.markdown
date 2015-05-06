---
layout: post
title: "Kipalog: Câu chuyện về viết và chia sẻ"
date: 2015-05-06 16:43
comments: true
categories:
---

# Giới thiệu
Đầu tiên, chúng tôi muốn cảm ơn các bạn đọc đã gắn bó với ktmt trong suốt thời gian qua. Chúng tôi thật sự rất vui vì những kiến thức mình viết ra đã đem lại lợi ích cho một số lượng không nhỏ bạn đọc. Sự đón đọc của các bạn giúp chúng tôi thêm tin tưởng vào những việc chúng tôi đang thực hiện.

![Thank you](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_chuju0zn2l)

Hôm nay, chúng tôi muốn chia sẻ câu chuyện và những suy nghĩ của chúng tôi về việc **viết**, để qua đó thuyết phục các bạn về tầm quan trọng của việc chia sẻ kiến thức nói chung, và **viết lách** nói riêng.

# Vòng lặp

Trước khi viết ktmt, công việc hàng ngày của chúng tôi đã từng theo một vòng lặp như sau:

{% codeblock proc.sh %}
  while (còn vấn đề kỹ thuật cần giải quyết) {
    while (chưa biết cách giải quyết) {
      Google   #google trả lời bằng rất nhiều lời giải...
      foreach(kết quả)
      Thử từng kết quả
    }
  }
{% endcodeblock %}

Chúng tôi nhận ra có rất nhiều vấn đề ở vòng lặp này.
- Vấn đề tìm kiếm cũng như lời giải hoàn toàn vụn vặt và thiếu tính khái quát.
- Cùng một vấn đề hoặc vấn đề tương tự nhau nhưng nhiều khi phải google rất nhiều.
- Nhiều khi giải quyết được vấn đề nhưng đấy lại không phải là cách giải quyết tốt nhất. Cách giải quyết tốt nhất nhiều khi lại đến từ bạn bè xung quanh mình.

Chúng tôi nhận thấy nếu như không tổng hợp lại những điều mình đã tìm hiểu, chúng tôi sẽ không co cách nào nhớ được cách giải quyết. Cách đơn giản nhất mà chúng tôi đã nhận thấy là ***viết*** và ***chia sẻ*** cho bạn bè. ***Viết*** giúp chúng tôi tổng hợp các cách giải quyết vấn đề đồng thời giúp chúng tôi lưu lại cách giải quyết đó cho những lần sau. Viết cũng chính là **giải thích** lại vấn đề cho chính bản thân sau này. Chia sẻ giúp chúng tôi nhận được feedback nhanh chóng từ những người giỏi hơn mình. Do vậy chúng tôi đã bắt đầu blog ktmt. Giống như đã viết ở [ktmt blog nguồn mở](http://ktmt.github.io/blog/2015/03/08/ktmt-blog-nguon-mo/), chúng tôi nhận thấy chúng tôi dần dần thoát khỏi vòng lặp trên.

![](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_6ynsrhkggx)

# "Viết" có chắc chắn là cách giải quyết vấn đề?

* **Albert Einstein** đã từng nói:

![If you can't explain it simply, you don't understand it well enough](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_t1aodwath4)

Để hiểu rõ một điều gì đó, hãy "thử giải thích" điều đó một cách **đơn giản** nhất.

* **Leslie B. Lamport** đã từng nói:

![If you’re thinking without writing, you only think you’re thinking.](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_q6wz91nezj)

Khi chúng ta không viết ra, chúng ta chỉ **tưởng** là chúng ta đã biết thôi. Thực sự là chúng ta là **chưa biết** gì cả.

Hãy giải thích một cách đơn giản và hãy viết ra là thông điệp của 2 vĩ nhân trên. Do vậy chúng tôi tin tưởng viết chính là cách giải quyết cho vấn đề của chúng tôi.

# Viết liệu có khó khăn.

Bắt đầu viết không hề đơn giản. Chúng tôi đã từng [thử khảo sát](http://ktmt.github.io/blog/2014/09/08/tong-ket-ban-dieu-tra-ve-thoi-quen-programmer-cua-blog-ktmt/) và nhận ra viết lách thật sự không hề dễ. Các bạn trả lời cho điều tra trên gặp những vấn đề sau đây:

#### Suy nghĩ: "Chỉ chuyên gia mới viết được bài viết kĩ thuật?"

> Tôi không phải là một chuyên gia về một vấn đề gì cả, vậy nên chả biết viết về cái gì cả!!

Đây có lẽ là một lý do thiếu thuyết phục nhất. Bạn không cần phải là chuyên gia mới viết được blog. Trong 85 bài viết của ktmt blog, có những chủ đề mà chúng tôi hoàn toàn chưa hiểu rõ, cho đến khi bắt tay vào viết và tìm hiểu để viết ra. Và chính nhờ việc nghiên cứu rất nhiều để viết ra một thứ gì đó, đã giúp chúng tôi hiểu ra rất nhiều điều.

#### Viết sai làm tôi trong như một đứa ngớ ngẩn?

> Nếu tôi viết một thứ gì đó không đúng, hay viết sai, tôi sẽ bị nhìn như một thằng đần trên internet

Đây có lẽ là một lý do làm nhiều bạn "sợ" viết nhất. Chúng tôi cũng như bạn, chúng tôi cũng dễ mắc phải các sai lầm. Không phải 100% kiến thức chúng tôi viết ra ngay lần đầu tiên là chính xác. Và chính các bạn, những người đọc là những người giúp chung tôi nhận ra điều đó, và trách nhiệm của chúng tôi là sửa lại cho đúng. Vậy ai là người có lợi ở đây: người viết ra, hay người không viết ra? Chắc các bạn có thể tự trả lời được câu hỏi này.

> Điều quan trọng nhất tự việc nhầm lẫn (make mistake) là việc thu dọn những nhầm lẫn đó, và học những điều mới từ nó.

#### Viết tốt quá khó!

> Tôi có thể code tốt, nhưng viết thì chịu, viết  câu cú đúng ngữ pháp, có nội dung hợp lý với tôi như một cực hình.

Cái này chúng tôi hoàn toàn đông ý với bạn. Viết tốt là một trong những điều khó nhất mà tôi từng biết. Viết để cho mình hiểu đã khó, cho người khác, đặc biệt là cho những người không cùng kĩ năng với bạn hiểu được còn khó hơn.
Tuy nhiên trong công việc hàng ngày, 50% việc bạn phải là là **giao tiếp**.
Và giao tiếp chính là "nói cái mình hiểu cho người khác hiểu". Việc tập luyện kĩ năng "viết" cho "người khác hiểu" chính là giúp tăng kĩ năng giao tiếp của bạn lên. Hãy kiên trì và sẽ đến một lúc các bạn nhận ra rằng việc **viết tốt** giúp bạn nhiều đến thế nào.

Bởi vì viết và chia sẻ là khá khó khăn, nên nếu có một nơi viết và chia sẻ trở nên thật sự đơn giản thì sao?

# Ngôi nhà mới [kipalog.com](http://kipalog.com)

Chính vì tầm quan trọng của việc viết và chia sẻ các kiến thức kĩ thuật, và muốn phủ rộng hơn văn hoá viết ra và chia sẻ với cộng đồng kĩ thuật tại Việt Nam nói chung, chúng tôi đã quyết định làm một điều lớn hơn chỉ là [open blog](http://ktmt.github.io/blog/2015/03/08/ktmt-blog-nguon-mo/).

Chúng tôi đã quyết định xây dựng một nền tảng, mà ở đó ai cũng có thể viết được, và chia sẻ những kiến thức kĩ thuật của mình một cách dễ dàng nhất. Chúng tôi đặt tên nền tảng đó là **Kipalog**.
Nền tảng được đặt tại trang web: [http://kipalog.com](http://kipalog.com)

Kipalog là cách gọi tắt của "keep a log", cũng chính là khái niệm chủ đạo của nền tảng này. Đó là coi trọng việc "log" hay là giữ lại các kiến thức của bạn bằng cách "viết ra".

Vậy bạn có thể làm gì với kipalog:

- Bạn có thể **viết** để chia sẻ kiến thức kĩ thuật của bạn với người khác. Chúng tôi cung cấp cho bạn editor sử dụng markdown với live rendering, syntax highlight và nhiều tiện ích khác, giúp bạn cảm thấy thoải mái khi viết một tài liệu kĩ thuật.
- Bạn có thể **kipalog** kiến thức của người khác. Việc kipalog giúp bạn giữ lại những kiến thức cần thiết cho bản thân, để có thể tìm lại dễ dàng về sau.
- Trao đổi, cung cấp feedback cho các bạn khác. Nếu bạn có cách giải quyết tốt hơn, hãy đóng góp thông qua bình luận.
- Các công ty và tổ chức chia sẻ công nghệ cũng như kinh nghiệm của bản thân công ty mình, đồng thời thu lợi được từ các công ty và tổ chức khác.

Chúng tôi hy vọng kipalog sẽ trở thành

- Nơi để những người làm kĩ thuật chuyên nghiệp ở Việt Nam trao đổi kiến thức.
- Sẽ thành một **Kho** kiến thức có ích cho tất cả những người làm kĩ thuật.

Tại sao bạn nên bắt tay vào đăng ký và viết bài trên kipalog sớm nhất có thể
- Tại kipalog chúng tôi đảm bảo việc chia sẻ và feedback dựa trên tinh thần tôn trọng lẫn nhau. Bạn có thể chia sẻ những gì mình biết mà không sợ bị "ném đá" hay coi thường.
- Bạn có thể tạo được portfolio cá nhân dựa trên những gì bạn biết và viết ra. Những bài viết tốt là cách tốt nhất để thể hiện một kĩ sư chuyên nghiệp, chứ không phải là những số năm kinh nghiệp vô giá trị.
- Bạn sẽ có cơ hội kết bạn và giao lưu với những người cùng đam mê kĩ thuật khác (trong đó có những editor chính của blog ktmt).

# Vậy KTMT sẽ ra sao?

Chúng tôi sẽ chuyển thành một **tổ chức** ở trên kipalog.com.

> [http://kipalog.com/organizations/KTMT](http://kipalog.com/organizations/KTMT)

Blog ktmt sẽ vẫn được giữ ở trạng thái hoạt động, nhưng sẽ không cập nhật các bài viết mới. Các bài viết mới sẽ được viết dưới tổ chức KTMT. Bạn nào muốn viết blog cho KTMT có thể tham gia tổ chức KTMT trên kipalog cùng chúng tôi!

# Kết luận

Chúng tôi hy vọng bạn sẽ thích kipalog. Trên hơn cả, chúng tôi hy vọng các bạn xem kipalog **không chỉ là nơi để đọc**, mà còn là nơi các bạn **tích cực chia sẻ** vốn kiến thức của bản thân.

Cám ơn các bạn. Đón đọc những tri thức của bạn tại kipalog.com!
