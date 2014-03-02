---
layout: post
title: "Full Text Search từ khái niệm đến thực tiễn (Phần 4)"
date: 2014-03-03 01:43
comments: true
categories: 
---

#Introduction
Trong [phần 3](http://ktmt.github.io/blog/2014/01/04/full-text-search-engine-part-3/), các bạn đã được tìm hiểu về
việc sử dụng Boolean Logic để tìm ra các Document chứa các term trong query cần tìm kiếm. Vậy sau khi tìm được 
các Document thích hợp rồi thì chỉ việc trả lại cho người dùng, hay đưa lên màn hình? Bài toán sẽ rất đơn giản
khi chỉ có 5, 10 kết quả, nhưng khi kết quả lên đến hàng trăm nghìn, thì mọi việc sẽ không đơn giản là trả lại kết
quả nữa. Lúc đó sẽ có vấn đề mới cần giải quyết, đó là **đưa kết quả nào lên trước**, hay chính là bài toán về 
**Ranking**

Việc Ranking trong Full Text Search thông thường sẽ được thực hiện thông qua việc **tính điểm** các Document được
tìm thấy, rồi Rank dựa vào điểm số tính được. Việc tính điểm thế nào sẽ được thực hiện thông qua các công thức, hay
thuật toán, mà mình gọi chung là **Ranking Model**

#Ranking Model
Trong bài viết về [Ranking news](http://ktmt.github.io/blog/2013/08/06/a-little-bit-about-news-ranking/), mình đã 
nói về việc giải quyết một bài toán gần tương tự. Tuy nhiên bài toán lần này cần giải quyết khác một chút, đó là việc
Ranking sẽ phải thực hiện dựa trên mối quan hệ giữa "query terms" và "document".

Ranking Model được chia làm 3 loại chính: **Static, Dynamic, Machine Learning**.
Dưới đây mình sẽ giới thiệu lần lượt về mỗi loại này.

#Static
Static ở đây có nghĩa là, Ranking Model thuộc loại này sẽ **không phụ thuộc** vào mối quan hệ ngữ nghĩa giữa "query term"
và "document". Tại sao không phụ thuộc vào "query term" mà vẫn ranking được? Việc này được giải thích dựa theo quan điểm
khoa học là `độ quan trọng của document phụ thuộc vào mối quan hệ giữa các document với nhau`.

Chúng ta sẽ đi vào cụ thể một Ranking Model rất nổi tiếng trong loại này, đó chính là [PageRank](http://en.wikipedia.org/wiki/PageRank).
PageRank là thuật toán đời đầu của Google, sử dụng chủ yếu cho web page, khi mà chúng có thể "link" được đến nhau.
Idea của PageRank là "Page nào càng được nhiều link tới, và được link tới bởi các page càng quan trọng, thì score càng cao".
Để tính toán được PageRank, thì chúng ta chỉ cần sử dụng WebCrawler để crawl được mối quan hệ "link" giữa tất cả các trang web, 
và tạo được một Directed Graph của chúng. 

Chính vì cách tính theo kiểu, tạo được Graph xong là có score, nên mô hình dạng này được gọi là "Static".

Ngoài PageRank ra còn có một số thuật toán khác gần tương tự như [HITS](http://en.wikipedia.org/wiki/HITS_algorithm) đã từng được sử dụng
trong Yahoo! trong thời gian đầu.

#Dynamic
Ranking Model thuộc dạng Dynamic dựa chủ yếu vào **Mối quan hệ** giữa "query term" và "document".
Có rất nhiều thuật toán thuộc dạng này, có thuật toán dựa vào tần suất xuất hiện của "query term" trong document, 
có thuật toán lại dựa vào các đặc tính ngữ nghĩa (semantic) của query term , có thuật toán lại sử dụng những quan sát mang tính
con người như thứ tự xuất hiện các từ trong "query term" và thứ tự xuất hiện trong "document".

Một trong những thuật toán được sử dụng nhiều nhất là [TF-IDF](http://en.wikipedia.org/wiki/Tf%E2%80%93idf) (Term Frequency Inverse Document Frequency).
Thuật toán này dựa vào Idea là "query term" xuất hiện càng nhiều trong document, document sẽ có điểm càng cao.

Thuật toán này được biểu diễn dưới công thức sau
$$TF-IDF(t, d, D) = TF(t, d) * IDF (t, D)$$
Ở đây t là query term, d là document cần được score, và D là tập hợp "tất cả" các documents. Trong đó thì:
$$TF(t, d) = frequency(t, d)$$
$$IDF(t, D) = log{N \over \|\{d \in D : t \in d\}\|}$$

Một cách đơn giản thì:

- TF : tần suất xuất hiện của term t trong document d
- IDF : chỉ số này biểu hiện cho tần suất xuất hiện của term t trong toàn bộ các documents. t xuất hiện càng nhiều, chỉ số càng thấp (vì xuất hiện quá nhiều
đồng nghĩa với độ quan trọng rất thấp)

Công thức của TF-IDF đã phối hợp một cách rất hợp lý giữa tần suất của term và ý nghĩa/độ quan trọng của term đó.

Trong thực tế thì người ta hay sử dụng thuật toán [Okapi BM25](http://en.wikipedia.org/wiki/Okapi_BM25) hay gọi tắt là BM25, là một mở rộng của TF-IDF, nhưng thêm
một vài weight factor hợp lý.

#Machine Learning
Ngoài việc sử dụng các mối quan hệ đơn giản giừa query term và document, hay giứa document với nhau, thì gần đây việc sử dụng học máy (Machine Learning) trong
Ranking cũng đang trở nên rất phổ biến.
Để nói về Machine Learning thì không gian bài viết này có lẽ là không đủ, mình sẽ nói về ý tưởng của Model này.

Idea của việc sử dụng Machine Learning trong ranking là chúng ta sẽ sử dụng một mô hình xác suất để tính toán.
Cụ thể hơn là chúng ta sẽ sử dụng supervised learning, nghĩa là chúng ta sẽ có input là một tập dữ liệu X để training, một model M ban đầu,
một hàm error để so sánh kết quả output X' có được từ việc áp dụng model M vào query term, và một hàm boost để từ kêt quả của hàm error
chúng ta có thể tính lại được model M. 

Thuật toán gần đây được sử dụng khá nhiều trong Ranking model chính là Gradient Boosting Decision Tree mà các bạn có thể tham khảo ở [đây](https://www.cse.cuhk.edu.hk/irwin.king/_media/presentations/gbdt-tom.pdf)


#Conclusion
Bài viết đã giới thiệu về 3 mô hình chính dùng để Ranking kết quả tìm kiếm trong Full Text Search. 
Trong thực tế thì các công ty lớn nhưn Google, Yahoo, MS sẽ không có một mô hình cố định nào cả, mà sẽ dựa trên các kết quả có từ người dùng để liên tục cải thiện.
Không có một mô hinh nào là "đúng" hay "không đúng" cả, mà để đánh giá Ranking Model chúng ta sẽ phải dựa trên thông kê người dùng (như click rate, view time...).
Việc hiểu rõ Ranking Model sẽ giúp chúng ta build được một search engine tốt cho service của mình, đông thời cũng giúp ích rất nhiều cho việc SEO (Search Engine Optimization).

Tài liệu tham khảo:
- [Yahoo! Learning to Rank Challenge Overview](http://jmlr.org/proceedings/papers/v14/chapelle11a/chapelle11a.pdf)
