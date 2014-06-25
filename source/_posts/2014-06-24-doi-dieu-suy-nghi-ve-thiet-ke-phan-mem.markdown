---
layout: post
title: "Đôi điều suy nghĩ về thiết kế phần mềm"
date: 2014-06-24 20:11
comments: true
categories: 
- thinking
---

Là một lập trình viên, công việc hàng ngày của bạn là viết code.
Viết code cũng như xây dựng vậy, bạn phải đắp từng viên gạch để xây nên một ngôi nhà.
Một ngôi nhà có chắc chắn và dễ thay đổi hay không không chỉ dựa vào việc bạn có dùng gạch tốt hay không, mà còn phụ thuộc rất lớn vào nhà thiết kế.

Gần đây tôi có đọc cuốn sách tựa đề ['Practical Object Oriented Design in Ruby'](http://www.poodr.com/) của Sandi Metz, một diễn giả ưa thích của tôi. Cuốn sách dành phần lớn để nói về các kĩ thuật thiết kế phần mềm với đối tượng là ngôn ngữ là Ruby.
Tuy nhiên có rất nhiều ý tưởng của tác giả mà không chỉ giới hạn ở Ruby nói chung mà có thể áp dụng cho bất kì ngôn ngữ nào. Trong bài viết này tôi sẽ liệt kê ra một số ý trong cuốn sách mà tôi thấy rất hay và đáng nhớ.

#Why
Hãy bắt đầu từ việc **tại sao nên dành thời gian cho việc thiết kế phần mềm**:
  
- Việc nên dành một khoảng thời gian tương đối cho việc thiết kế phần mềm một cách nghiêm chỉnh hay không phụ thuộc vào việc: Logic mà bạn sẽ viết có tầm ảnh hưởng như thế nào đến hiện tại và tương lai. Ảnh hưởng đến hiện tại là nhiều khi một tính năng có ngay lập tức là quan trọng hơn cả. Ảnh hưởng đến tương lai là khi mà tính năng mà bạn code một cách cẩu thả sẽ ảnh hưởng vô cùng lớn đến tốc độ phát triển trong tương lai, gây ra các lỗi nghiêm trọng. Hãy nhìn việc thiết kế nghiêm chỉnh hay không như là một **món nợ kĩ thuật** (technical debt). Bạn thiết kế cẩu thả ở thời điểm hiện tại cũng như là bạn vay mượn thời gian ở tương lai vậy. Nếu khoảng thời gian đó không đến thì sẽ không sao, nhưng nếu đằng nào nó cũng xảy đến thì hãy suy nghĩ thật kĩ, bạn có thể đang làm mất thời gian trong tương lai của mình đó :).

#How
Vậy việc nên dành thời gian nghiêm chỉnh để thiết kế phần mêm là nên, thì chúng ta **nên thiết kế theo phương pháp thế nào**:

- Từ xưa, việc thiết kế phần mêm thường được thực hiện theo mô hình thác nước (water flow). Mô hình này được tiến hành từ trên cao xuống thấp qua các bước như nhận yêu cầu (requirement), thiết kế kiến trúc (architecture design), thiết kế cơ bản (Basic design).. Tuy nhiên mô hình này đòi hỏi bạn phải nắm rõ 90% yêu cẩu của dự án ngày từ đầu, và việc này gần như là không thể. Do đó gần đây xu hướng là **Agile development**, khi mà việc phát triển chia thành nhiều chặng nhỏ, mỗi chặng sẽ có yêu cầu rõ ràng, và qua mỗi chặng sẽ đánh giá lại tính khả thi của dự án và đưa ra yêu cầu cho chặng tiếp theo. Về cơ bản thì Agile development có tính khả thi hơn cả khi mà không ai có thể đoán trước được sản phẩm đầu ra khi nào sẽ hoàn thành và nên có tính năng ra sao.


#Detail
Khi đã quyết được phương pháp thiết kế, việc quan trọng nhất, khó nhất, đó là bắt tay vào làm, bắt tay vào thiết kế chương trình. Để làm được việc này tốt quả thật là rất khó, bởi vì không có một tiêu chuẩn chung nào có thể áp dụng cho mọi yêu cầu, mọi chương trình. Bản thân tôi cũng là một junior software developer, nên tôi luôn gặp khó khăn mỗi khi viết một chương trình từ đầu (from the scratch). Có rất nhiều cách để giảm khó khăn, và tăng khả năng thiết kế của bạn như: nắm vững về các design pattern, nắm vững về domain logic, đọc về kiến trúc của các phần mêm open source nổi tiếng, và sử dụng các "luật" về thiết kế. Ở dưới đây tôi sẽ nói về một số "luật" mà cuốn sách đề cập đến, mà bản thân tôi thấy khá hữu dụng.

