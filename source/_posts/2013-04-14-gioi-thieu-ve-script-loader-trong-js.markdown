---
layout: post
title: "giới thiệu về script loader trong js"
date: 2013-04-14 00:23
comments: true
categories: 
- programming
- javascript
---

##I.Script loader là gì và tại sao lại cần nó ##
Trong javascript, khi cần include một thư viện, hay một module từ ngoài vào, chắc hản mọi
web developer đều nghĩ ngay đến việc include vào html:
{% codeblock include direct - include.html %}
 <script src="http://yourhost/script.js" ></script>
{% endcodeblock %} 

Vậy include trực tiếp script tag vào html có gì không tốt?

+ Block việc render GUI của web browser: 
Cơ chế render của web browser là render tuần tự, đi từ trên xuống dưới.Chính vì thế mà khi 
gặp script tag thì đầu tiên là web browser phải download về, sau đó parse và execute script đó
, sau đó mới render những thứ tiếp theo. Việc này làm cho việc render nội dung web sẽ bị block lại
. Thử hình dung bạn sử dụng thư viện ember.js, thư viện này sau khi minified lại có dung lượng khoảng
200kb, bạn download từ cdn về mất 1.5s, bạn render mất 0.5s nữa, tổng cộng đã mất 2s, là một con số 
không nhỏ.

+ Khi qui mô của web lớn lên, đặc biệt tại thời điểm mà các framework mvc cho js nở rộ như hiện 
nay với ember, backbone hay angular và việc phát triển bùng phát của single-page web app(những 
application viết chủ yếu bằng javascript) thì việc quản lý chặt chẽ thư viện, module nào có dependency
ra sao, nên được load vào thời điểm nào là hết sức quan trọng

Để giải quyết vấn đề đó, thì chúng ta sẽ sử dụng một khái niệm gọi là script loader. Script loader chỉ 
đơn giản là chuyển việc load script từ html vào một cái script js chỉ chuyên làm nhiệm vụ "load" các 
dependent scripts. "load" bằng cách nào thì rất đơn giản, chỉ là tạo ra một script tag, gán source 
và insert vào dom. Việc này khác việc include script bằng html là nó không block UI, nó chỉ đơn thuần
là request đến server chứa script cần load thông qua XHR, lấy kết quả về, và eval đoạn script đó.

Ví dụ về script loader:
{% gist 5378918 %}

Và kết quả đạt được là:

1. Load script trực tiếp vào html tag
{% img /images/script-loader-images/withoutloader.png 'image' 'images' %}

2. Load script thông qua loader
{% img /images/script-loader-images/withloader.png 'image' 'images' %}

Có được kết quả trên là vì đưa việc loading js vào trong script giúp cho ta có thể load các module 
đó asynchronousi thông qua XHR(ajax), và nhờ đó rút ngắn được thời gian load + render
Như vậy là ta đã giải quyết được bài toán thứ nhất, tuy nhiên có một vấn đề là để load được một module
thông qua script loader thì module đó bắt buộc phải tuân theo một qui chuẩn nào đó để giúp qui định 
về thứ tự load, và dependency. Để giải quyết vấn đề đó, đồng thời cũng để giải quyết vấn đề thứ hai đã
nêu ở trên chúng ta sẽ đưa ra khái niệm AMD

## II AMD ##
AMD là viết tắt của Asynchronous Module Definition, là một qui chuẩn của javascript dành cho việc load 
các script/module và các dependency của chúng từ ngoài vào một cách không đồng bộ (asynchronously).

Thực tế gọi là một qui chuẩn, nhưng AMD chỉ đơn thuần qui định 2 rule cơ bản:

* Interface cho hàm define()
{% codeblock define define.js %}
 define(id?, dependencies?, factory);
{% endcodeblock %} 
+ param id: qui định id của module được load vào, [?] là do param này là optional, có thể bỏ qua
+ param dependencies: là 1 **array** các module dependency của module được load vào, param này cũng là optional
+ param factory: là đoạn script dùng để initialze cho module sẽ được load vào. factory() sẽ chỉ được execute một lần 
, và nếu factory() có return value thì return value này nên được export ra ngoài để có thể sử dụng lại ở trong các
script khác

Một ví dụ đơn giản cho AMD interface:
{% gist 5380787 %}

