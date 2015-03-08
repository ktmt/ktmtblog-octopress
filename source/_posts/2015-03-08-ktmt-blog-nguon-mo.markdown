---
layout: post
title: "KTMT: Blog nguồn mở"
date: 2015-03-08 12:56
comments: true
categories:
  - other
---

>"If you're thinking without writing, you only think you're thinking." -- Lessie Lamport

# Giới thiệu

Mình rất thích câu nói trên của Lamport. Đối với mình câu nói trên hay ở chỗ: vế sau của câu là một cách nói đệ quy. "Bạn chỉ nghĩ rằng là bạn đang suy nghĩ". Suy nghĩ là để tìm ra câu trả lời cho một câu hỏi nào đó. Nhưng nếu không có việc viết lách, đối tượng của suy nghĩ sẽ chỉ đơn thuần là "sự suy nghĩ" - và chúc mừng bạn, bạn rơi vào vòng lặp đệ quy vô hạn. Cách duy nhất để bạn thoát khỏi vòng lặp đệ quy vô hạn của suy nghĩ là phải định nghĩa một điểm khởi đầu trong tư duy. Viết lách chính là điểm khởi đầu đó.

Blog ktmt cũng bắt đầu với một ý tuởng đơn giản như ở trên: một chỗ để các thành viên viết và chia sẻ cho những thành viên khác điều mình học đuợc. Bài viết không cần phức tạp, chỉ cần có nội dung liên quan đến kỹ thuật là được chấp nhận. "Muốn chia sẻ điều mình học đuợc?" - Hãy viết một bài về chủ đề đó và các thành viên khác sẽ đọc. Ý tuởng thì là vậy nhưng thực hiện đuợc nó thật sự rất gian nan. Khi thực sự viết ra, bọn mình mới thấy để viết đuợc một bài cần đầu tư rất nhiều thời gian, từ nghiên cứu cho đến viết code mẫu để demo cho bài viết. Tuy vậy nhờ việc viết ra những điều *mình tuởng là biết* bọn mình khám phá ra có rất nhiều chỗ bọn mình chưa thực sự *biết như mình tuởng*. Mỗi câu văn khó hiểu cho người đọc thật sự không chỉ do cách viết mà còn do sự thiếu tuờng tận và am hiểu về chủ đề đuợc viết. Cứ mỗi bài viết, bọn mình là đọc rất kỹ, kiểm tra cho nhau và đưa ra những góp ý sửa chữa cho nhau. Nhờ vậy am hiểu của ngưòi viết về chủ đề đang viết cũng như nguời đọc trở nên sâu sắc hơn.

Bọn mình đưa bài lên một blog chỉ đơn giản với mục đích cho các thành viên khác đọc và góp ý. Thế nhưng dần dần bọn mình nhân ra rằng không chỉ cá nhân nhóm tác giả mà còn rất nhiều bạn đọc khác cũng đọc và góp ý. Bài viết của bọn mình một phần nào đó đã đem lại ích lợi cho cho cộng đồng. Ngoài ra bọn mình cũng nhận được nhiều đóng góp cũng như câu hỏi từ bạn đọc. Những đóng góp và câu hỏi giúp bọn mình rất nhiều trong việc hiểu sâu sắc hơn chủ đề mỗi bài viết. Bọn mình nhận thấy bọn mình không những học đuợc lẫn nhau mà còn học đuợc từ rất nhiều bạn đọc khác - điều bọn mình rất vui.

Gần đây bọn mình nhận đuợc nhiều ý kiến đề xuất đóng góp bài viết. "Sao không!" là câu nói đầu tiên xuất hiện trong đầu của tất cả các thành viên blog ktmt. Đối với bọn mình đây là điều không gì vui hơn. Blog sẽ có nhiều bài viết mới từ nhiều góc độ suy nghĩ cũng như kiến thức hơn (và bọn mình sẽ có cơ hội học được từ nhiều ngưòi hơn). Các bạn tác giả sẽ có nơi để luyện tập viết lách. Độc giả sẽ có nhiều bài viết để đọc hơn. Sau khi cân nhắc nhiều yếu tố - hầu hết chỉ có lợi - bọn mình đi đến quyết định:

