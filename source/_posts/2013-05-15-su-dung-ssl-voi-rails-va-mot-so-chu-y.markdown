---
layout: post
title: "Sử dụng ssl trên rubyonrails"
date: 2013-05-15 23:03
comments: true
categories: 
  - rails
  - tips
  - ssl
  - tutorials
---

#HTTPS trên rails
Là RoR developer, khi phải làm việc với một số thông tin quan trọng như: thông tin cá nhân user, thông tin về thanh toán trực tuyến thì thường bạn phải dùng kết nối có bảo mật (secure connection), và điển hình ở đây là sử dụng HTTPS. Để setup HTTPS trên rails, thì trước hết mình phải nhắc lại là các web server phổ biến trên rails như là webrick, unicorn hay thin đều không hỗ trợ HTTPS từ đầu.  Để sử dụng SSL thì có 2 cách: 

1. Add thêm plugin: ví dụ như với webrick thì bạn sử dụng "webrick/https", nhưng cách này có một bất lợi là bạn phải setting từ đầu, và server đó sẽ luôn và chỉ phục vụ các request ssl:
{%codeblock webrickssl.rb %}
module Rails
  class Server < ::Rack::Server
    def default_options
      super.merge({
        :Port => 3000,
        :environment => (ENV['RAILS_ENV'] || "development").dup,
        :daemonize => false,
        :debugger => false,
        :pid => File.expand_path("tmp/pids/server.pid"),
        :config => File.expand_path("config.ru"),
        :SSLEnable => true,
        :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
        :SSLPrivateKey => OpenSSL::PKey::RSA.new(
        IO.read(File.expand_path("vendor/ssl/gs.key"))),
        :SSLCertificate => OpenSSL::X509::Certificate.new(
        IO.read(File.expand_path("vendor/ssl/gs.crt"))),
        :SSLCertName => [["CN", WEBrick::Utils::getservername]]
      })
    end
  end
end
{% endcodeblock %}
Để switch được giữa ssl và non-ssl thì thường bạn sẽ phải chạy song song 2 bản webrick, một bản hỗ trợ ssl và một bản không

2. Bạn sử dụng **Nginx** như một ssl proxy, sau khi xử lý ssl request thì Nginx sẽ forward lại request cho rails-server. Ở bài viết này mình sẽ nói về thiết lập môi trường ssl ở dưới môi trường development sử dụng **Pow** và **Nginx**

#Pow + Nginx
Tại sao lại sử dụng Pow? Pow là một rails-server rất hay được sử dụng trong công đoạn **development**. Lý do vì: dễ cài đặt, không phải config, và pow cho mỗi webapp của chúng ta một cái domain đẹp đẽ trên local. Để cài đặt pow thì vô cùng đơn giản:
{% codeblock install.sh %}
$curl get.pow.cx | sh
{% endcodeblock %}

Pow không đi kèm một bộ tool dòng lệnh tốt lắm (command line tool), tuy nhiên rất may đã có người làm hộ chúng ta 1 cái gem tên là **powder**, có nó thì chúng ta sẽ sử dụng pow dễ dàng hơn:
{% codeblock install.sh %}
$sudo gem install powder
{% endcodeblock %}

Sau khi install xong powder, chúng ta đi đến folder chứa rails app và chỉ cần [powder link appname] là đã xong phần cài đặt
{% codeblock install.sh %}
cd ~/yourapp
$powder link app-name
{% endcodeblock %}
Sau khi làm thao tác này thì một symlink với tên là app-name sẽ được tạo ra ở trong thư mục **~/.pow**
Kết thúc thao tác này, powder đã tự động được khởi động, và chúng ta chỉ cần truy cập vào url [app-name.dev] là đã sử dụng được như bình thường :)

OK vậy là xong pow, giờ đến lượt nginx, để cài đặt nginx thì khá đơn giản trên mac, mình sử dụng brew:
{% codeblock install.sh%}
brew install nginx
{% endcodeblock%}
Thường thì nginx sau khi được cài đặt xong sẽ nằm ở :[/usr/local/etc/nginx]

Bạn đang muốn sử dụng HTTPS, nên công đoạn tiếp theo sẽ là setup để nginx nhận request HTTPS và forward lại cho pow. Đầu tiên là phải generate ra một cặp **private key** và **certificate sign**, tại sao lại cần cặp này thì các bạn có thể tự tìm hiểu về giao thức HTTPS. 
{% codeblock install.sh%}
$openssl req -new -nodes -keyout server.key -out server.csr
$openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
{% endcodeblock%}

Sau khi có cặp key và sign, rồi bạn copy cặp đó vào thư mục [/usr/local/etc/nginx/ssl] cho dễ config. Tiếp đến bạn mở config của nginx ra và config lại như dưới đây
{% codeblock nginx %}
worker_processes  1;

events {
      worker_connections  1024;
}


http {
      include       mime.types;
      default_type  application/octet-stream;

      sendfile        on;
      keepalive_timeout  65;

      server {
        ### server port and name ###
        listen          443 ssl;
        server_name     app-name.dev;

        ### SSL log files ###
        access_log      logs/ssl-access.log;
        error_log       logs/ssl-error.log;

        ### SSL cert files ###
        ssl_certificate      ssl/app-name.crt;
        ssl_certificate_key  ssl/app-name.key;
        ### Add SSL specific settings here ###
        keepalive_timeout    60;
        ### We want full access to SSL via backend ###
        location / {
          proxy_pass  http://app-name.dev/;
          ### force timeouts if one of backend is died ##
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

          ### Set headers ####
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          ### Most PHP, Python, Rails, Java App can use this header ###
          proxy_set_header X-Forwarded-Proto https;
          ### By default we don't want to redirect it ####
          proxy_redirect     off;
        }
     }
}
{% endcodeblock %}

Công việc cuối cùng chỉ là chạy nginx, bạn khởi động nginx với option -t để test config file có đúng và không có warning nào không:
{% codeblock runnginx.sh %}
$ sudo nginx -t
nginx: the configuration file /usr/local/etc/nginx/nginx.conf syntax is ok
nginx: configuration file /usr/local/etc/nginx/nginx.conf test is successful
{% endcodeblock %}

Như vậy là mọi thứ đã OK, giờ chỉ việc dev thôi :D 

Để switch một cách đơn giản nhất giữa HTTPS và HTTP thì mình tạo 2 hàm sau trong application_controller:
{% codeblock switch.rb %}
def redirect_to_https
  if request.protocol == 'http://'
    redirect_to action: action_name,
      params: request.query_parameters,
      protocol: 'https://'
  end
end

def redirect_to_http
  if request.protocol == 'https://'
    redirect_to action: action_name,
      params: request.query_parameters,
      protocol: 'http://'
  end
end
{% endcodeblock %}
Và với nhứng method nào cần sử dụng https thì mình chỉ cần gọi đến hàm redirect_to_https là ok :D.

Các bạn có thể thấy bộ đôi pow và nginx rất dễ sử dụng đúng không.
Gần đây mình có gặp phải một problem với bộ đôi này là mình sử dụng oauth2 để login với google account. Và google api **không chấp nhận callback uri có domain có đuôi là .dev nhưng lại chấp nhận domain là localhost**. Khi cài đặt powder thì default cái 127.0.0.1 sẽ không được trỏ đến app-name.dev của bạn, để làm việc này thì bạn chỉ cần vào ~/.pow, tạo một symlink với tên là **default** trỏ đến rails app của bạn là OK :D.










