---
layout: post
title: "Web Beacon và cookie"
date: 2013-05-18 15:27
comments: true
categories: 
  - Web programming 
---


## Web Beacon là gì ##

Web Beacon, hay Web Bug là 1 khái niệm với 2 tên gọi khác nhau.
Có thể bạn chưa từng nghe nói đến, hay đã nghe nhưng ko hiểu rõ lắm về cụm từ này. Trước hết mình sẽ lấy định nghĩa trên Wikipedia xuống để dễ theo dõi

> A web bug is an object that is embedded in a web page or email and is usually invisible to the user but allows checking that a user has viewed the page or email. Common uses are email tracking and page tagging for Web analytics

Như vậy, Web beacon là 1 technique trong web programming, mục đích là phục vụ cho web data analytics. 

Tại sao lại cần phải có web beacon ? Cách implement web beacon ra sao ? Bài viết này sẽ trả lời 2 câu hỏi trên và 2 khái niệm liên quan thông qua các ví dụ và hình dung cụ thể.


## Tại sao lại phải có web beacon ? ##

Nếu bạn đã từng tự xây dựng 1 web application, deploy trên server của chính bạn - bravo - bạn đã có sản phẩm của chính bạn - đứa con tinh thần đầu tiên :D

Now what ? Bạn muốn application của mình to hơn, lớn nữa, performance cao lên, vậy sẽ bắt đầu phải scale up, add feature, brainstorming để **lôi kéo user**.

Phần khó khăn nhất ở đây - Long live the users :D Application cần có nhiều idea mới. Hoặc đơn giản, không có thứ gì interesting thì phải có link đến những web khác có interesting content. 
Vậy, **làm thế nào** để biết user cảm thấy interesting với content nào nhất ? User hứng thú với dịch vụ gì và không hứng thú với dịch vụ gì ?

1 cách mô hình hoá, Website của bạn - website A có link đến website N1, N2, N3, ... (các site có intersting content) 
Bạn - site A webmaster muốn biết user của bạn click vào những link nào nhiều nhất trong số các N-site. 
Dĩ nhiên là site nào ít attractive nhất thì muốn bỏ đi, site nào càng nhiều attractive thì tìm thêm các loại tương ứng. 
Mặc dù khi user click vào các link thì đã ra khỏi site của bạn và đi đến site khác, nhưng bạn có thể **đặt web beacon ở từng link** để tracking user của bạn.

Ngược lại, giả sử vì mục đích quảng cáo, site N của bạn đặt link (banner) ở các site A1, A2, A3,.... 
Đổi lại bạn đang trả tiền cho tất cả. 
Dĩ nhiên bạn muốn biết user visit site của mình đến từ nơi nào nhiều nhất. 
Nơi nào user ko đến thì cắt bỏ để giảm chi phí v.v... 
Bạn có thể **đặt web beacon ở cổng vào site mình** và record lại các information bạn cần. 


## Implement Web Beacon ##

Trước hết, Web beacon thường được implement dưới dạng 1 file gif 1x1 pixel, gần như trong suốt với user và giảm tối đa load mỗi lần generate ra request với server.
 
Trường hợp 1 ở bên trên, cách implement khá đơn giản: Mỗi link đến các website N1, N2, N3... có để đặt gán với 1 hàm javascript, khởi động 1 ajax request đến server của site mình kèm theo các thông tin hữu ích (IP của user, target website v.v...) 
Nội dung request là GET web beacon (request file fig 1x1 pixel) Như thế server site mình sẽ mất thêm lượng tải tối thiếu cho mục đích tracking.

Cách viết cụ thể ajax request và xử lý cookie phía server sẽ không trình bày cụ thể ở bài viết này. 

Trường hợp 2, cần có 1 chút lưu ý. Các site A1, A2, A3,... bạn đặt banner cần phải có 1 param ghi lại domain của họ, ví dụ:

{% codeblock siteA.html %}
<form method = "GET" action = "www.your_site.com">
<input type="hidden" name="callback_url" value="domain_of_this_site">
</form>
{% endcodeblock %}

Như vậy user đi đến site N của bạn sẽ mang theo "callback_url". Ở cổng vào site của bạn có thể đặt 1 beacon như sau

{% codeblock siteN.html %}
<img src="/img/_.gif?from_=<?php $_GET["callback_url"];?>&_=<?php date("Y-m-d H:i:s");?>"> 
{% endcodeblock %}