Biến ktmt trở thành một blog cộng đồng!

# Mở rộng blog KTMT

Blog ktmt sẽ không chỉ bao gồm bài viết của nhóm tác giả hiện tại mà sẽ nhận bài viết từ tất cả các bạn nào muốn đóng góp. Mỗi bài viết của KTMT đều đuợc viết bằng [ngữ pháp Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet), sử dụng [Octopress](http://octopress.org/) để biên tập và chia sẻ trên máy chủ của [github](http://github.com). Về cách sử dụng các tool này các bạn có thể tham khảo: [Blogging With Github and Octopress](http://ktmt.github.io/blog/2013/04/30/huong-dan-su-dung-octopress-cho-blog-tren-github/). Để giữ blog không thay đổi quá nhiều ở giai đoạn đầu, bọn mình quyết định quy trình đóng góp bài viết như sau:

* Fork https://github.com/ktmt/ktmtblog-octopress/
* Viết bài mới.
* Tạo Pull Request đến repository của KTMT.
* "Ban biên tập" sẽ tiến hành biên tập và góp ý công khai trên Pull Request.
* Các bài viết đáp ứng đuợc yêu cầu sẽ được merge và đưa lên blog KTMT.

Tiêu chí biên tập là điều bọn mình đã suy nghĩ nhưng vẫn chưa tìm ra đuợc những tiêu chí xác đáng. Vì vậy truớc mắt bọn mình tạm đề ra các tiêu chí biên tập như duới đây:

* Bài viết phải có nội dung về kỹ thuật và máy tính. Bài viết nên viết về chủ đề mà tác giả đã hoặc đang nghiên cứu. Bài viết nên đuợc đầu tư thời gian về ý tuởng và cách diễn đạt. Bài viết có tính mới mẻ và sáng tạo là hoàn hảo!
* Bài viết nên đuợc viết bằng tiếng Việt và có bố cục rõ ràng.
* Bài viết nếu có mã nguồn demo thì càng tốt. Linux Torvalds đã từng nói: "Talk is cheap. Show me the code". Mã nguồn chuơng trình chạy được sẽ như một bức tranh đáng giá hàng ngàn từ ngữ.

Ngoài ra bọn mình cũng đã thiết lập [một trang Facebook group của blog](https://www.facebook.com/groups/714123448709763/). Các thảo luận xung quanh bài viết sẽ đuợc thực hiện thông qua page này.


# Ban biên tập

Trước mắt ban biên tập sẽ chỉ bao gốm những thành viên đóng góp thuờng xuyên của KTMT:

* [dtvd](https://github.com/dtvd)
* [huydx](https://github.com/huydx)
* [kiennt](https://github.com/kiennt)
* [viethnguyen](https://github.com/viethnguyen)
* [telescreen](https://github.com/telescreen)


Trong tuơng lai bọn mình muốn sẽ có những thành viên xuất sắc trong biên tập. Vì vậy bọn mình tạm đề ra một tiêu chí để tham gia ban biên tập như sau:

***"Là một thành viên đóng góp thuờng xuyên và có nhiều bài viết tốt cho blog KTMT".***

Thành viên nào đóng góp đuợc 5 bài viết sẽ đuợc tính là thành viên thường xuyên. Về tiêu chí bài viết tốt, bọn mình hiện đang trong quá trình xây dựng cách đánh giá cho tiêu chí này.


# Kết thúc

Bọn mình mong chờ nhiều bài viết tốt hơn nữa từ các bạn!

# Tham khảo

1. [Bài phát biểu của Lessie Lamport](http://channel9.msdn.com/Events/Build/2014/3-642)
2. [Những câu nói của Linus Torvalds](http://en.wikiquote.org/wiki/Linus_Torvalds)
