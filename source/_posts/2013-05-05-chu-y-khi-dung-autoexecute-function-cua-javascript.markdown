---
layout: post
title: "chú ý khi dùng autoexecute function của javascript"
date: 2013-05-05 01:02
comments: true
categories: 
  - javascript
  - memo
  - programming
---
### Loading order problem
Khi viết javascript cho một website thì web-developer thường hay dùng autoexecute function của javascript để tạo ra một closure cho đỡ poison global environment ( vì khi không nằm trong closure mà viết thẳng luôn dưới dạng global thì các biến/function được tạo mới dưới dạng (var x) sẽ thành window.x và có khả năng nào đó sẽ conflict với các bién/hàm có sẵn hoặc của các library khác).

Autoexecute function thường hay được viết như sau:

{% codeblock autoexecute.js %}
(function() {
  //do all the thing  
})();
{% endcodeblock %}

tuy nhiên thì khi viết thế này thì có một đặc điểm là cái (//do all the thing) sẽ **được execute trước khi dom được load lên**.
Chính vì thế nếu bạn gọi trong đó một hàm có thao tác với dom như

{% codeblock autoexecute.js %}
(function() {
  var x = document.getElementById("xxx");
})();
{% endcodeblock %}
thì cái x đấy khả năng null sẽ cao vì khi đấy dom chưa được gắn (render) cái element xxx vào.

Để giải quyết vấn đề này thì bạn chỉ cần gom cái (//all the thing) vào trong hàm callback của window.onload là ok:

{% codeblock autoexecute.js %}
(function() {
  window.onload = init;
  function init() {
    var x = document.getElementById("xxx");
  }
})();
{% endcodeblock %}

### Callback scope problem
Gần đây mình có gặp một lỗi rất lạ là, với callback function được gọi từ phía ngoài scope của autoexecute function, ví dụ như sau:

{% codeblock autoexecute.js %}
(function() {
  var xxx;
  xxx.callback = function() {
    //do yyy
  }
})();
{% endcodeblock %}

Khi xxx.callback được gọi bởi một hàm ** ở ngoài** scope của closure, thì lúc đầu **xxx.callback** vẫn được gọi, nhưng sau một lúc, 
khi mà cái closure (function(){})() đã được execute xong, đồng nghĩa với việc xxx cũng bị dọn dẹp rồi thì cái callback này đương
nhiên cũng bị mất đi, và tất nhiên sẽ không chui vào được nữa. Một lỗi rất cơ bản nhưng mình cũng mất một lúc mới phát hiện ra nguyên
nhân.
