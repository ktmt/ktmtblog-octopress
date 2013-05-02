---
layout: post
title: "error when install therubyracer"
date: 2013-05-03 06:43
comments: true
categories: 
  - tips
  - memo
---

Là ruby dev chắc bạn biết đến gem therubyracer (là gem dùng làm javascript interpreter trên ruby thông qua v8, gem này thường dùng làm javascript headless test hay để sử dụng một số module của nodejs trên ruby)
Tuy nhiên khi cài đặt gem này trên mac os (kể cả từ 10.6 đến 10.8) thì rất hay bị gặp lỗi:
{% codeblock error error.sh%}
$ gem install therubyracer
Building native extensions.  This could take a while...
ERROR:  Error installing therubyracer:
    ERROR: Failed to build gem native extension.

        /Users/david/.rvm/rubies/ruby-1.9.3-p194/bin/ruby extconf.rb
checking for main() in -lobjc... yes
*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of
necessary libraries and/or headers.  Check the mkmf.log file for more
details.  You may need configuration options.

Provided configuration options:
    --with-opt-dir
    --with-opt-include
    --without-opt-include=${opt-dir}/include
    --with-opt-lib
    --without-opt-lib=${opt-dir}/lib
    --with-make-prog
    --without-make-prog
    --srcdir=.
    --curdir
    --ruby=/Users/david/.rvm/rubies/ruby-1.9.3-p194/bin/ruby
    --with-objclib
    --without-objclib
extconf.rb:15:in `<main>': undefined method `include_path' for Libv8:Module (NoMethodError)
{% endcodeblock %}

Bị lỗi này hình như là do version của v8 đang cài trong máy bị conflict với version v8 therubyracer reference đến, để fix thì có 2 cách:
{% codeblock fix1 fix1.sh %}
$ gem uninstall libv8
$ gem install therubyracer
{% endcodeblock %}
Khi install therubyracer thì gem sẽ tự động install lại bản v8 thích hợp vào đúng chỗ.

Hoặc bạn có thể:
{% codeblock fix1 fix1.sh %}
$ gem update libv8
$ bundle install
{% endcodeblock %}


