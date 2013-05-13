---
layout: post
title: "closure và scope trong javascript"
date: 2013-05-12 00:15
comments: true
categories: 
  - javascript
  - programming
---

#Scope và closure là gì?
Scope và closure là 2 khái niệm cơ bản mà một programmer nên biết, vì hiểu rõ 2 khái niệm này vừa giúp cho programmer tránh được một số lỗi hay gặp, vừa giúp thiết kế chương trình tốt hơn. Đầu tiên chúng ta sẽ remind lại 2 khái niệm này một cách ngắn gọn.
Đầu tiên là khái niệm về scope, khái niệm này quá cơ bản chắc hẳn mọi người đều biết, nhưng thôi mình cứ quote lại từ wikipedia đề phòng có người quên:
> [Scope refers to where variables and functions are accessible, and in what context it is being executed]

 => Dịch ra đại thể là scope là nơi mà *biến* hoặc *hàm* có thể truy cập vào và sử dụng/ tham chiếu được qua tên trực tiếp. Và ở ngoài scope đó thì *biến* hoặc *hàm* đó sẽ không thể **nhìn** được một cách trực tiếp nữa. (hơi khó hình dung nhỉ). Để phân loại scope thì có rất nhiều cách tùy thuộc vào từng góc nhìn , nhưng mình sẽ không đi sâu vào vấn đề này. Mỗi ngôn ngữ lại có đặc trưng về scope khác nhau. Trong bài viết này chúng ta sẽ chỉ tập trung vào javascript.

 Khái niệm tiếp theo là về closure, khái niệm này thì không phải ai cũng biết, vì không phải ai cũng cần đến và từng động đến. Một số ngôn ngữ mainstream như C++ , java cũng không hỗ trợ closure, càng làm ít người để ý đến nó (java 8 expected sẽ cho closure vào). Hãy xem wiki nói về closure thế nào:

> [a closure (also lexical closure or function closure) is a function or reference to a function together with a **referencing environment**]

 => Dịch ra đại thể là closure là một hàm hoặc một tham chiếu (hay còn gọi là một cái **bao đóng**) đi kèm với cái môi trường mà nó tham chiếu đến (khá là xoắn). Cái cần nhấn mạnh ở đây là cái **referencing environment** (môi trường tham chiếu) mà các bạn sẽ hiểu hơn ở các ví dụ dưới đây.

 
#Scope và closure trong javascript
Javascript là một ngôn ngữ phổ biến hiện nay. Người biết về js thì nhiều, nhưng người hiểu rõ một số corner của js thì chắc không nhiều đến thế :D. Một trong các corner đấy chính là **scope và closure**. Js là một ngôn ngữ khá đặc biệt, đặc biệt ở chỗ js mang hơi hướng của lập trình hàm (functional programming), khi mà **function ở js cũng là một first-class object**, tức là function có thể được tạo mới (construct new) tại run-time, được lưu dưới dạng một cấu trúc dữ liệu (data structure), được truyền qua parameter, được dùng như một giá trị trả về (return value). Chính vì đặc điểm đấy khiến cho scope và closure của js không giống như các ngôn ngữ phổ biến khác.

Đầu tiên chúng ta sẽ nói về scope

##1. ***<u>Scope</u>***
Như chúng ta vừa nói ở trên, scope là khái niệm qui định "visibility" và "lifetime" của variable. Thông thường, ví dụ như C thì scope sẽ là **block scope**, tức là những biến **tạo ra** trong block sẽ chỉ được nhìn thấy trong block đấy thôi, và khi ra ngoài block đấy thì những variable nằm trong block sẽ được giải phóng ( như trong C là các biến tạo ra trong stack sẽ được free khi ra khỏi block), và không nhìn thấy được nữa. 

Tuy nhiên rất buồn là javascript của chúng ta lại không có cái scope dễ hiểu đến thế, mà nó lại là **function block**.Function block ở đây là gì: tức là những gì bạn tạo ra trong một function sẽ available ở trong function đó. Vì javascript cũng là block syntax, nên sẽ hơi dễ confusing, chúng ta sẽ dùng ví dụ dễ hiểu này:
{% codeblock function.js %}
function scope() {
  if (true) {
    var test = 1;
  }
  alert(test); #=> 1
}
scope();
{% endcodeblock %} 

Nói đến đây chắc chắn có bạn sẽ nghĩ đến điều gì xảy ra khi chúng ta có **nested function**. Let's try
{% codeblock function.js %}
function outer() {
  var outer_var = 2;
  function inner() {
    alert(outer_var);
  }
  inner();
}
outer(); #=> 2
{% endcodeblock %} 
Từ ví dụ trên ta có thể dễ dàng thấy là inner function có thể access được outer function variable. Từ ví dụ này chúng ta có thể thấy là **inner function có thể inherit biến của outer function**, hay nói cách khác, inner function **chứa(contain)** scope của outer function. Chính nhờ điều đặc biệt này mà chúng ta có cái gọi là **Closure** mà mình sắp sửa nói đến ngay dưới đây. Một điều chú ý là đối với nhiều ngôn ngữ thì các bạn hay được khuyên là declare biến muộn nhất có thể để tránh overhead, tuy nhiên với javascript là ngôn ngữ với **function scope** thì best practice lại là **declare biến sớm nhất có thể ** để tránh nguy cơ xảy ra một số lỗi không mong muốn.



##2. ***<u>Closure</u>***
 Quote lại cái định nghĩa cho đỡ quên:

 > A closure is an expression (typically a function) that can have free variables **together with an environment that binds those variables (that "closes" the expression).**

Chắc có bạn sẽ thắc mắc, **environment** ở đây là gì. Để hình dung một cách dễ hiểu, thì environment ở đây trong phần lớn các trường hợp chính là cái outer function mà chung ta vừa thử ở ví dụ về scope ở trên. Một đặc điểm rất hay của closure là **closure sẽ giữ tham chiếu đến các biến nằm bên trong nó, hoặc được gọi đến bên trong nó**. Điều này dẫn đến việc gì? Chắc sẽ có bạn nghĩ đến một trường hợp rất đặc biệt là khi bạn muốn context của một function được giữ lại sau khi hàm đó đã được execute xong :D. Hãy bắt đầu bằng một ví dụ:

{% codeblock closure.js %}
function outside(x) {
  function inside(y) {
    return x + y;
  }
  return inside;
}
fn_inside = outside(3); 
result = fn_inside(5); // #=> 8
 
result1 = outside(3)(5); // #=> 8
{% endcodeblock %}

Bạn có nhận thấy điều gì đặc biệt ở trên? Điều đặc biệt nằm ở hàm **fn_inside** : hàm fn_inside được tạo ra bởi kết quả trả về của hàm outside() với parameter là 3, và bạn có thể nhận thấy hàm fn_inside vẫn giữ tham chiếu đến cái parameter 3 đó **ngay cả khi hàm outside() đã được execute xong**. Chắc các bạn sẽ thấy mâu thuẫn với cái lý thuyết về function scope chúng ta đã nói đến ở trên, khi mà *mọi thứ được tạo ra trong function của js chỉ nhìn thấy và sử dụng được ở trong đó, và sẽ được giải phóng hoặc không nhìn thấy khi ra ngoài function đó*. 
Thực tế là không hề mâu thuẫn chút nào cả, chính vì cái gọi là closure của js :D. Nói một cách cụ thể hơn: **fn_inside khi được tạo ra đã đồng thời cũng tạo ra một cái closure (bao đóng), trong cái bao đó, giá trị 3 được truyền vào, và cái bao của fn_inside sẽ vẫn giữ cái giá trị 3 đó cho dù outside() function có execute xong**. Các bạn cứ hình dung trực quan closure như một cái bao chứa rất nhiều thứ trong nó là sẽ thấy dễ hiểu hơn:

