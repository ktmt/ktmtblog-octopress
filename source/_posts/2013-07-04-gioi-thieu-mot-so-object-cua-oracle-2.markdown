---
layout: post
title: "Giới thiệu một số object của Oracle - phần 2 "
date: 2013-07-04 06:20
comments: true
categories: 
  - PLSQL 
  - Database 
  - Oracle
---

## Tổng quan về Oracle và những điểm mạnh (tiếp)

Như đã giới thiệu với độc giả từ bài viết trước. Oracle là hệ cơ sở dữ liệu có nhiều object tiện dụng được chuẩn bị sẵn, và những hỗ trợ mạnh mẽ từ các công cụ trên top của tầng RDBMS.

Bài viết lần này sẽ giới thiệu tiếp về những object còn lại, và về chính ngôn ngữ của Oracle DB : PL/SQL


## MATERIALIZED VIEW LOG

MATERIALIZED VIEW LOG là object bắt buộc phải có nếu bạn lựa chọn chiến lược FAST REFRESH của object MATERIALIZED VIEW trong bài trước.
Chúng ta sẽ nhắc lại 1 chút về chiến lược REFRESH của object MATERIALZED VIEW.

MATERIALIZED VIEW có 3 kiểu REFRESH sau:

* COMPLETE: REFRESH mới hoàn toàn, Oracle sẽ query lại và tính toán lại, Nếu Table chứa lượng data lớn và việc tính toán mất nhiều thời gian thì mỗi lần COMPLETE REFRESH sẽ tốn nhiều thời gian,
* FAST: REFRESH những phần mới từ lần gần đây nhất. thời gian cho mỗi lần FAST REFRESH sẽ được rút ngắn tối thiểu.
* FORCE: là default của REFRESH. Oracle sẽ cố FAST REFRESH, và nếu không được thì sẽ COMPLETE REFRESH

Bạn có thể hình dung mỗi lần Oracle tính toán và ra kết quả cho MATERIALZED VIEW, bạn sẽ có 1 snapshot. 
Đến lần sau khi FAST REFRESH bạn sẽ update laị kết quả từ last snapshot lần trước. 
Tất nhiên cái giá phải trả cho việc có được thời gian REFRESH ngắn là sẽ mất thêm dung lượng đĩa cứng để lưu các snapshot ! 
Tuy nhiên để application chạy được smoothly hết mức có thể thì tốc độ luôn là ưu tiên hàng đầu :D

Vậy snapshot (hay là change log) của MATERIALZED VIEW là gì ? Chúng ta đang nói đến object đề cập ở bên trên: MATERIALIZED VIEW LOG

Cần lưu ý là COMPLETE hay FAST là phương pháp REFRESH (how). 
Còn thời điểm REFRESH (when) sẽ định nghĩa khi nào thì MATERIALZIED VIEW được REFRESH. Có 2 mode cơ bản là manually (ON DEMAND) và automatically (ON COMMIT, DBMS_JOB).
ON DEMAND là khi nào bạn (user) ra lệnh REFRESH, ON COMMIT là khi nào MATERIALZED bị thay đổi (COMMIT), còn DBMS_JOB là cho REFRESH thành 1 job được đặt lịch sẵn (giống như cron của Unix system :D) 

