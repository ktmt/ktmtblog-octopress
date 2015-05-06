---
layout: post
title: "Kipalog: Câu chuyện về viết và chia sẻ"
date: 2015-05-06 16:43
comments: true
categories: writing, programming, blogging, technical platform, KTMT, Kipalog
---

# Giới thiệu
Đầu tiên, chúng tôi muốn cảm ơn các bạn đọc đã gắn bó với KTMT trong suốt thời gian qua. Chúng tôi thật sự rất vui vì những kiến thức mình viết ra đã đem lại lợi ích cho một số lượng không nhỏ bạn đọc. Sự đón đọc của các bạn giúp chúng tôi thêm tin tưởng vào những việc chúng tôi đang thực hiện.

![](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_chuju0zn2l)

Hôm nay, chúng tôi muốn chia sẻ câu chuyện và những suy nghĩ của chúng tôi về việc **viết**, để qua đó thuyết phục các bạn về tầm quan trọng của việc chia sẻ kiến thức nói chung, và **viết lách** nói riêng.

# Vòng lặp

Trước khi viết KTMT, công việc hàng ngày của chúng tôi đã từng theo một vòng lặp như sau:

{% codeblock proc.sh %}
while (còn vấn đề kỹ thuật cần giải quyết) {
  while (chưa biết cách giải quyết) {
    Google   # Google trả lời bằng rất nhiều lời giải...
    foreach(kết quả) {
      Thử từng kết quả
    }
  }
}
{% endcodeblock %}

Chúng tôi nhận ra có rất nhiều vấn đề ở vòng lặp này: vấn đề tìm kiếm cũng như lời giải hoàn toàn vụn vặt và thiếu tính khái quát, cùng một vấn đề hoặc vấn đề tương tự nhau nhưng nhiều khi phải google rất nhiều, nhiều khi giải quyết được vấn đề nhưng đấy lại không phải là cách giải quyết tốt nhất, cách giải quyết tốt nhất nhiều khi lại đến từ bạn bè xung quanh mình.