{% img /images/closurejs/closure.png %}

Như vậy chúng ta có thể tóm gọn lại đoạn code ở trên như sau:

1. Khi outside() được gọi, outside trả về một function 
2. function được outside trả lại (fn_inside) đó đóng lại cái context hiện tại và cái context đó **chứa biến x tại thời điểm outside() được gọi**
3. Khi fn_inside được gọi, nó vẫn nhớ x có giá trị là 3
4. Khi invoke fn_inside(5) thì nó sẽ lấy giá trị biến y=5 + giá trị biến x=3 và kết quả sẽ là 8

Như vậy chúng ta có thể rút ra một đặc điểm của closure là:
>  ***A closure must preserve the arguments and variables in all scopes it references***

* Một câu hỏi được đặt ra là: Khi nào cái biến x được giải phóng?? Câu trả lời là khi mà cái context mà biến x được reference đến ( ở đây là fn_inside ) không còn accessible được nữa ( refer đến scope của js, chúng ta có thể hiểu là khi mà function chứa fn_inside được execute xong và không còn bất kì tham chiếu nào đến fn_inside nữa ).

* Một câu hỏi khác được đặt ra là với multi-nested function thì điều gì sẽ xảy ra?? Let's give a try:
{% codeblock multinested.js %}
function A(x) {
  function B(y) {
    function C(z) {
      alert(x + y + z);
    }
    C(3);
  }
  B(2);
}
A(1); #=> 6
{% endcodeblock %}

Ở đoạn code trên thì điều gì đã xảy ra?

1. B tạo ra một cái closure chữa context của A, do đó B có thể access vào A's variable, ở đây là x
2. C tạo ra một cái closure chứa context của B
3. Vì B chứa context của A nên C cũng sẽ chứa context của A, tức là C cũng access được vào biến x của A, và cả biến y của B. 

Do đó kết quả sẽ là 1+2+3=6, khá là obvious nhỉ. Đoạn code ở trên giúp chúng ta có thêm một khái niệm mới gọi là ***scope chaining***. Tại sao gọi là chaining, vì khi context được include từ outer function vào inner function, thì chúng ta sẽ hiểu một cách đơn giản là context của inner function và context của outer function được nối với nhau, một cách có chiều (**directed**). Và độ ưu tiên khi access biến là từ trong ra ngoài.

{% img /images/closurejs/closure2.png %}

Do cái scope chaining là directed nên ở phía ngược lại, A lại không thể access được C, vì C nằm trong context của B, và chỉ visible **inside B**, hay nói cách khác là C sẽ là private của B, và không nhìn được từ A.

* Lại có một bạn nghĩ là khi outer function có biến tên là x, mà ta cũng truyền 1 biến tên là x vào inner function, tức là khi có name-conflict thì chuyện gì sẽ xảy ra. Let's take an example
{% codeblock nameconflict.js %}
function outside() {
  var x = 10;
  function inside(x) {
    return x;
  }
  return inside;
}
result = outside()(20); #=> 20
{% endcodeblock %}

Bạn có thể thấy kết quả trả về biến x được trực tiếp truyền vào inner function thay vì biến x của outer function. Sử dụng khái niệm scope chaining ở trên thì chúng ta có thể thấy độ ưu tiên của context inside là cao hon context outside khi intepreter tìm giá trị của x, nên giá trị của x ở inside (ở đây là 20) sẽ được sử dụng.

Hy vọng là với 3 ví dụ trên các bạn đã có cái nhìn rõ ràng hơn về closure.

##3. ***<u>Closure pitfalls</u>***
Closure là một khái niệm khá dễ nhầm lẫn và khó nắm rõ với những người người ít quan tâm đến javascript. Một trong những ví dụ hay được dùng để minh họa cái sự dễ nhầm này được gọi là **The Infamous Loop Problem**. Ví dụ này được minh họa bằng đoạn code dưới đây:

{% codeblock closurepitfall.js %}
var add_the_handlers = function (nodes) {
  var i;
  for (i = 0; i < nodes.length; i += 1) {
    nodes[i].onclick = function (e) {
      alert(i);
    };
  }
};
nodes = document.getElementById("click");
add_the_handlers(nodes);
{% endcodeblock %}

Đoan code ở trên làm một việc là tìm tất cả các node có id là "click", add vào node đó một cái sự kiện là khi click vào node đó sẽ alert lên thứ tự của node đó. Giả sử bạn có một file html như sau:

{% codeblock closurepitfall.html %}
<li id="click">link 1 </li>
<li id="click">link 2 </li>
<li id="click">link 3 </li>
<li id="click">link 4 </li>
<li id="click">link 5 </li>
{% endcodeblock %}

Bạn hy vọng là khi click vào link 1 sẽ alert 1, click vào link 2 sẽ alert ra 2.... đúng không. Tuy nhiên thực tế là **bạn click vào link nào nó cũng alert ra 5 cả**. Kì lạ nhỉ? Để giải thích cho hiện tượng này thì chúng ta hãy xem lại khái niệm về closure nào. Biến i được sử dụng trong anonymous function được gán cho onclick, được **kế thừa từ context của add_the_handlers function**. Tại thời điểm mà bạn gọi onclick, for loop đã được execute xong, và biến i **của context của add_the_handlers** lúc này có giá trị là 5. Do đó bạn có click vào link nào thì giá trị được alert ra cũng là 5 cả. Điểm chú ý của việc này chính là do bạn đang nhầm lẫn, hay chính xác là có sự khác biệt giữa **scope/context của for-loop** với **scope/context của outer function là add_the_handlers **. 

Để giải quyết vấn đề này thì bạn có thể làm như dưới đây:

{% codeblock pitfall.js %}
var add_the_handlers = function (nodes) {
  var helper = function (i) {
    return function (e) {
      alert(i);
    };
  };
  var i;
  for (i = 0; i < nodes.length; i += 1) {
    modes[i].onclick = helper(i);
  }
};
{% endcodeblock %}

Point của cách làm này chính là việc truyền được giá trị của (i) tại thời điểm hiện tại vào closure của function được bind (gán) vào onclick. Giúp cho hàm helper() luôn tham chiếu đến giá trị i đúng. Một best practice để tránh những sai lầm như thế này là
> Avoid creating functions within a loop. It can be wasteful computationally,and it can cause confusion (tránh tạo mới function trong vòng loop, vì nó vừa làm tốn tài nguyên cpu, vừa dễ gây nhầm lẫn)

#Kết luận
Như vậy qua bài viết này chúng ta đã nắm được khái niệm về function scope và closure trong javascript, và một số best practices trong việc sử dụng closure và scope. Closure trong javascript hay sử dụng để tạo ra một cái bao mà các thứ trong đấy không được nhìn thấy bởi bên ngoài nhưng vẫn truy cập được từ bên trong, và thường được áp dụng cho một số design pattern trong js (tiêu biểu nhất là module pattern).Chi tiết hơn các bạn có thể tham khảo ở các tài liệu sau:

- [Javascript the good part (by Douglas Crockford)](http://www.amazon.com/JavaScript-Good-Parts-Douglas-Crockford/dp/0596517742/ref=sr_1_1?ie=UTF8&qid=1368334060&sr=8-1&keywords=javascript+the+good+part)
- [Ecma-262 standard](http://www.ecma-international.org/publications/standards/Ecma-262.htm)
- [http://robertnyman.com/2008/10/09/explaining-javascript-scope-and-closures/](http://robertnyman.com/2008/10/09/explaining-javascript-scope-and-closures/)
- [https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Functions_and_function_scope](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Functions_and_function_scope)