- Rule 1: Nền tảng cơ bản của việt thiết kế hướng đối tượng, là việc các đối tượng thao tác với nhau qua việc gửi thông điệp (sending message). Do đó mà việc thiết kế một phần mêm sẽ xoay quanh việc bạn thiết kế sao cho các đối tượng **gửi thông điệp cho nhau thông qua một interface dễ hiểu nhất, rõ ràng nhất**. Hãy luôn hình dung bài toán của bạn sẽ được giải quyết thông qua một loạt các đối tượng gửi rất nhiều loại thông điệp cho nhau, bạn sẽ hình dung được kiến trúc tổng thể của chương trình dễ dàng hơn.

- Rule 2: Single Responsibility: Đây là một luật khá cơ bản trong thiết kế hướng đối tượng. Ai cũng biết về luật này nhưng rất khó để làm theo, nhất là khi khối lượng chương trình tăng lên, và công việc chính của bạn hàng ngày là thêm logic vào một code base đã có. Luật này nói rằng mỗi class chỉ nên đảm trách một vai trò duy nhất. Làm thế nào để đảm bảo tính chất này là một việc khá mơ hồ. Cuốn sách nói rằng với mỗi class, bạn nên có thử **mô tả về nó chỉ trong 1 câu**. Làm được việc này một cách dễ dàng đảm bảo cho việc logic của class đó thống nhất và không bị lai tạp.

- Rule 3: Giảm sự kết dính của code (**Writing loosely coupled code**). Cá nhân tôi thấy rule này là rule quan trọng bậc nhất trong việc thiết kế phần mềm. Muốn đánh giá một phần mềm được thiết kế tồi hay không, hãy nhìn vào việc các logic có bị kết dính(couple) hay phụ thuộc vào nhau hay không. Vậy các bạn sẽ hỏi "kết dính" cụ thể ở đây có nghĩa là gì? Sự kết dính được hình thành khi logic này "phụ thuộc" vào logic khác. Cụ thể hơn ở khái niệm phụ thuộc, đó là việc mà khi mà một trong **logic của class A lại chứa các logic class B**, hay nói cách khác là khi A "biết" quá nhiều về B thì khi đó A sẽ phụ thuộc vào B. Khái niệm này hay được nhắc đến bằng những cụm từ khác như là logic hiding, tức khi thiết kế một class, bạn phải giấu logic của class đó càng nhiều càng tốt. Đó chính là lý do tại sao các ngôn ngữ như java có những keyword như public, private hay protected. Vậy quay lại từ đầu, để giảm sự kết dính của code thì chúng ta phải làm một việc là thiết kế sao cho các class không phụ thuộc vào nhau, và **"biết"** càng ít về nhau càng tốt. Vì vậy mỗi khi bạn viết một đoạn code nào đó, bạn hãy tự đọc lại và xem đoạn code đó có sử dụng quá nhiều logic của một class hay logic bên ngoài không. Để giải quyết cho việc "writing loosely coupled code" thì có khá nhiều kĩ thuật nổi tiếng như là: Inject Dependencies, Isolate Dependencies, Reversing Dependencies mà nếu có dịp tôi sẽ giới thiệu trong một bài viết khác. Ngoài ra còn có một luật rất hữu dụng để giải quyết vấn đề kết dính của code được gọi là [Law of Demeter](http://c2.com/cgi/wiki?LawOfDemeter), các bạn có thể tham khảo ở đường link tôi vừa gửi.


#Conclusion
Ở trên tôi đã trình bày về một số suy nghĩ của cá nhân về thiết kế phần mềm. Bản thân việc thiết kế được phần mềm tốt là rất khó, mà mỗi một dạng phần mềm, với mỗi một logic domain lại có một cách giải quyết riêng. Không có một cách giải quyết nào chung cho mọi bài toán cả, nhưng có một số qui tắc chung mà bán có thể áp dụng được cho nhiều bài toán khác nhau. Để nắm được các qui tắc đó đòi hỏi bạn không những phải đọc nhiều, làm nhiều, tích luỹ nhiều kinh nghiệm, mà còn dựa trên việc bạn thất bại nhiều nữa. Tạo ra các phần mềm tồi, khó bảo trì cũng là một bước đệm tốt để bạn rút kinh nghiệm cho các lần sau :).
