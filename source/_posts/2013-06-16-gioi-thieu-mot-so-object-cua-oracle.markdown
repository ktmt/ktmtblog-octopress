---
layout: post
title: "Giới thiệu một số object của Oracle - phần 1 "
date: 2013-06-16 21:16
comments: true
categories: 
  - PLSQL 
  - Database 
  - Oracle
---

## Tổng quan về Oracle và những điểm mạnh 
Oracle là hệ có sở dữ liệu hay dùng trong business application, gồm phiên bản free (standard edition) và phiên bản trả phí (enterprise edition). Với một set rất nhiều feature được develop trong thời gian dài, những object tiện dụng được chuẩn bị sẵn, hay quan trọng hơn hết là các tool tương thích trên top của tầng RDBMS (như RAC hay Datawarehouse), Oracle tỏ ra có ưu thế vượt trội so với các hệ cơ sở dữ liệu quan hệ open source.

Bài viết này sẽ mang đến cho độc giả những khái niệm đầu tiên về các object hay được sử dụng và những feature nổi bật của oracle 

## VIEW 
VIEW là 1 object cũng available trên MySQL, tuy nhiên trước khi đi vào một số object phía sau, mình sẽ nói lại một chút về object này.

Needs của VIEW phát sinh khi bạn có 1 complex query. Thay vì gửi complex query về DB mỗi lần, bạn có thể create sẵn 1 VIEW mang nội dung của complex query, và mỗi lần gọi từ tầng application chỉ cần SELECT * FROM VIEW

Như vậy syntax của VIEW đơn giản như sau: 

{% codeblock view.sql %}
CREATE VIEW demo_view AS 
  -- select ... (complex query)
{% endcodeblock %}

* Một điểm cần lưu ý là, sau khi VIEW được tạo ra thì database không mất bất cứ dung lượng nào ngoại trừ 1 cái dictionary entry để định nghĩa bản thân VIEW. Nói cách khác, VIEW chỉ là định nghĩa, mỗi lần bạn gọi VIEW thì Oracle sẽ đi thực hiện nội dung cái VIEW và trả lại cho bạn kết quả.

* VIEW cũng thường được dùng để hide table columns. Nói đơn giản, bạn muốn user A chỉ nhìn thấy 1 số chứ ko không tất cả column của table T, bạn có thể create VIEW V chỉ bao gồm những column của table T mà bạn muốn cho user A access, và đơn giản give access control của V cho A 

* Cuối cùng: Predicate pushing, là 1 behaviour của Oracle View thường sẽ đem lại good performance những cũng gây hậu quả ngược trong không ít trường hợp. 

Giả sử bạn có 2 view như sau: 

{% codeblock view.sql %}
CREATE VIEW V1 AS
  SELECT * FROM GOTHAM_CITIZENS;
CREATE VIEW V2 AS
  SELECR * FROM V1
  WHERE
    NAME = 'Batman';
{% endcodeblock %}

Giả sử query gọi từ tầng Application là 

{% codeblock query.sql %}
SELECT * FROM V2 
WHERE
  ABILITY = 'can fly';
{% endcodeblock %}

Ở đây predicate là những điều kiện đằng sau WHERE, cụ thể là NAME = 'Batman' và ABILITY = 'can fly'. Trong trường hợp này Oracle sẽ cố biến VIEW V1 thành như sau 
{% codeblock query.sql %}
CREATE VIEW V1 AS
  SELECT * FROM GOTHAM_CITIZENS
  WHERE
    NAME = 'Batman'
  AND
    ABILITY = 'can fly';
{% endcodeblock %}

Nói cách khác, Oracle sẽ cố push các predicates xuống tầng cuối cùng! Bạn có thể có 10 hay 100 predicates trải từ V1 đến V100 (stack views), tất cả sẽ được push xuống tầng tiếp xúc trực tiếp với table! Điềy này có ý nghĩa gì ?

V1 sẽ có thể dùng index và tăng performance nhanh chóng cho cả stack views.


## MATERIALIZED VIEW 

MATERIALIZED VIEW là 1 object đặc thù của Oracle. Trên MySQL bạn cũng có thể implement MATERIALIZED VIEW dưới dạng 1 table mới. 

Needs của MATERIALZED VIEW phát sinh khi bạn có 1 complex computation hoặc 1 complex JOIN statement . Dĩ nhiên bạn không muốn mỗi lần query DB, DB engine lại bắt đầu select từ các table và thực hiện lại các thao tác tính toán phức tạp.

{% codeblock materialized_view.sql %}
CREATE MATERIALIZED VIEW demo_materialized_view AS 
  -- select ... (comlex JOIN or computation)
{% endcodeblock %}
 
* Khác với VIEW, MATERIALIZED VIEW thực sự chiếm storage của DB. Khi được tạo ra MATERIALZED VIEW sẽ đi tính toán theo công thức được chỉ định sẵn và lưu vào 1 object trong DB. Mỗi lần bạn SELECT FROM MATERIALZED_VIEW thì sẽ nhận được kết quả tính toán của lần gần nhất.

* Kết quả tính toán sẽ được update trong mỗi lần REFRESH. Giữa 2 lần REFRESH thì kết quả tính toán là không đổi.

* REFRESH có thể được kích hoạt bẳng COMMIT, bằng TRIGGER hoặc được đặt SCHEDULE.

* Chiến lược REFRESH của MATERIALZED_VIEW bao gồm COMPLETE (mới hoàn toàn), FAST (chỉ lấy thêm phần khác biệt so với lần trước). FAST REFRESH đòi hỏi phải có 1 object nữa là MATERIALZED VIEW LOG, sẽ được đề cập trong bài tiếp.

* Khi dữ liệu quá lớn và tính toán quá phức tạp, MATERIALZED VIEW sẽ đưa toàn bộ phần load của complex computation về thời điểm REFRESH và giúp câu query tại các thời điểm khác trả về kết quả tức thì. Nói hình tượng, bạn có thể schedule cho MATERIALZED VIEW được REFRESH vào lúc nửa đêm, khi user của bạn không mấy khi phát sinh request nào đến Application có thể động chạm đến DB, và trong 1 ngày tiếp theo bạn sẽ có kết quả tính toán được query ra trong 1s và đảm bảo là luôn dúng cho đến ngày hôm trước! 

 
## Kết luận
* VIEW: là logical object, không chiếm storage của DB và thường tổng hợp 1 set các SQL query để có thể gọi 1 cách đơn giản từ application.
* Predicates pusing: là behaviour của Oracle khi tạo nhiều VIEW chồng nhau thành cấu trúc stack views. Oracle luôn cố push predicates xuống tầng cuối cùng để index.
* MATERIALZED VIEW: là object chiếm storage trực tiếp của DB, thường tổng hợp 1 set các tính toán hoặc JOIN phức tạp và được REFRESH dựa theo chiến lược được định nghĩa sẵn. Với khả năng index chính các kết quả sau khi tính toán, MATERIALZED VIEW cho kết quả trả lại gần như ngay lập tức đối với những data up-to-date đến 1 thời điểm nhất định. 
