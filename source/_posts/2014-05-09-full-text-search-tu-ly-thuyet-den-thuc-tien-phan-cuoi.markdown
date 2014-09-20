---
layout: post
title: "Full Text Search từ lý thuyết đến thực tiễn (phần cuối)"
date: 2014-05-09 20:00
comments: true
categories: 
---

#Introduction
Trong loạt bài viết trước về Full-text search, mình đã giới thiệu về các khái niệm hết sức cơ bản để làm nên một search-engine:

- [Phần 1: Giới thiệu cơ bản: Inverted Index](http://ktmt.github.io/blog/2013/10/27/full-text-search-engine/) 
- [Phần 2: Kỹ thuật Tokenize](http://ktmt.github.io/blog/2013/11/03/full-text-search/)
- [Phần 3: Tìm kiếm sử dụng Boolean Logic](http://ktmt.github.io/blog/2014/01/04/full-text-search-engine-part-3/)
- [Phần 4: Các mô hình Ranking](http://ktmt.github.io/blog/2014/03/03/full-text-search-tu-khai-niem-den-thuc-tien-phan-4/)

Trong bài viết này, để khép lại loạt bài về Full-Text search, mình sẽ hướng dẫn cách làm một search engine hết sức đơn giản sử dụng inverted index. Sample code mình sẽ sử dụng Python để cho dễ hiểu.

#Code Design
Việc đầu tiên trước khi code chúng ta phải design xem chương trình của chúng ta sẽ gồm những module nào, nhiệm vụ mỗi module ra sao. Để design được thì chúng ta phải làm rõ yêu cầu bài toán và cách giải quyết. 

Bài toán trong bài viết này là **xây dụng một search engine**. Để cho đơn giản chúng ta sẽ xây dựng search engine trên command line, dựa trên đầu vào là các documents với format được định nghĩa trước. Trong bài này, mình sẽ sử dụng một sample nhỏ của twitter data như là input documents. Bài toán được tóm tắt lại như dưới đây:

```
Input document:
11  superkarafan  superkarafan  http://twitter.com/superkarafan Yes. He is Kendo Kobayashi. One of great JKamilia RT "@nicolexrina:  Is your twitter DP you? I have seen him in ametalk before!"
12  sao_mama  saomama http://twitter.com/sao_mama @miwauknow  持って行きたいけど、北海道からだから重い(T_T)飲むゼリーとかはダメなのかな。「SMT」のときそうしたんだけど・・・

Command-line Interface:
./searcher <word>
```

Như đã giới thiệu ở loạt bài trước, Full Text Search sử dụng inverted index để lưu lại term và các document chứa term đó:

```
"this" => {D1, D2, D3, D4}
```
Vì vậy chúng ta cần một module để lưu Structure này, chúng ta sẽ gọi module đó là DocID. DocID sẽ có nhiệm vụ là lưu term và một array để chứa id của các documents mà chứa term đó. 

Tuy nhiên chỉ lưu đơn thuần dữ liệu inverted index thì sẽ không đủ, chúng ta cần một module để lưu lại các document và ID của chúng để khi có kết quả tìm kiếm chúng ta có thể present kết quả dễ dàng hơn. Module này chúng ta sẽ gọi là Content. Content sẽ lưu lại Id và nội dung của document.

Chúng ta cũng sẽ cần một module để làm nhiệm vụ phân tích document ra thành các term như đã giới thiệu trong [Bài 2: Kỹ thuật Tokenize](http://ktmt.github.io/blog/2013/11/03/full-text-search/). Chúng ta sẽ gọi module này là Tokenizer.

Đã có Tokenizer, DocID, Content, chúng ta cần một module sử dụng cả 3 module này để lưu trữ thông tin được tạo ra từ Tokenizer vào DocID và Content, chúng ta sẽ gọi nó là Indexer.

Cuối cùng, chúng ta cần một module sử dụng boolean logic như đã giới thiệu trong [Bài 3](http://ktmt.github.io/blog/2014/01/04/full-text-search-engine-part-3/) để tìm kiếm. Chúng ta sẽ gọi module này là Searcher. Module Searcher sẽ có nhiệm vụ sử dụng tách query ra thành các term, search ra một tập document chứa các term đó, và present ra màn hình.

Tóm tắt lại chúng ta sẽ có các module sau:

- DocID : Lưu inverted index
- Content : Lưu id và dữ liệu thô từ input data
- Tokenizer : Bóc tách term
- Indexer : Sử dụng tokenizer để lưu thông tin
- Searcher : Tìm kiếm

#Implement
Để implement bài toán này chúng ta sẽ sử dụng python. Chúng ta cũng cần một thư viện để lưu lại/sử dụng (dump) dữ liệu (inverted index) ra file. Python có một thư viện rất tốt để dump data structure ra file gọi là Pickle. 

Sử dụng pickle, chúng ta sẽ lưu dữ liệu ra file và khi load chương trình lên sẽ sử load file vào data structure lên sau. Tách ra làm 2 bước như vậy giúp chúng ta tách biệt được 2 quá trình 1) Index và 2) Search, mà qua đó khi có thêm dữ liệu mới, index file sẽ được update thêm mà không ảnh hưởng đên Searcher.

Dưới đây chúng ta sẽ đi lần lượt vào implementation của từng module. Đầu tiên là DocID.

## DocID
{%codeblock DocID - DocID.py %}
import pickle

class DocID:
  def __init__(self):
    self.docIDTable = dict() 

  def get_doc_num(self):
    return len(self.docIDTable)

  def set(self, term, docID, termPos):
    value = self.docIDTable.get(term, [])
    value.append((docID, termPos))
    self.docIDTable[term] = value

  def get(self, term):
    return self.docIDTable.get(term, [])

  def dump(self, file):
    f = open(file, "w")
    pickle.dump(self.docIDTable, f)
    f.close()

  def load(self, file):
    f = open(file)
    self.docIDTable = pickle.load(f)
    f.close()
{% endcodeblock %}

Ở DocID chúng ta có property docIDTable được lưu dưới dạng dictionary của python, mà trong đó key là term , và value sẽ là array chứa Ids của các document chứa term đó. docIDTable chính là biểu diễn bằng code của inverted index data structure. 

Module DocID có các hàm dump và load để lưu dữ liệu ra file và load dữ liệu lên memory. 
Tiếp theo chúng ta sẽ đến với implemetation của module Content.

##Content
 
{%codeblock Content - Content.py %}
import pickle

class Content:
  def __init__(self):
    self.contentTable = dict()

  def get_content_num(self):
    return len(self.contentTable)

  def set(self, content):
    self.contentTable[self.get_content_num()] = content
    current_index = self.get_content_num() - 1
    return current_index
  
  def get(self, id):
    return self.contentTable.get(id)

  ...
{%endcodeblock%}

Module này chỉ nhằm nhiệm vụ lưu lại dữ liệu của document và Id của document đó. Việc này sẽ được thực hiện cũng qua dictionary của python, với key là Id của document, và value là content của document tương ứng.

Tiếp đến, module Tokenizer sẽ được implement như dưới đây

##Tokenizer
Để cho đơn giản, tokenizer của chúng ta sẽ sử dụng ngram.
{%codeblock Tokenizer - Tokenizer.py %}
class Tokenizer:
  def __init__(self, engine):
    self.engine = engine

  def split(self, statement, ngram):
    result = []
    if(len(statement) >= ngram):
      for i in xrange(len(statement) - ngram + 1):
        result.append(statement[i:i+ngram])
    return result
{%endcodeblock%}

##Indexer
{%codeblock Indexer - Indexer.py %}
from docid import DocID
from content import Content
from tokenizer import Tokenizer


class Index:
  def __init__(self, ngram):
    self.tokenizer = Tokenizer("ma")
    self.docID = DocID()
    self.content = Content()
    self.ngram = ngram

  def tokenize(self, statement):
    return self.tokenizer.split(statement)

  def append_doc(self, token, id, pos):
    return self.docID.set(token, id, pos)

  def set_content(self, statement):
    return self.content.set(statement)

  def append(self, statement):
    tokenized_str = self.tokenize(statement)
    content_id = self.set_content(statement)

    token_index = 0

    for token in tokenized_str:
      self.append_doc(token, content_id, token_index)
      token_index += 1 

  def dump(self, dir):
    f_content_name = "content.pickle"
    f_docid_name = "docid.pickle"
    self.content.dump(f_content_name)
    self.docID.dump(f_docid_name)

  def load(self, dir):
    f_content_name = "content.pickle"
    f_docid_name = "docid.pickle"

    self.content.load(f_content_name)
    self.docID.dump(f_docid_name)

def main(filepath, column):
  indexer = Index(NGRAM)
  f = codecs.open(filepath, "r", "utf-8")
  lines = f.readlines()

  for line in lines:
    print line
    elems = line.split("\t")
    indexer.append(''.join(elems[column-1]))

  f.close()
  indexer.dump("data/")
  return

if __name__ == "__main__":
  if len(sys.argv) < 3:
    print "usage: ./indexer.py INPUT_TSV_FILE_PATH TARGET_COLUMN_NUM"
    sys.exit(1)
  filepath = sys.argv[1]
  column = int(sys.argv[2])
  main(filepath, column)
{%endcodeblock%}

Module này có nhiệm vụ là sử dụng Tokenizer để tách input document thành các term sử dụng ngram, tức là mỗi term sẽ có độ dài bằng độ dài ngram. Sau đó sẽ index term đó vào DocID, nếu term đó đã tồn tại thì id của document hiện tại sẽ được add vào docIDTable của docId thông qua hàm "set".

Kết quả index sẽ được lưu vào file docid.pickle (inverted index data) và content.pickle (content data).

##Searcher
Module này có nhiệm vụ load dữ liệu đã qua index từ 2 file docid.pickle và content.pickle vào memory, sau đó với mỗi query, Searcher sẽ phân tích query đó thành các term dựa vào tokenizer, tìm kiếm document chứa các term đó dựa vào dữ liệu từ docid, và present kết quả ra màn hình dựa vào dữ liệu lấy được từ content.pickle:

{%codeblock Searcher - Searcher.py %}
from docid import DocID
from content import Content
from tokenizer import Tokenizer
from collections import Counter
import collections

class Searcher:
  def __init__(self, ngram, dir):
    self.docID = DocID()
    self.tokenizer = Tokenizer()
    self.content = Content()
    self.docID.load(dir + "docid.pickle")
    self.content.load(dir + "content.pickle")
    self.result = dict()

  def search(self, statement, numOfResult):
    tokenized_list = self.tokenizer.split_query(statement)
    return self._search(tokenized_list, numOfResult)

  def _search(self, tokenList, numOfResult):
    token_search_index = 0 
    
    for token in tokenList:
      content_ids = self.docID.get(token)

      for content_id in content_ids:
        if not result[content_id]:
          self.result[content_id] = 0
        else:
          self.result[content_id] = result[content_id] + 1

  def print_result(self):
    sorted_result = sorted(self.result.items(), reverse=True)
    for item in sorted_result:
      print "{}\n".format(self.content.get(item))

{%endcodeblock%}

Chúng ta có thể thấy Searcher là một module rất đơn giản sử dụng tokenizer để bóc tách query. Sau khi bóc tách query thành các term, với mỗi term chúng ta sẽ tìm các document chứa term đó dựa vào docID. Mỗi term chúng ta sẽ thu được một chuỗi Ids chứa id của document chứa chúng. 

Để kết hợp các các chuỗi ids tìm được thành kết quả cuối cùng, chúng ta làm một mô hình ranking rất đơn giản, document nào chứa nhiều term hơn thì hiển thị trước. Logic này được thực hiện dựa vào tạo một dictionary chứa kết quả (self.result) , cứ mỗi khi tìm được document nào thì ta cộng kết quả thêm 1.

Kết quả cuối cùng sẽ được in ra màn hình thông qua hàm print_result. Như vậy chúng ta đã implement xong một search engine hết sức đơn giản.

#Conclusion
Thông qua chuỗi bài viết, chúng ta đã hiểu được phần nào việc tạo ra một search engine. Để có một search engine thành công, như google hay yahoo, không những performance phải được hoàn thiện ở mức tối đa với khối lượng dữ liệu rất lớn, thì việc có một mô hình ranking thích hợp cũng vô cùng quan trọng. Hy vọng chuỗi bài viết đã đem đến cho các bạn cái nhìn cơ bản nhất về search engine.
