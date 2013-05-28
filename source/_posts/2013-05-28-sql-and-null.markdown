---
layout: post
title: "sql and null"
date: 2013-05-28 22:28
comments: true
categories: 
 - sql
---

Khi sử dụng SQL, chắc hẳn các bạn đã biết có một cái gọi là **NULL** (mình gọi là cái vì NULL **không 
phải là một giá trị**)
Để so sánh với NULL thì các bạn sẽ dùng toán tử **is** và **is not** thay vì **=**(equal) hoặc là
**<>**(not equal)
{% codeblock null.sql %}
SELECT * WHERE field IS NULL
{% endcodeblock %}

Bạn đã bao giờ tự hỏi tại sao lại không dùng (=) và (<>). Đầu tiên chúng ta hãy thử nhé
{% codeblock null.sql %}
select "1" where 1 <> NULL;
select "2" where 1 IS NOT NULL;
select "3" where NULL = NULL;
select "4" where NULL <> NULL;
select "5" where NULL IS NULL;
{% endcodeblock %}

và kết quả nhận được sẽ là "2" và "5". Từ đấy có thể thấy một điều đơn giản là: để so sánh với NULL chúng ta chỉ có thể dùng IS và IS NOT.
Vậy nếu bạn thực hiện các phép toán với NULL thì sao? Mọi phép toán như cộng ,trừ ,nhân ,chia ,concat mà có sự tham gia của NULL đều cho 
kết quả là NULL cả.  


Đầu tiên để hiểu lý do thì chúng ta phải biết là tại sao lại có giá trị NULL. 
Giá trị NULL trong SQL mục đích chính là để nhằm tạo ra một cách thể hiện cho cái gọi là "không có thông tin hoặc thông tin không phù hợp" 
(missing information and inapplicable information). Do đó về mặt tự nhiên, bạn sẽ nói là field X không có thông tin, chứ sẽ không nói là 
field X bằng (equal) không có thông tin, đúng không. Tuy nhiên lý do trên không có giá trị về mặt giải thích.

Để giải thích cặn kẽ thì chúng ta phải đi lại một chút về khái niệm Logic. Về mặt toán học thì có rất nhiều loại LOGIC. Boolean logic được 
biết đến nhiều nhất. Bản chất của Boolean là chỉ tồn tại 2 giá trị TRUE, FALSE và các phép toán trên chúng. Do đó Boolean được xếp vào loại
2VL (2 valued logic). Tuy nhiên logic trong SQL rất tiếc lại không phải Boolean, vì trong SQL sẽ tồn tại 3 khái niệm logic: TRUE, FALSE, và 
Unknown ( hay chính là NULL ). Do đó logic trong SQL gọi là 3VL (3 valued logic). Trong Boolean chỉ có 2 phép so sánh là equal (=) và not(<>),
tuy nhiên với 3VL như SQL sẽ có thêm phép so sánh là **IS** và **IS NOT**. Kết hợp 3 loại giá trị với các phép so sánh đó sẽ cho chúng ta kết
quả là 3 loại bảng truth table dưới đây:

{% img /images/sqlandnull/truthtbl.png 500 1000 truth table %}

{% img /images/sqlandnull/truthtbl2.png 300 600 truth table %}

(trích dẫn từ Wikipedia)

Trên đây là những kiến thức hết sức basic về giá trị NULL trên SQL, hy vọng có thể giúp các bạn đỡ nhầm lẫn khi thực hiện các phép toán với NULL.






