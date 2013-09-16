---
layout: post
title: "Data Analysis - Pig Latin Programming"
date: 2013-09-16 17:21
comments: true
categories:
  - Data Analytic
  - Pig Latin
  - Map-Reduce
---

## Giới thiệu về Data Analysis bằng Pig Latin

Nếu bạn đã từng làm việc với DB, chắc hẳn đã nghe đến Hadoop và Map-Reduce.

Map-Reduce, hay NoSQL style quả thực là 1 phương pháp tiếp cận ko thể thiếu cho các hệ Database lớn, tuy nhiên lượng knowhow cần phải có và phương pháp tư duy đặc thù là những rào cản lớn đối với những Data Analyser hay ngay cả những DB engineer thông thường.

Một Data Analyser muốn viết được job cho Map-Reduce, trước hết phải có kỹ năng của 1 Java Engineer, phải re-invent 1 số hàm common (JOIN, FILTER ...)

Yahoo đã giới thiệu 1 hướng tiệp cận khác: Pig Latin, là 1 programming language build trên top của Hadoop, cú pháp tương đối giống SQL thuần tuý, tuy nhiên ở tầng dưới có thể "translate" program execution thành các job Map-Reduce và trả lại kết quả với tốc độ của Map-Reduce.

Pig Latin (kể từ đây sẽ gọi tắt là "Pig" :D ) với bộ engine đằng sau là Java, có thể extend bằng các thư viện viết = Java hay thậm chí Python.

Pig có hiệu suất phát triển cao, nghĩa là thay vì bỏ ra 1 tiếng để viết job 100 lines Map-Reduce bằng Java, bạn có thể chỉ cần 10 phút với 10 lines Pig :D

Ở các phần tiếp theo của bài viết này, bạn sẽ được giới thiệu những bước đầu của Pig Developer

## Get Start
Rất may là chúng ta không phải ngồi tưởng tượng chay cách hoạt động của Pig.
Cloudera có [free VM image](http://blog.cloudera.com/blog/2012/08/hadoop-on-your-pc-clouderas-cdh4-virtual-machine/), bạn chỉ cần down bản tương ứng về chạy trên Virtual Box hoặc VMWare.

Pig có cấu trúc khá tương đồng với SQL. Trước hết để làm với 1 cục dữ liệu cần phân tích, cần LOAD cả cục lên rồi tiến hành "mổ xẻ", sau đó STORE lại 1 file kết quả.

{% codeblock  sample.pig %}

city = LOAD '/input/gotham/people.txt' AS (name:chararray, age:int, income:int);
citizens = ORDER city BY age;
max_age = LIMIT citizens 1;
STORE max_age INTO 'output/gotham/analysis1.txt'

{% endcodeblock %}

people.txt là data đầu vào được tạo ra từ table trong DB.

## Basic functions

Về cơ bản Pig có những function/commands sau :

* LOAD, STORE: lấy dữ liệu trước khi xử lý và lưu sau khi xử lý. Ngoài ra DUMP có thể dùng để debug kiểu data
* GROUP, FILTER, ORDER BY, DISTINCT, LIMIT, UNION: những xử lý cơ bản giống hệt SQL.
* FOREACH: loop function, để tạo nest operator (có thể hiểu đơn giản như cách tạo sub-query)
* JOIN: giống JOIN của SQL, cũng có INNER, LEFT OUTER hay RIGHT OUTER... Những bước JOIN trong Pig thường là những bước quan trọng khi muốn tạo relation từ 2 cục data riêng rẽ trở lên
* Eval functions (MAX, AVG, COUNT, SUM....)
* Math functions (SIN, COS, TAN, SQRT, ...)
* Tuple. Bag, Map functions. Phần này khá là khó và tác giả cũng không có nhiều kinh nghiệm sử dụng
* UDF (User Define Functions): là functions do developer tự viết bằng Java hoặc Python :D

Bạn có thể xem cụ thể ở [Pig Latin Basics](http://pig.apache.org/docs/r0.10.0/basic.html) hoặc [Pig Latin Built In Functions](http://pig.apache.org/docs/r0.10.0/func.html)

## Challenge 1: GROUP và FOREACH

Bài toán đơn giản đầu tiên, với data đầu vào là thông tin của các công dân thành phố gotham như ở trên, ta cần tìm người có giảu nhất (Income cao nhát) trong các nhóm độ tuổi 20~30, 30~40, 40~50, v.v..

{% codeblock  sample.pig %}

city = LOAD '/input/gotham/people.txt' AS (name:chararray, age:int, income:int);
city_divide = FOREACH city GENERATE
	name,
	age/10 AS class,
	income;
city_classes = GROUP city_divide BY class;
citizens = FOREACH city_classes {
	ord = ORDER city_divide BY income;
	lim = LIMIT ord BY 1;
	GENERATE class*10 as class, lim.name AS name, lim.income AS income;

STORE citizens INTO 'output/gotham/analysis2.txt'

{% endcodeblock %}

			city												city_classes

╒=====================╕    ╒==============================================╕
|	Batman, 25, 5000000 |    |		(2,{Batman,2,5000000},{Joker,2,2000000})  |
|	Joker, 	24, 2000000 |    |    (3,{Bane,3,200000},{Gordon,3,500000})			|
|	Bane, 	31,  200000 | 	 |		(6,{Alfred,6,500000})											|
|	Alfred,	60,  500000 |    ╘==============================================╛
|	Gordon,	35,  500000 |
╘=====================╛


			citizens
╒=====================╕
|		20,Batman,5000000 |
|		30,Gordon, 500000 |
|		60,Alfred, 500000 |
╘=====================╛

Đến đây chắc độc gỉả đã phần nào hình dung được data analyser dùng Pig Latin như thế nào :D


## Challende 2: JOIN
... Còn tiếp ...
