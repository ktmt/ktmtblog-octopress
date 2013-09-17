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

Map-Reduce, hay NoSQL style là một phương pháp tiếp cận ko thể thiếu cho các database lớn, tuy nhiên lượng knowhow cần phải có và phương pháp tư duy đặc thù là những rào cản lớn đối với những Data Analyser hay ngay cả những DB engineer thông thường.

Một Data Analyser muốn viết được job cho Map-Reduce, trước hết phải có kỹ năng của 1 Java Engineer, phải re-invent 1 số hàm common (JOIN, FILTER ...)

Yahoo đã giới thiệu 1 hướng tiệp cận khác: Pig Latin, là 1 programming language build trên top của Hadoop, cú pháp tương đối giống SQL thuần tuý, tuy nhiên ở tầng dưới có thể "translate" program execution thành các job Map-Reduce và trả lại kết quả với tốc độ của Map-Reduce.

Pig Latin (kể từ đây sẽ gọi tắt là "Pig" :D ) với bộ engine đằng sau là Java, có thể extend bằng các thư viện viết = Java hay thậm chí Python. Pig có hiệu suất phát triển cao, nghĩa là thay vì bỏ ra 1 tiếng để viết job 100 lines Map-Reduce bằng Java, bạn có thể chỉ cần 10 phút với 10 lines Pig :D

Ở các phần tiếp theo của bài viết này, bạn sẽ được giới thiệu những bước học hỏi đầu tiên của Pig Developer.

## Get Start
Rất may là chúng ta không phải ngồi tưởng tượng chay cách hoạt động của Pig.
Cloudera có [free VM image](http://blog.cloudera.com/blog/2012/08/hadoop-on-your-pc-clouderas-cdh4-virtual-machine/), bạn chỉ cần down bản tương ứng về chạy trên Virtual Box hoặc VMWare.

Pig có cấu trúc khá tương đồng với SQL. Trước hết để làm với 1 cục dữ liệu cần phân tích, cần LOAD cả cục lên rồi tiến hành "mổ xẻ", sau đó STORE lại 1 file kết quả.

{% codeblock  sample.sql %}

city = LOAD '/input/gotham/people.txt' AS (name:chararray, age:int, income:int);
citizens = ORDER city BY age;
max_age = LIMIT citizens 1;
STORE max_age INTO 'output/gotham/analysis1.txt'

{% endcodeblock %}

people.txt là data đầu vào được tạo ra từ table trong DB.

## Basic functions

Về cơ bản Pig có những function/commands sau :

* LOAD, STORE: lấy dữ liệu trước khi xử lý và lưu sau khi xử lý. Ngoài ra DUMP có thể dùng để debug kiểu data.
* GROUP, FILTER, ORDER BY, DISTINCT, LIMIT, UNION: những xử lý cơ bản giống hệt SQL.
* FOREACH: loop function, để tạo nest operator (có thể hiểu đơn giản như cách tạo sub-query).
* JOIN: giống JOIN của SQL, cũng có INNER, LEFT OUTER hay RIGHT OUTER... Những bước JOIN trong Pig thường là những bước quan trọng khi muốn tạo relation từ 2 cục data riêng rẽ trở lên.
* Eval functions (MAX, AVG, COUNT, SUM....).
* Math functions (SIN, COS, TAN, SQRT, ...).
* Tuple. Bag, Map functions. Phần này khá là khó và tác giả cũng không có nhiều kinh nghiệm sử dụng.
* UDF (User Define Functions): là functions do developer tự viết bằng Java hoặc Python :D

Bạn có thể xem cụ thể ở [Pig Latin Basics](http://pig.apache.org/docs/r0.10.0/basic.html) hoặc [Pig Latin Built In Functions](http://pig.apache.org/docs/r0.10.0/func.html)

## Challenge 1: GROUP và FOREACH

Bài toán đơn giản đầu tiên, với data đầu vào là thông tin của các công dân thành phố gotham như ở trên, ta cần tìm người giàu nhất (income cao nhất) trong các nhóm độ tuổi 20~30, 30~40, 40~50, v.v..

{% codeblock  sample.sql %}

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

Đến đây chắc độc gỉả đã phần nào hình dung được data analyser dùng Pig Latin như thế nào :D

## Challende 2: JOIN
Giả sử ngoài data về từng công dân của gotham, chúng ra có 1 data khác về các ..."super heroes", bao gồm "strength", "ability". Làm thế nào để biết các "super heroes" có thu nhập bao nhiêu trong cuộc sống thường ngày của họ ?

{% codeblock  sample.sql %}

city = LOAD '/input/gotham/people.txt' AS (name:chararray, age:int, income:int);
heroes = LOAD '/input/gotham/heroes.txt' AS (name:chararray, strength:int, ability:chararray);

op = JOIN city BY name, heroes BY name;
opt = FOREACH op GENERATE
	$0 AS name,
	$1 AS age,
	$2 AS income,
	$4 AS strength,
	$5 AS ability;
STORE opt INTO 'output/gotham/analysis3.txt'

{% endcodeblock %}

Ở đây bạn có thể để ý $0, $1, $2 lần lượt là name, age, income của biến city, $3, $4, $5 là name, strength, ability của biến heroes. Như vậy kết quả sau khi JOIN gồm tất cả các fields của 2 biến JOIN thành phần!

## Pig Tuning
Qua 2 ví dụ trên đây, bạn có thể thế thấy Pig dễ phát triển như thế nào.
Tuy nhiên khi engineer hoàn toàn không có kinh nghiệm về Map-Reduce viết Pig thì chắc chắn sẽ không thể biết cách optimize để các job Hadoop bên dưới đạt tốc độ nhanh nhất có thể.

Để giữ có Pig program có hiệu suất xử lý cao, engineer có thể áp dụng các trick dưới đây:

* Dùng FILTER nhiều nhất và sớm nhất có thể. Nếu bạn JOIN a và b rồi lại FILTER, thì hãy tìm cách FILTER a và b trước rồi hãy JOIN.

* Loại bỏ các cột (các fields) không cần thiết. Giả sử biến a có 11 fields và bạn chỉ cần 7 fields, hãy "FOREACH a GENERATE ($0...$6)" để lập tức loại bỏ 4 fields.

* PARALLEL là 1 magic keyword. Dùng PARALLEL để chỉ định số lượng reduceers.

## UDFs

Điều cuối cùng tác giả muốn chia sẻ, là khi bạn có những tasks xử lý nhỏ sử dụng nhiều lần với các fields, hãy cố gắng viết UDFs để xử lý. Pig được ship cùng với 1 package UDF viết sẵn [Piggy Bank](https://cwiki.apache.org/confluence/display/PIG/PiggyBank).

UDF có thể viết bằng Java hoặc Python. Java UDFs có tốc độ và khả năng ứng dụng trong Pig tốt hơn. Khi đã làm chủ được cấu trúc dữ liệu giữa Python/Java và Pig, bạn sẽ thấy UDFs là một feature mạnh mẽ và không thể sống thiếu :D


## Tóm tắt:
* Pig Latin: Ngôn ngữ được build trên top của Hadoop, với bộ core Java và engine có thể translate logic sang 1 set các Map-Reduce Jobs.
* VM có thể dùng cho mục đích học hỏi từ đầu [Cloudera Pig VM image](http://blog.cloudera.com/blog/2012/08/hadoop-on-your-pc-clouderas-cdh4-virtual-machine/).
* Tất cả các hàm có thể tra cứu tại [Pig Latin Built In Functions](http://pig.apache.org/docs/r0.10.0/func.html).
* UDFs được viết sẵn [Piggy Bank](https://cwiki.apache.org/confluence/display/PIG/PiggyBank).
* [Slide giới thiệu tổng hợp của Cloudera](http://blog.cloudera.com/wp-content/uploads/2010/01/IntroToPig.pdf).