MATERIALIZED còn có nhiều điểm cần lưu ý khi áp dụng cụ thể. Bài viết chỉ trình bày những khái niệm cơ bản nhất. Bạn có thể xem thêm các restriction và cách create cụ thể tại [Oracle Doc](http://docs.oracle.com/cd/E11882_01/server.112/e10706/repmview.htm)
 

## TRIGGER

Nếu bạn đã biết TRIGGER trong MySQL thìcó lẽ sẽ không thấy lạ lẫm với obejct này lắm. TRIGGER về cơ bản là để định nghĩa các action tự động khi có 1 event xảy ra.

Ví dụ: Khi bạn có table Users và 2 table Students, Teachers. Bạn muốn khi 1 User mới được INSERT vào table Users, có thể phán đoán dựa theo conđition để cùng insert vào table Students hoặc Teachers 

{% codeblock materialized_view.sql %}
CREATE OR REPLACE TRIGGER teacher_trigger
   before insert 
   ON USERS 
   FOR EACH ROW
   WHEN (NEW.FIELD1= 'TEACHER_CONDITION') -- Or any other condition
BEGIN

    INSERT INTO TEACHERS (col1, col2) VALUES (:NEW.col1, :NEW.col2);

END;

CREATE OR REPLACE TRIGGER student_trigger
   after insert 
   ON USERS 
   FOR EACH ROW
   WHEN (NEW.FIELD1= 'STUDENT_CONDITION') -- Or any other condition
BEGIN

    INSERT INTO STUDENTS (col1, col2, col3) VALUES (:NEW.col1, :NEW.col2, :NEW.col3);

END;

/

{% endcodeblock %}
 

Bạn có thể thấy ở đoạn code trên, TRIGGER có thể được fire BEFORE hoặc AFTER event mà bạn định nghĩa. 
Event trong trường hợp này là INSERT vào table USERS, thuộc loại DML statements (INSERT, UPDATE, DELETE trong các table...). 
TRIGGER còn có thể fire on DDL statements (CREATE hoặc ALTER table ...) và Database events (logon. logoff, startup, shutdown ..)

## PL/SQL (Procedural Language/Structured Query Language) và PACKAGE Object 
PL/SQL Là 1 procedutal programming language, trong khi SQL chỉ là declarative language. 
Điều đó có nghĩa bạn có thể viết PL/SQL giống như các ngôn ngữ phổ biến khác. 
PL/SQL cũng có variable, có try catch exception, có if-statement, loop, function, regex, convert, file reader ... đẩy đủ các builtin function mà Oracle đã chuẩn bị sẵn. 
PL/SQL còn nắm lợi thế là thao tác trực tiếp với cursor, table, view, materialized view... các object của Database, remote action qua DB_LINK ... 

Như vậy với năng lực của 1 ngôn ngữ hoàn chỉnh, cộng với khả năng tương tác với DB giống như SQL, PL/SQL được dùng để đóng gói xử lý trên DB server.

Bạn có thể developer web application = Java, Ruby, PHP v.v... chỉ gọi đến DB thông qua các PACKAGE object. 
Mỗi PACKAGE (viết bằng PL/SQL) là 1 "gói" Được viết như 1 module xử lỹ nội bộ trong Oracle DB. 
Ưu điểm của phương pháp này là tốc độ xử lý sẽ được cải thiện, và communication giữa Application server vs DB server (chỉ là truyền parameter cho PACKAGE và nhận lại result từ PACKAGE) được giảm thiểu. 
 
VD: với xử lý như sau:

* PHP validate 1 string ADD_ME và nhận 1 string UserId từ user input (trong request gửi đến web server)
* Nếu ADD_ME không tồn tại trong table USERS, insert 1 record mới vào table USERS
* Nếu ADD_ME = "teacher", kiểm tra xem trong table TEACHERS có tồn tại UserID không
* Nếu trong table TEACHERS không có UserID, INSERT 1 record vào table TEACHERS 
* Nếu ADD_ME = "student", kiểm tra xem trong table STUDENTS có tồn tại UserID không
* Nếu trong table STUDENTS không có UserID, INSERT 1 record vào table STUDENTS 
...
(Lặp lại n lần với n table khác nhau)

Như vậy trong các bước kể trên, ngoại trừ bước đầu tiên, tất cả các bước còn lại đều phải init connection từ Application server đến DB server. (Không quan tâm bạn dùng DAO hay ORM hay execute query thẳng trên DB)

Tôi có thể designed lại xử lý trên như sau:

* PHP validate 1 string ADD_ME và nhận 1 string UserId từ user input (trong request gửi đến web server)
* PHP truyền parameter ADD_ME và UserId cho PACKAGE "EVALUATE_USER" của Oracle
* "EVALUATE_USER" does all the stuff :D
* "EVALUATE_USER" trả kết quả về cho PHP : 0: kết thúc không có lỗi, 1: Kết thúc với lỗi ở TABLE USERS, 2: Kết thúc với lỗi ở TABLE TEACHER, .....

Như vậy connection từ Application server sang DB server chỉ phát sinh ở bước 2 và bước 4. Tôi dám cá là bạn hệ thống sẽ sppedup với 1 tốc độ không nhỏ :D 


## Kết luận
* MATERIALIZED VIEW LOG : là snapshot, là obecjt bắt buộc phải có khi dùng MATERIALZED VIEW với chiến lược FAST REFRESH .
* TRIGGER: Là object định nghĩa sẽ fire event nào khi các action nào được thực hiện trong database.
* PL/SQL: Là extend của SQL, produceral programming language của Oracle, cho phép thao tác trực tiếp với các object của Database trên Database server với đầy đủ năng lực xử lý như 1 ngôn ngữ hoàn chỉnh 