Tại sao ở đây lại cần hàm date("Y-m-d H:i:s") ? Browser có cơ chế cache và thông thường sẽ cache lại các file image tại 1 website để lần sau quay lại load trang web nhanh hơn. Nếu Browser detect thấy file _.gif nằm trong cache thì sẽ **không mạke request đến server** và tracking sẽ thất bại :D với &_=<?php date("Y-m-d H:i:s");?> image sẽ vẫn đc request nhưng với đuôi có chưa curent time nên sẽ không bị cache.

 
## Cross-domain cookies ##

Phần này sẽ đề cập đến 1 khái niệm liên quan: cross-domain cookie.
Giả sử site A có đặt link hay ads(quảng cáo) của site N, và cả site A lẫn site N đều nằm thuộc cùng 1 group, 1 công ty. Lúc đó webmaster của site A và site N có thể sử dụng cross-domain cookie để tracking user action flow trên cả 2 site.

Cái gì gọi là cross-domain cookie ? Chẳng phải là cookie chỉ readable với 1 domain cố định hay sao ?

Bạn có thể hình dung đơn giản như sau: 

* User visit site A, site A tạo 1 cookie với domain của mình, kèm theo 1 sessionID. Với sessionID này site A có thể tracking user trong phạm vi site của mình.
* User click vào link (hoặc ads) đến site N, site A "gửi kèm" 1 param là sessionID kể trên . Site N đón nhận request với sessionID và cũng tạo 1 cookie trên domain của mình chứa sessionID dược nhận.
* User click vào nút "Come back to previous site" trên site N, site N sẽ tổng hợp action flow trên site mình (dựa vào cookie tạo ở trên), send ngược trờ lại cùng với sessionID cho site A.
* Site A sẽ welcome user trở lại, VD thêm đoạn chào hỏi: "Aha, bạn đến site N để mua abcxyz phải không, để tôi show cho bạn thêm vài site khác nữa cũng có thứ đồ abcxyz đó nữa, tốt lắm " etc :D


Vậy vấn đề sẽ thế nào nếu như ko có nút "Come back to previous site" hay link hoặc ads trên site A ?
Nói 1 cách khác, nếu user chỉ visit site A và site N bằng cách gõ URL trực tiếp trên thanh URL của browser ?

Implement cross-domain cookies sẽ hơi phức tạp hơn nhưng không phải là không làm được.

*  User visit siteA, site A vẫn tạo cookie với 1 sessionID như trên
* User visit siteN/randompage, site N redirect lại siteA/cookieGetter.php với param callback_url="randompage"
* Khi browser quay trờ lại siteA/cookieGetter.php, site A sẽ check cookie của mình và nếu tìm thấy sessionID sẽ gửi dưới dạng param ngược lại cho siteN/randompage ("randompage được lấy ra từ param callback_url")
* User được redirect back lại siteN/randompage cùng với sessionID, lúc này site N sẽ tạo cookie của site mình với sessionID kể trên.

Như vậy cross-domain cookie thực tế vẫn là các cookie khác nhau trên các domain khác nhau


## Third-party cookies ##
 
Third-party cookies lại là 1 khái niệm khác và dễ nhầm lẫn. Trong trường hợp site A và site N ở trên không cùng 1 công ty hay đơn vị quản lý, cookie của site A đối với site N gọi là third-party cookie và ngược lại.

Giả sử trên site A đặt 1 ads banner của site N. Khi browser của user load webpage từ site A, nó đồng thời send request đến site N để load banner image. Site N có thể dựa vào request để tạo ra 1 cookie với 1 sessionID (anonymous profile) gửi lại đến browser. 

Tiếp theo, user đến site B cũng đặt ads banner của site N. Browser lại request webpage từ site B **cùng với request đến site N để load banner image**. Lần này site N có thể check sessionID được gửi kèm tới trong cookie, và nhận biết được user đi từ site A đến site B :D


## Kết luận
* Web beacon: là 1 technique trong web programming, mục đích là phục vụ cho web data analytics
* Cross-domain cookies: các cookie khác nhau trên các domain khác nhau, tuy nhiên identify được lẫn nhau thông qua unique ID
* Third-party cookies: cookies của domain khác nhưng được set khi user visit webpage của server mình



