---
layout: post
title: "Cài đặt memcached với sasl"
date: 2013-07-24 10:05
comments: true
categories: sysadmin
---

# Giới thiệu
Memcached là cơ sở dữ liệu được lưu trong memory. Thông thường chúng ta sử dụng memcached trong mạng nội bộ, hoặc sử dụng private IP để kết nối tới memcached, tuy nhiên trong một số trường hợp, IP của memcached server cần public ra ngoài (ví dụ toàn bộ các server đều đặt trên AWS). Trong trường hợp này, chúng ta cần bảo mật kết nối của memcached server.

Từ phiên bản 1.4.3, memcached đã support sử dụng [SASL](http://en.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer)

Bài viết này sẽ giới thiệu với các bạn cách cài đặt memcached với SASL cũng như giới thiệu cơ chế, cách làm việc của SASL

# Cách cài đặt SASL với memcached
Đầu tiên bạn cần cài đặt phiên bản mới nhất của memcached. Bạn sẽ cần một số gói và thư viện khác để support SASL.

{% codeblock install.sh %}
$> sudo apt-get install libsasl2-2 sasl2-bin libsasl2-2 libsasl2-dev libsasl2-modules
{% endcodeblock %}

Đừng quên, để cài đặt memcached, bạn cùng sẽ cần cài `libevent`

Cài đặt memcached

{% codeblock install.sh %}
$> wget http://memcached.googlecode.com/files/memcached-1.4.3.tar.gz
$> tar xvf memcached-1.4.3.tar.gz
$> cd memcached-1.4.3
$> ./configure --enable-sasl
$> sed -i 's/-Werror//g' Makefile
$> make
$> sudo make install
{% endcodeblock %}

Cài đặt libmemcached

{% codeblock install.sh %}
$> wget https://launchpad.net/libmemcached/1.0/1.0.17/+download/libmemcached-1.0.17.tar.gz
$> tar xvf libmemcached-1.0.17.tar.gz
$> cd libmemcached-1.0.17
$> ./configure
$> make
$> sudo make install
{% endcodeblock %}

# Set up SASL với memcached
Điều đầu tiên bạn cần đảm bảo đó là set biến môi trường `SASL_CONF_PATH` khi bạn chay memcached. Trong ví dụ này `SASL_CONF_PATH` sẽ được trỏ tới `/home/kiennt/sasl`

{% codeblock install.sh %}
$> export SASL_CONF_PATH=/home/kiennt/sasl
{% endcodeblock %}

Sau đó bạn cần set up file memcached.conf trong SASL (tên của file sẽ là tên của ứng dụng SASL - cụ thể ở đây là memcached)

{% codeblock  %}
mech_list: plain
log_level: 5
sasldb_path: /home/kiennt/sasl/sasldb2
{% endcodeblock %}

Tiếp theo, bạn cần tạo một file database (được trỏ tới từ bước trước) trong file `memcached.conf`

{% codeblock install.sh %}
$> sudo saslpasswd2 -c -a memcached -f /home/kiennt/sasl/sasldb2 <username>
{% endcodeblock %}

Chú ý rằng cờ -a xác định tên của ứng dụng `memcached` - chính là tên của config file bạn đã xác định ở trên `memcached.conf`. Khi bạn chạy `saslpasswd2`, bạn sẽ được hỏi password và password verify cation.

# Chạy memcached với SASL

Để chạy memcached với SASL, bạn cần sử dụng cờ `-S` để bật cơ chế security của mecached lên

{% codeblock install.sh %}
$> export SASL_CONF_PATH=/home/kiennt/sasl
$> /usr/local/bin/memcached -S -vvv
{% endcodeblock %}

# Tổng kết
Bài viết này giới thiệu với các cài đặt và chạy memcached với SASL. Giờ bạn có thể tập trung vào việc code ứng dụng của bạn rồi.
