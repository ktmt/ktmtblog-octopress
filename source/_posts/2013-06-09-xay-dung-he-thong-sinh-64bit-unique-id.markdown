---
layout: post
title: "Giới thiệu một số phương pháp sinh 64 bit unique ID"
date: 2013-06-09 21:15
comments: true
categories: python, programming
---

# Bài toán sinh unique ID
Unique ID được sử dụng để phân biệt các đối tượng khác nhau.
Ví dụ primary key là một unique key đặc biệt dùng để phân biệt các row trong table.

Bài viết giới thiệu một số phương pháp sinh 64 bit unique ID.

# Một số giải pháp sinh unique ID

 + Nếu số lượng dữ liệu nhỏ, ta có thể sử dụng ID kiểu Integer và set cho nó thuộc tính auto increment.

 Ưu điểm: đơn giản, dễ làm.

 Nhược điểm: số lượng ID bị giới hạn (2 ^ 32 = 4294967296) và đặc biệt cách làm này không scale. Để đảm bảo tính duy nhất, tại một thời điểm, chỉ có thể sinh ra đúng một ID mà thôi.

 + Sử dụng [UUID](http://en.wikipedia.org/wiki/Uuid) - UUID là một giá trị 128bit, tuỳ vào thuật toán xây dựng UUID, có thể dựa trên Mac Address của máy.

 Ưu điểm: scalable, distributed. Tại một thời điểm có thể sinh ra nhiều ID khác nhau, thậm chí client cũng có thể sinh ID mà vẫn đảm bảo không bị trùng lặp với server

 Nhược điểm: sử dụng 128 bit, một số hệ thống phải lưu trữ dưới dạng char, tốn tài nguyên và index

 64 bit unique ID trùng hoà giữa 2 cách trên, đảm bảo số lượng ID sinh ra là đủ lớn, đồng thời có thể lưu trữ dưới dạng dạng Big Int

# Một số phương pháp sinh 64 bit unique ID

1. Twitter [snowflake](https://github.com/twitter/snowflake/)
 Snowflake là thrift service sử dụng Apache ZooKeeper để liên kết các node và sinh ra 64bit unique ID.
 Mỗi node là một worker, các worker được đánh số khác nhau

 ID được sinh ra theo công thức

   * time - 42bit (được tính bằng epoch)
   * worker id - 10 bit (số worker có thể lên đến 1024)
   * sequence number - 12 bit (number được tăng liên tiếp, đảm bảo tại một thời điểm, mỗi worker có thể sinh được 4096 ID)

 Ở phần tiếp theo, chúng ta sẽ implement thuật một service sử dụng thuật toán trên để sinh ID

2. [Instagram 64bt ID](http://instagram-engineering.tumblr.com/post/10853187575/sharding-ids-at-instagram)

 Instagram sinh ID dựa vào posgresql schema. Thuật toán sinh ID tương tự như snowflake, mỗi ID 64 bit bao gồm

   * time - 41 bit (time epoch)
   * shard_id - 13 bit (so shard id lên tới 8192)
   * sequence number - 10 bit

# Implement thuật toán sinh 64 bit uniqueID của snowflake bằng python

{% codeblock flake.py %}

import simplejson
import sys
import tornado.httpserver
import tornado.ioloop
import tornado.options
import tornado.web

from time import time
from tornado.options import define, options

define("port", default=8888, help="run on the given port", type=int)
define("worker_id", help="globally unique worker_id between 0 and 1023", type=int)


class IDHandler(tornado.web.RequestHandler):
    max_time = int(time() * 1000)
    sequence = 0
    worker_id = False
    epoch = 137079712900000 # 2013-06-09

    def get(self):
        curr_time = int(time() * 1000)

        if curr_time < IDHandler.max_time:
            # stop handling requests til we've caught back up
            raise tornado.web.HTTPError(500, 'Clock went backwards! %d < %d' % (curr_time, IDHandler.max_time))

        if curr_time > IDHandler.max_time:
            IDHandler.sequence = 0
            IDHandler.max_time = curr_time

        IDHandler.sequence += 1
        if IDHandler.sequence > 4095:
            # Sequence overflow, bail out
            raise tornado.web.HTTPError(500, 'Sequence Overflow: %d' % IDHandler.sequence)

        generated_id = ((curr_time - IDHandler.epoch) << 22) + (IDHandler.worker_id << 12) + IDHandler.sequence

        self.set_header("Content-Type", "text/plain")
        self.write(str(generated_id))
        self.flush() # avoid ETag, etc generation


def main():
    tornado.options.parse_command_line()

    if 'worker_id' not in options:
        print 'missing --worker_id argument, see %s --help' % sys.argv[0]
        sys.exit()

    if not 0 <= options.worker_id < 1024:
        print 'invalid worker id, must be between 0 and 1023'
        sys.exit()

    IDHandler.worker_id = options.worker_id

    application = tornado.web.Application([
        (r"/", IDHandler),
    ], static_path="./static")
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()


if __name__ == "__main__":
    main()

{% endcodeblock %}

Đoạn code trên được trích từ repository [flake](https://github.com/formspring/flake/blob/master/flake.py)
Sử dụng [tornado](http://www.tornadoweb.org/en/stable/) - Python web framework and asynchronous networking library, ở một thời điểm (độ chính xác tới millisecond), một node có thể handle được nhiều request, mỗi một request sẽ được trả về một số là ID được sinh ra. Số lượng ID được sinh ra bởi một node, tại một thời điểm bị giới hạn bởi 4096, nếu lớn hơn, request sẽ bị báo lỗi

# Kết luận

Bài viết trình bày một số phương pháp sinh ID 64 bit, kèm code minh hoạ. Tuỳ vào hệ thống của bạn, bạn có thể sử dụng ID 64 bit cho những mục đích khác nhau. Ví dụ như đánh số tất cả các đối tượng trong database (giống như FB làm với graph API), hoặc sử dụng 64 bit ID như một bước đệm và áp dụng thêm một bước mã hoá để sinh ID cho một loại đối tượng (giống như youtube đánh số các video).