Chúng tôi nhận thấy nếu như không tổng hợp lại những điều mình đã tìm hiểu thì sẽ không có cách nào nhớ được cách giải quyết. Cách đơn giản nhất mà chúng tôi đã nhận thấy là **viết** và **chia sẻ** cho bạn bè. **Viết** giúp tổng hợp các cách giải quyết vấn đề đồng thời giúp lưu lại cách giải quyết đó cho những lần sau. Viết cũng chính là **giải thích** lại vấn đề cho chính bản thân sau này. **Chia sẻ** giúp nhận được góp ý từ những người giỏi hơn mình. Do vậy chúng tôi đã bắt đầu blog KTMT. Giống như đã viết ở [KTMT blog nguồn mở](http://ktmt.github.io/blog/2015/03/08/ktmt-blog-nguon-mo/), chúng tôi nhận thấy chúng tôi dần dần thoát khỏi vòng lặp nói trên.

![](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_6ynsrhkggx)

# "Viết" có chắc chắn là cách giải quyết vấn đề?

* **Albert Einstein** đã từng nói:

![](https://s3-ap-southeast-1.amazonaws.com/kipalog.com/blob_t1aodwath4)

Để hiểu rõ một điều gì đó, hãy thử giải thích điều đó một cách **đơn giản** nhất.

* **Leslie B. Lamport** đã từng nói:

>If you're thinking without writing, you only think you're thinking.

Khi chúng ta không viết ra, chúng ta chỉ *tưởng* là chúng ta đã biết thôi. Thực sự là chúng ta là *chưa biết* gì cả.

*Hãy giải thích một cách đơn giản* và *hãy viết ra* là thông điệp của 2 vĩ nhân trên. Do vậy chúng tôi tin tưởng viết chính là cách giải quyết cho vấn đề của chúng tôi.

# Viết liệu có khó khăn ?

Bắt đầu viết không hề đơn giản. Chúng tôi đã từng [thử khảo sát](http://ktmt.github.io/blog/2014/09/08/tong-ket-ban-dieu-tra-ve-thoi-quen-programmer-cua-blog-ktmt/) và nhận ra viết lách thật sự không hề dễ. Các bạn trả lời cho điều tra trên gặp những vấn đề sau đây:

#### Suy nghĩ: "Chỉ chuyên gia mới viết được bài viết kĩ thuật ?"

> Tôi không phải là một chuyên gia về một vấn đề gì cả, vậy nên chả biết viết về cái gì cả!!

Đây có lẽ là một lý do thiếu thuyết phục nhất. Bạn không cần phải là chuyên gia mới viết được blog. Trong 85 bài viết của KTMT blog, có những chủ đề mà chúng tôi hoàn toàn chưa hiểu rõ, cho đến khi bắt tay vào viết và tìm hiểu để viết ra. Và chính nhờ việc nghiên cứu rất nhiều để viết ra một thứ gì đó, đã giúp chúng tôi hiểu ra rất nhiều điều.

#### Viết sai làm tôi trông như một đứa ngớ ngẩn ?

> Nếu tôi viết một thứ gì đó không đúng, hay viết sai, tôi sẽ bị nhìn như một thằng đần trên internet

Đây có lẽ là một lý do làm nhiều bạn "sợ" viết nhất. Chúng tôi cũng như bạn, chúng tôi cũng dễ mắc phải các sai lầm. Không phải 100% kiến thức chúng tôi viết ra ngay lần đầu tiên là chính xác. Và chính các bạn, những người đọc là những người giúp chúng tôi nhận ra điều đó, trách nhiệm của chúng tôi là sửa lại cho đúng. Vậy ai là người có lợi ở đây: người viết ra, hay người không viết ra ? Chắc các bạn có thể tự trả lời được câu hỏi này.

> Điều quan trọng nhất tự việc nhầm lẫn (make mistake) là việc thu dọn những nhầm lẫn đó, và học những điều mới từ nó.

#### Viết tốt quá khó !

> Tôi có thể code tốt, nhưng viết thì chịu, viết  câu cú đúng ngữ pháp, có nội dung hợp lý với tôi như một cực hình.

Cái này chúng tôi hoàn toàn đông ý với bạn. Viết tốt là một trong những điều khó nhất mà tôi từng biết. Viết để cho mình hiểu đã khó, cho người khác, đặc biệt là cho những người không cùng kĩ năng với bạn hiểu được còn khó hơn.
Tuy nhiên trong công việc hàng ngày, 50% việc bạn phải là là **giao tiếp**.
Và giao tiếp chính là "nói cái mình hiểu cho người khác hiểu". Việc tập luyện kĩ năng "viết" cho "người khác hiểu" chính là giúp tăng kĩ năng giao tiếp của bạn lên. Hãy kiên trì và sẽ đến một lúc các bạn nhận ra rằng việc **viết tốt** giúp bạn nhiều đến thế nào.

Chúng tôi hy vọng bài viết đến đây đã giúp truyền tải được phần nào những gì chúng tôi đang suy nghĩ về việc chia sẻ các vấn đề kĩ thuật mà mình biết bằng cách viết ra.
Chính vì tầm quan trọng của việc viết và chia sẻ các kiến thức kĩ thuật, và muốn phủ rộng hơn văn hoá viết ra và chia sẻ với cộng đồng kĩ thuật tại Việt Nam nói chung, chúng tôi đã quyết định làm một điều lớn hơn là chỉ [open blog](http://ktmt.github.io/blog/2015/03/08/ktmt-blog-nguon-mo/).

# Ngôi nhà mới [kipalog.com](http://kipalog.com)

Chúng tôi đã quyết định xây dựng một nền tảng, mà ở đó ai cũng có thể viết để chia sẻ kiến thức của mình một cách dễ dàng, có thể tìm kiếm và học hỏi kiến thức có chất lượng từ những người cùng làm kĩ thuật chuyện nghiệp khác. Bạn hãy tưởng tượng đó là một *kho* kiến thức chất lượng cao, một môi trường cởi mở và tôn trọng lẫn nhau của những người có cùng niềm đam mê về kĩ thuật.

Nền tảng được đặt tên là **Kipalog** và đặt tại trang web: [http://kipalog.com](http://kipalog.com)

Kipalog là cách gọi tắt của "keep a log", cũng chính là khái niệm chủ đạo của nền tảng này, coi trọng việc "log" hay là giữ lại các kiến thức của bạn bằng cách "viết ra".

Vậy bạn có thể làm gì với Kipalog:

- Bạn có thể **viết** để chia sẻ kiến thức kĩ thuật của bạn với người khác. Chúng tôi cung cấp cho bạn trình soạn thảo markdown với khả năng hiển thị trực quan theo 2 cột, kéo thả / cắt dán ảnh trực tiếp và nhiều tiện ích khác, giúp bạn cảm thấy thoải mái khi viết một tài liệu kĩ thuật.
- Bạn có thể đọc, học hỏi và **kipalog** kiến thức của người khác. Việc **kipalog** giúp bạn giữ lại những kiến thức cần thiết cho bản thân để có thể tìm lại dễ dàng về sau.
- Bạn có thể trao đổi, cung cấp phản hồi cho các bạn khác. Nếu bạn có cách giải quyết tốt hơn, hãy đóng góp thông qua bình luận. Bản thân bình luận cũng có thể viết bằng markdown.
- Các công ty và tổ chức chia sẻ công nghệ cũng như kinh nghiệm của bản thân công ty mình, đồng thời thu lợi được công nghệ và kinh nghiệm từ các công ty và tổ chức khác.

Tại sao bạn nên bắt tay vào đăng ký và viết bài trên Kipalog:

- Tại Kipalog chúng tôi đảm bảo việc chia sẻ và phản hồi dựa trên tinh thần tôn trọng lẫn nhau. Bạn có thể chia sẻ những gì mình biết mà không sợ bị "ném đá" hay coi thường.
- Bạn có thể tạo được *portfolio cá nhân* dựa trên những gì bạn biết và viết ra. Những bài viết tốt, chứ không phải là số năm kinh nghiệm, thể hiện bạn là một kĩ sư chuyên nghiệp và có trình độ cao.
- Bạn sẽ có cơ hội kết bạn và giao lưu với những người cùng đam mê kĩ thuật khác (trong đó có những người viết của chính blog KTMT).

# Vậy KTMT sẽ ra sao?

Chúng tôi sẽ chuyển blog KTMT thành một **tổ chức** trên Kipalog.

> [http://kipalog.com/organizations/KTMT](http://kipalog.com/organizations/KTMT)

Blog KTMT sẽ vẫn được giữ ở trạng thái hoạt động, nhưng sẽ không cập nhật các bài viết mới. Các bài viết mới sẽ được viết dưới tổ chức KTMT. Bạn nào muốn viết blog cho KTMT có thể tham gia tổ chức KTMT trên Kipalog cùng chúng tôi.

# Kết luận

Chúng tôi hy vọng bạn sẽ thích Kipalog. Trên hơn cả, chúng tôi hy vọng các bạn xem Kipalog **không chỉ là nơi để đọc**, mà còn là nơi các bạn **tích cực chia sẻ** vốn kiến thức của bản thân.

Cám ơn các bạn. Đón đọc những tri thức của bạn tại [kipalog.com](http://kipalog.com) :)