* Property amd cho hàm define:
Function define **nên** có property tên là amd. Việc này giúp tránh conflict khi module của bạn đã có một function tên 
là define, và trong property này sẽ định nghĩa là module của bạn có cho phép nhiều version trên cùng một document không
 ( khi module của bạn đã conform theo AMD, thì chắc chắn trong hàm require phải có đoạn check là đã có property
này hay chưa  và check giá trị của nó).
{% codeblock amd - amd.js %}
define.amd = {
  multiversion: true
};
{% endcodeblock %}
Nói đến đây thì chấc sẽ có bạn thắc mắc, hoặc chưa hiểu rõ use case của cái AMD này như thế nào, nó được dùng ở đâu, ở script
loader, ở module, hay ở dom. Câu trả lời là AMD sẽ được dùng ở script loader và ở module. Cụ thể hơn là trong module của bạn,
nếu bạn muốn module đó được load async thông qua script loader, mà script loader đó lại load theo chuẩn AMD, thì đương nhiên
module của bạn cũng sẽ phải conform theo AMD, bằng cách là có hàm define() trong module, và có property amd của hàm define.
Còn script loader bản thân cũng là một module, thì tất nhiên cũng phải tuân theo AMD.

Một cách ngắn gọn, giả sử bạn có một module X
{% codeblock module - module.js %}
X = (function() {
  var prop = {};
  return prop;  
})()
{% endcodeblock %}
Bạn muốn module đó nói với bên ngoài là: tao lã X, tao có các dependency là Y, Z, khi init tao thì mày làm thế này, thế này nhé
thì bạn sẽ làm theo AMD api theo cách như sau: 
{% codeblock module with amd module.js %}
X = (function() {
  var prop = {};
  prop.define = function(name, deps, callback) {  
  }

  callback = function() {//do something to init here}
  prop.define.amd = {multiversion: true}
  
  return prop;  
})()
{% endcodeblock %} 

Và khi script loader nhìn vào cái define của bạn, nó sẽ biêt nên làm thê nào. Rất đơn giản phải không.

##III Các scriptloader nổi tiếng và việc áp dụng AMD đang ở đâu##
Hiện nay, có một số script loader nổi tiếng như:

+ YepNope: http://yepnopejs.com/
+ RequireJs: http://requirejs.org/docs/
+ Headjs: https://github.com/headjs/headjs
+ CurlJs: https://github.com/cujojs/curl
Ngoài ra trong bộ toolkit nổi tiếng Dojo cũng có sử dụng script loader

Trong những script ở trên thì có requirejs và curljs là sử dụng AMD, còn lại 2 script còn lại là yepnope
và headjs thì không. Về số lượng được sử dụng nhiều nhất thì có lẽ là requirejs.

Hiện tại các module nổi tiếng thì không phải module nào cũng conform theo AMD. Theo mình biết thì hiện 
tại có jQuery là support AMD internally, còn lại thì phần nhiều các module nổi tiếng khác như backbone, ember,
angular đểu không support AMD internally. Để sử dụng các module này với một script loader theo chuẩn AMD 
như require.js thì bạn đơn giản chỉ cần viết lại hàm define tại app của bạn, ví dụ như trong trường hợp của 
backbone:
{% codeblock backbone with amd - bbamd.js %}
require.config({
  paths: {
    jquery: 'libs/jquery/jquery',
    underscore: 'libs/underscore/underscore',
    backbone: 'libs/backbone/backbone'
});

require([
    // Load our app module and pass it to our definition function
    'app',
    ], function(App){
      // The "app" dependency is passed in as "App"
      App.initialize();
    }
);
{% endcodeblock %}

Vậy tại sao AMD có rất nhiều merit như thê mà một số module nổi tiêng lại bỏ qua việc conform theo AMD, ví dụ 
tiêu biểu nhất là emberjs. Theo như Tom Dale, một trong những creator của emberjs thì AMD yêu cầu quá nhiều
HTTP request, bởi vì để conform theo AMD thì script phải chia ra thành nhiều module, nhiều file. Ngoài ra 
thì AMD cũng yêu cầu toàn bộ module phải wrap trong một function (factory()), việc này có thể ok với một số 
người nhưng cũng sẽ gây khó chịu với một số người khác. Và cuối cùng là một số build tool hiện tại (ví dụ như
Grunt https://github.com/cowboy/grunt) hỗ trợ rất tốt cho việc quản lý dependency và version rồi, thế nên
việc conform cấu trúc code của mình theo một cái có sẵn như AMD là không cần thiết.

## IV Kết luận ##
Script loader đã và đang trở thành một kĩ thuật không thể thiếu trong việc tạo ra một responsive web app, giúp
rút ngắn thời gian load và render js. Cộng với việc AMD ra đời chúng ta đang thấy ecmascript, cụ thể hơn là 
javascript đang có những nỗ lực trở nên mature hơn, để có thể trở thành ngôn ngữ mà developer có thể cảm thấy
thoải mái khi phát triển và khi scope của application bị phình to ra. Tại version ecma hiện tại (ECMA-262) thì
vẫn chưa có một qui chuẩn nào cho việc load script theo module và dependency, tuy nhiên chúng ta có thể hy vọng
về điều này trong một thời gian gần.
