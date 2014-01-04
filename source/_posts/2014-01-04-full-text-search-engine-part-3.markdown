---
layout: post
title: "Full Text Search, Từ Khái Niệm đến Thực Tiễn (Phần 3)"
date: 2014-01-04 21:23
comments: true
categories: 
---

#Introduction
Trong [phần 2](http://ktmt.github.io/blog/2013/11/03/full-text-search/), chúng ta đã nắm được một kĩ thuật cơ bản và quan trọng để tạo ra search-engine, đó chính là kĩ thuật tách chữ (Tokenize), thông qua 2 phương pháp chính là N-gram và Morphological Analysis. Nhờ có kĩ thuật này mà văn bản gốc sẽ được bóc tách thành các kí tự, sau đó sẽ được lưu trữ dưới dạng Inverted Index như đã giới thiệu ở [phần 1](http://ktmt.github.io/blog/2013/10/27/full-text-search-engine/).

Trong bài viết này, chúng ta sẽ tìm hiểu là làm thế nào, mà khi được cung cấp đầu vào là một chuỗi truy vấn (query string), search engine sẽ cung cấp được cho chúng ta kết quả phù hợp nhất. Về cơ bản, để tìm kiếm bên trong một khối dữ liệu khổng lồ đã được index dưới dạng "Inverted Index", search-engine sẽ sử dụng "Boolean Logic".

#Boolean Logic và tại sao Search Engine lại sử dụng Boolean Logic
Khi nhắc đến Boolean Logic, các bạn sẽ hình dung ra trong đầu những hình ảnh như thao tác AND/OR/XOR với bit, mạch logic trong điện tử số, hay biểu đồ ven. 
Đối tượng thao tác của Boolean Logic có thể là bit, cổng logic, hay là tập hợp (set). 
Trong bài này, Boolean Logic sẽ được nhắc đến với đối tượng là tập hợp (set), và hình ảnh dễ hình dung nhất khi thao tác với đối tượng này chính là biểu đồ Ven.

Để tìm hiểu mối liên quan giữa Boolean Logic và Search Engine, chúng ta hãy thử hình dung cơ chế của Search Engine. 
Khi được cung cấp một chuỗi truy vấn (query string), việc đầu tiên Search Engine sẽ phải sử dụng Parser module để bóc tách chuỗi truy vấn này theo một **ngữ pháp** đã được qui định trước, để tạo thành các token sử dụng cho logic tìm kiếm. 
Việc sử dụng Parser này cũng giống như compiler hay intepreter sẽ sử dụng các cú pháp đã được định nghĩa trước của một ngôn ngữ bất kỳ để dịch một đoạn code ra mã máy hoặc là bytecode. 
Ngữ pháp qui định trước càng phức tạp, không chỉ dẫn đến việc parse chuỗi truy vấn trở nên phức tạp hơn, việc viết ra một câu truy vấn phức tạp hơn (ảnh hưởng đến người dùng),  mà còn khiến logic tìm kiếm cũng trở nên phức tạp, qua đó làm giảm hiệu suất của việc tìm kiếm. 
Chính vì thế mà việc tận dụng một ngữ pháp gần giống với Boolean Logic không những sẽ giúp giữ cho độ phức tạp khi parse query string ở mức thấp, mà nó còn giúp cho người dùng tạo ra những câu truy vấn dễ hiểu hơn.

#Sử dụng Boolean Logic trong Search Engine
Boolean logic sử dụng trong Search Engine thường sẽ gồm 3 phép toán chính là **AND**, **NOT** **và OR**
Hãy trở lại ví dụ gần giống trong [phần 1](http://ktmt.github.io/blog/2013/10/27/full-text-search-engine/), chúng ta có 5 documents {D1, D2, D3, D4, D5} đã được index như sau:

```
D1 = "This is first document"
D2 = "This is second one"
D3 = "one two"
D4 = "This one is great"
D5 = "This two is great!"
```

```
"this" => {D1, D2, D4, D5}
"is" => {D1, D2, D4, D5}
"first" => {D1}
"document" => {D1}
"second" => {D2}
"one" => {D2, D3, D4}
"two" => {D3, D5}
```

Giả sử chúng ta muốn query một câu truy vấn như sau : "This one". Sử dụng Morphological Analysis đã giới thiệu trong [phần 2](http://ktmt.github.io/blog/2013/11/03/full-text-search/), chúng ta sẽ tách câu truy vấn đó thành 2 token là "This" và "one". 
Bỏ qua yếu tố chữ hoa và chữ thường, thì "This" đã được index {D1, D2, D4, D5}, và "one" đã được index {D2, D3, D4}. 

Thông thường để cho dễ hiểu và phù hợp với logic của người dùng, thì space sẽ tương đương với logic AND, hay là việc tìm kiếu "This one" sẽ tương đương với kết tìm kiếm "This" AND với kết quả tìm kiếm "one". 
Hay như trong ví dụ này thì kết quả tìm kiếm sẽ là kết quả AND của 2 set {D1, D2, D4, D5} và {D2, D3, D4}.
Kết quả này có thể thấy dễ dàng là {D2, D4}

Vậy nếu người dùng input là "This OR one" thì sao? Lúc này kết quả tìm kiếm sẽ là 
```
{D1, D2, D4, D5} OR {D2, D3, D4} = {D1, D3, D5}
```
Từ ví dụ trên chúng ta thấy rằng độ phức tạp của việc tìm kiếm lúc này sẽ chuyển thành 
```
Độ phức tạp của parse query string(1) 
+ Độ phức tạp của Index lookup(2) 
+ Độ phức tạp của thao tác boolean Logic dựa trên kết quả của Index lookup(3)
```

\(1\) thường sẽ không lớn do query string do user input khá ngắn, và trong trường hợp query string được generate phức tạp khi sử dụng lucene hoặc solr, thì việc sử dụng boolean logic rất đơn giản cũng làm độ phức tạp khi parse query string là không cao.

\(2\) Độ phức tạp của Index lookup tương đương với việc tìm kiếm giá trị của một key trong Hash table, chỉ khác là trên HDD, tuy nhiên so sánh với việc tìm kiếm trên BTree của MySQL thì performance của xử lý này là hoàn toàn vuợt trội.

\(3\) Thao tác này có thể được optimize rất nhiều dựa vào các lý thuyết tập hợp, hay các thư viện toán học cho big number.

Như vậy chúng ta có thể thấy bài toán tìm kiếm ban đầu đã được đưa về 3 bài toán nhỏ hơn, dễ optimize hơn.

#Kết luận
Bài viết đã giới thiệu về việc sử dụng Boolean Logic trong Full Text Search Engine. Qua đó các bạn chắc đã hình dung ra phần nào khi các bạn gõ một câu lệnh tìm kiếm vào ô tìm kiếm của Google, những gì sẽ xảy ra đằng sau (mặc dù trên thực tế những gì google làm sẽ phức tạp hơn rất nhiều).

Tham khảo:

- [Make Findspot](http://gihyo.jp/dev/serial/01/make-findspot)
