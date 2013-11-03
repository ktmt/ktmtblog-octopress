---
layout: post
title: "Full Text Search, Từ Khái Niệm đến Thực Tiễn (Phần 2)"
date: 2013-11-03 20:21
comments: true
categories: 
---

#Introduction
Trong [phần 1](http://ktmt.github.io/blog/2013/10/27/full-text-search-engine/), chúng ta đã tìm hiểu sơ qua về khái niệm Full Text Search, cũng như về Inverted Index.
Qua bài viết đầu tiên, các bạn đã nắm được tại sao Inverted Index lại được sử dụng để tăng tốc độ tìm kiếm trong một "Full Text Database".
Đồng thời ở ví dụ của phần một, các bạn cũng đã thấy, để tạo ra Inverted Index thì các bạn phải tách được một string ra thành các **term**, sau đó sẽ index string đó theo term đã tách được. Chính vì thế việc **tách string**, hay còn gọi là **Tokenize** là một bài toán con quan trọng nằm trong bài toán lớn của Full Text Search.
Ở bài này, chúng ta sẽ tìm hiểu về 2 kĩ thuật Tokenize cơ bản là:

- N-Gram
- Morphological Analysis

#N-gram
N-gram là kĩ thuật tokenize một chuỗi thành các chuỗi con, thông qua việc **chia đều** chuỗi đã có thành các chuỗi con đều nhau, có độ dài là N.
Về cơ bản thì N thường nằm từ 1~3, với các tên gọi tương ứng là unigram(N==1), bigram(N==2), trigram(N==3).
Ví dụ đơn giản là chúng ta có chuỗi "good morning", được phân tích thành bigram:

```
"good morning" => {"go", "oo", "od", "d ", " m", "mo", "or", "rn", "ni", "in", "ng"}
```
Từ ví dụ trên các bạn có thể dễ dàng hình dung về cách thức hoạt động của N-gram.
Để implement N-gram, chỉ cần một vài ba dòng code như sau, như ví dụ viết bằng python như sau:

```python
def split_ngram(self, statement, ngram):
    result = []
    if(len(statement) >= ngram):
      for i in xrange(len(statement) - ngram + 1):
        result.append(statement[i:i+ngram])
    return result
```

#Morphological Analysis
Morphological Analysis, rất may mắn có định nghĩa trên [wikipedia](http://vi.wikipedia.org/wiki/H%C3%ACnh_th%C3%A1i_h%E1%BB%8Dc_(ng%C3%B4n_ng%E1%BB%AF_h%E1%BB%8Dc) bằng tiếng Việt.
Định nghĩa khá dài dòng, các bạn có thể xem bằng [Tiếng Anh](http://en.wikipedia.org/wiki/Morphology_(linguistics)
Về cơ bản Morphological Analysis (từ bây giờ mình sẽ gọi tắt là MA), là một kĩ thuật phổ biến trong xử lý ngôn ngữ tự nhiên (Natural Language Processing).
Morphological chính là "cấu trúc" của từ, như vậy MA sẽ là "phân tích cấu trúc của từ", hay nói một cách rõ ràng hơn, MA sẽ là kĩ thuật tokenize mà để tách một chuỗi ra thành các từ có ý nghĩa. Ví dụ như cũng cụm từ "good morning" ở trên, chúng ta sẽ phân tích thành:

```
"good morning" => {"good", "morning"}
```
Để có được kết quả phân tích như trên, ngoài việc phải sở hữu một bộ từ điển tốt (để phân biệt được từ nào là có ý nghĩa, và thứ tự các từ thế nào thì có ý nghĩa), MA phải sử dụng các nghiên cứu sâu về xử lý ngôn ngữ tự nhiên, mà mình sẽ không đi sâu ở đây.
Thông thường các công ty lớn sở hữu các search engine của riêng họ(như Yahoo, Google, Microsoft..) sẽ có các đội ngũ nghiên cứu để tạo ra nhiều bộ thư viện MA riêng của họ, thích hợp với nhiều ngôn ngữ.
Ngoài ra chúng ta cũng có thể sử dụng các bộ thư viện được open source, hoặc sử dụng các package có sẵn trong các bộ full text search engine mà tiêu biểu là lucene.

#Mở rộng
Các bạn đọc đến đây chắc hẳn sẽ có suy nghĩ, để phân tách chuỗi, thì rõ ràng phân tích theo MA là quá hợp lý rồi, tại sao lại cần N-gram làm gì?
Như mình đã nói ở trên, để xây dựng MA thì cần một bộ từ điển tốt, để giúp cho máy tính có thể phân biệt được các từ có nghĩa.
Như thế nào là một từ điển tốt, thì về cơ bản, từ điển tốt là từ điển chứa càng nhiều từ (terms) càng tốt.
Tuy nhiên ngôn ngữ thì mỗi ngôn ngữ lại có đặc trưng riêng, và không ngừng mở rộng, không ngừng thêm các từ mới.
Việc chỉ sử dụng MA sẽ gây ra một tác dụng phụ là có rất nhiều từ không/chưa có trong từ điển, dẫn đến không thể index, và do đó sẽ không thể tiến hành tìm kiếm từ đó được.

Vậy cách giải quyết như thế nào?
Cách giải quyết tốt nhất là chúng ta sẽ **kết hợp(hybrid)** cả MA và N-gram. Cách hybrid thế nào thì sẽ tuỳ vào ngôn ngữ/ hoàn cảnh sử dụng, và cả performance cần thiết nữa. Về cơ bản thì những từ nào khó/không có thể phân tích được bằng MA, thì chúng ta sẽ dùng N-gram.

#Kết luận
Qua bài viết lần này, các bạn đã hiểu thêm về 2 kĩ thuật tách từ (tokenize) cơ bản là N-gram và MA.

Sử dụng 2 kĩ thuật này như thế nào để index dữ liệu đầu vào, sẽ được giới thiệu trong các bài viết sắp tới.
