---
layout: post
title: "giới thiệu về script loader trong js"
date: 2013-04-14 00:23
comments: true
categories: 
---

##I.Script loader là gì? ##
Trong javascript, khi cần include một thư viện, hay một module từ ngoài vào, chắc hản mọi
web developer đều nghĩ ngay là: xời, đơn giản, chỉ cần một dòng code là xong, sao phải xoắn
{% highlight html %}
 <script src="http://yourhost/script.js" ></script>
{% endhighlight %} 
Vậy include trực tiếp script tag vào html có gì không tốt?
+ (1) Block việc render GUI của web browser: 
Cơ chế render của web browser là render tuần tự, đi từ trên xuống dưới.Chính vì thế mà khi 
gặp script tag thì đầu tiên là web browser phải download về, sau đó parse và execute script đó
, sau đó mới render những thứ tiếp theo. Việc này làm cho việc render nội dung web sẽ bị block lại
. Thử hình dung bạn sử dụng thư viện ember.js, thư viện này sau khi minified lại có dung lượng khoảng
200kb, bạn download từ cdn về mất 1.5s, bạn render mất 0.5s nữa, tổng cộng đã mất 2s, là một con số 
không nhỏ, đặc biệt với user.
+ (2) Khi qui mô của web lớn lên, đặc biệt tại thời điểm mà các framework mvc cho js nở rộ như hiện 
nay với nhứng ember, backbone hay angular và việc phát triển bùng phát của single-page web app(những 
application viết chủ yếu bằng javascript) thì việc quản lý chặt chẽ thư viện, module nào có dependency
ra sao, nên được load vào thời điểm nào là hết sức quan trọng
Để giải quyết vấn đề đó, thì chúng ta sẽ sử dụng một khái niệm gọi là script loader. Script loader chỉ 
đơn giản là chuyển việc load script từ html vào một cái script js chỉ chuyên làm nhiệm vụ "load" các 
dependent scripts, và bảo đảm dependency của các script đó. 


Một ví dụ đơn giản:
Và kết quả đạt được là:
=>Load script bằng script loader:
