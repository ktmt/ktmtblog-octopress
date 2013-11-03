---
layout: post
title: "Full Text Search, từ khái niệm đến thực tiễn (phần 1)"
date: 2013-10-27 22:21
comments: true
categories: 
  - search-engine
  - solr
  - lucene
---

#Lời nói đầu
Là một lập trình viên mà đã từng phải thao tác với cơ sở dữ liệu, hay đơn thuần là đã từng là một trang web bán hàng ,chắc hẳn các bạn đã từng nghe qua về khái niệm "Full text search". Khái niệm này đã được định nghĩa khá cụ thể và đầy đủ trên [wikipedia](http://en.wikipedia.org/wiki/Full_text_search). Nói một cách đơn giản, "Full text search" là kĩ thuật tìm kiếm trên "Full text database", ở đây "Full text database" là cơ sở dữ liệu chứa "toàn bộ" các kí tự (text) của một hoặc một số các tài liệu, bài báo.. (document), hoặc là của websites. Trong loạt bài viết này, mình sẽ giới thiệu về Full Text Search, từ khái niệm đến ứng dụng thực tiễn của kĩ thuật này. Chuỗi bài viết không nhằm giúp bạn tìm hiểu cụ thể về Full Text Search technique trong MySQL, Lucene hay bất kì search engine nào nói riêng, mà sẽ giúp bạn hiểu thêm vầ bản chất của kĩ thuật này nói chung. Ở bài viết cuối cùng, mình sẽ cùng các bạn implement thử một "Full Text Search engine" sử dụng python, qua đó giúp các bạn nắm rõ hơn cốt lõi của vấn đề.

Trong phần đầu tiên mình sẽ giới thiệu về định nghĩa của Full text search, và khái niệm cơ bản nhất trong Full Text Search, đó là Inverted Index. 

#Introduction
Chắc hẳn các bạn đã từng dùng qua một kĩ thuật tìm kiếm rất cơ bản, đó là thông qua câu lệnh **LIKE** của SQL.
```sql
SELECT column_name(s)
FROM table_name
WHERE column_name LIKE pattern;
```
Sử dụng **LIKE**, các bạn sẽ chỉ phải tìm kiếm ở column đã định trước, do đó lượng thông tin phải tìm giới hạn lại chỉ trong các column đó. Câu lệnh LIKE cũng tương đương với việc bạn matching pattern cho "từng" chuỗi của từng dòng (rows) của field tương ứng, do đó về độ phức tạp sẽ là tuyến tính với số dòng, và số kí tự của từng dòng, hay chính là "toàn bộ kí tự chứa trong field cần tìm kiếm". Do đó sử dụng **LIKE** query sẽ có 2 vấn đề: 
 - 1) Chỉ search được trong row đã định trươc 
 - 2) Performance không tốt.

Như vậy chúng ta cần một kĩ thuật tìm kiếm khác, tốt hơn **LIKE** query, mềm dẻo hơn, tốt về performance hơn, đó chính là **Full text searchi**.

#Cơ bản về kĩ thuật Full text search
Về mặt cơ bản, điều làm nên sự khác biệt giữa Full text search và các kĩ thuật search thông thường khác chính là "Inverted Index". Vậy đầu tiên chúng ta sẽ tìm hiểu về Inverted Index

## Inverted Index là gì
Inverted Index là kĩ thuật thay vì index theo đơn vị row(document) giống như [mysql](http://dev.mysql.com/doc/refman/5.0/en/mysql-indexes.html) thì chúng ta sẽ tiến hành index theo đơn vị term. Cụ thể hơn, Inverted Index là một cấu trúc dữ liệu, nhằm mục đích map giữa **term**, và **các document chứa term đó**

Hãy xem ví dụ cụ thể dưới đây, chúng ta có 3 documents D1, D2, D3
```
D1 = "This is first document"
D2 = "This is second one"
D3 = "one two"
```
Inverted Index của 3 documents đó sẽ được lưu dưới dạng như sau:

```
"this" => {D1, D2}
"is" => {D1, D2}
"first" => {D1}
"document" => {D1}
"second" => {D2}
"one" => {D2, D3}
"two" => {D3}
```

Từ ví dụ trên các bạn có thể hình dung được về thế nào là Inverted Index. Vậy việc tạo index theo term như trên có lợi thế nào? Việc đầu tiên là inverted index giúp cho việc tìm kiếm trên full text database trở nên nhanh hơn bao giờ hết. Hãy giả sử bạn muốn query cụm từ "This is first", thì thay vì việc phải scan từng document một, bài toán tìm kiếm document chứa 3 term trên sẽ trở thành phép toán **union** của 3 tập hợp (document sets) của 3 term đó trong inverted index.

```
{D1, D2} union {D1, D2} union {D1} = {D1}
```

Một điểm lợi nữa chính là việc inverted index cực kì flexible trong việc tìm kiếm. Query đầu vào của bạn có thể là "This is first", "first This is" hay "This first is" thì độ phức tạp tính toán của phép union kia vẫn là không đổi.

Như vậy chúng ta đã hiểu phần nào về khái niệm "Thế nào là Inverted Index". Trong phần tiếp theo chúng ta sẽ tìm hiểu về cụ thể về cách implement của inverted index, và ứng dụng của inverted index vào việc tìm kiếm thông tin thông qua các kĩ thuật chính như: **tokenization technique** (thông qua N-Gram hoặc Morphological Analysis), **query technique** và **scoring technique**.


