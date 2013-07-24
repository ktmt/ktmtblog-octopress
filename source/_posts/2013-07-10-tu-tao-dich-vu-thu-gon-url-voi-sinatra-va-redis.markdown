---
layout: post
title: "tự tạo dịch vụ thu gọn url với sinatra và redis"
date: 2013-07-10 15:24
comments: true
categories: 
  - redis
  - sinatra
  - tutorial
---

## Mở đầu ##
Chắc hẳn các bạn đã biết về các dịch vụ rút gọn url, điển hình là bit.ly. Mục đích của dịch vụ này là nhằm thu gọn là những url rất dài để tiết kiệm chữ (cho những dịch vụ giới hạn về số kí tự như twitter chẳng hạn) và để cho url nhìn gọn hơn.
Cơ chế của một dịch vụ rút gọn url khá đơn giản, vậy tại sao không tự làm một dịch vụ cho chính mình. Bài này mình sẽ hướng dẫn cách làm một url shorten service đơn giản dựa trên sinatra và redis.

## Cài đặt ##
Để cài đặt sinatra thì bạn phải có ruby đã cài sẵn trên máy, việc cài đặt sinatra khá đơn giản thông qua **gem**:
{% codeblock sinatra_install.sh %}
  gem install sinatra
{% endcodeblock %}

Tiếp đến là redis, để cài đặt redis thì tùy thuộc vào hệ điều hành, trên mac-osx các bạn có thể cài đặt rất dễ dàng thông qua **brew**:
{% codeblock redis_install.sh %}
  brew install redis
{% endcodeblock %}
Trên linux hoặc windows các bạn có thể google để tìm ra hướng dẫn  cài tương ứng. 
Các bạn khởi động redis thông qua, khi khởi động redis mà không set option với config gì cả thì redis sẽ chạy trên localhost và port là 6789:
{% codeblock redis_install.sh %}
  redis-server
{% endcodeblock %}

## Giới thiệu qua về sinatra và redis ##
Sinatra là một mini webframework based trên Rack(Rack là web server interface rút gọn nhất có thể rất nổi tiếng trên ruby). Sinatra cung cấp cho bạn một DSL(Domain specific language) để có thể build một web app một cách dễ dàng nhất. Các bạn có thể tìm hiểu về sinatra ở [trang chủ của sinatra](http://www.sinatrarb.com/intro.html).

Redis là hệ thống lưu trữ key-value với rất nhiều tính năng và được sử dụng rộng rãi. KTMT blog đã có [một bài viết về redis](http://ktmt.github.io/blog/2013/07/02/tim-hieu-redis/) cách đây không lâu, các bạn có thể tham khảo lại. Về cách sử dụng redis, các bạn có thể tham khảo tại [trang chủ redis](http://redis.io/documentation)

## Thiết kế chương trình ##
Cơ chế của một dịch vụ thu gọn hết sức đơn giản, được thể hiện ở diagram dưới đây:

{% img /images/urlshorten/url-shorten-flow.png %}

Chắc bạn nào đã dùng bit.ly sẽ tưởng tượng ra usage flow một dịch vụ rút gọn url nên có. Cơ chế chúng ta dùng ở bài viết này như sau: đầu tiên user sẽ gửi url cần rút gọn thông qua form input. Web server nhận được request này sẽ hash url lại thành một chuỗi ngắn hơn, thông thường từ 5~10 kí tự, webserver sẽ lưu lại cặp <hash, origin url> vào redis, và trả lại chuỗi hash đó được ghép vào url của dịch vụ : http://your-service.com/hash.

Khi user click vào http://your-service.com/hash, đầu tiên server sẽ dùng chuỗi hash tìm original url trên redis, sau đó sẽ trả về response 301 (redirect) với location mới là original url, nhờ vậy mà user sẽ được redirect đến original url.

Như vậy là đã định hình ý tưởng nên làm gì, chúng ta sẽ bắt tay vào code

## Coding ##
1. Tạo khung
Đầu tiên là sườn của một Sinatra app, có get, post. Chúng ta tạo folder cho app của chúng ta và tạo 1 file là app.rb chính là sinatra app:
{% codeblock make.sh %}
mkdir url_shorten && cd url_shorten
touch app.rb && vim app.rb
{% endcodeblock %}

Sau đó chúng ta sẽ tạo cái khung cho sinatra app như dưới đây:
{% codeblock url_shorten.rb %}
require 'sinatra/base'
require 'redis'

class UrlShort < Sinatra::Base
  set :public_dir, File.dirname(__FILE__) + '/static'

  get '/' do
    erb :index
  end
end

UrlShort.run!
{% endcodeblock %}

Sinatra có syntax dạng DSL: get 'some info' do 'something' để represent cho 'get' request rất dễ hiểu. Đoạn code trên có nghĩa là khi request đến '/' (root) thì sẽ render file index nằm trong views.
Như vậy chúng ta đã có cái khung đơn giản nhất của một web service, nhận request, trả về view. (erb là template engine có sẵn của ruby, nó sẽ render file có đuôi erb ra html)

Tiếp đến chúng ta sẽ thực hiện xử lý hash url. Về mặt lý thuyết thì gọi là hash không đúng lắm vì hash phải là nhận đầu vào X và trả lại Y là kết quả của việc hash X, bài toán của chúng ta ở đây chỉ đơn thuần là generate ra một chuỗi random để represent cho một cái url, như vậy bài toán của chúng ta sẽ là một hàm random_hash(N) nhận đầu vào N là độ dài của chuỗi input và đầu ra là một chuỗi random (cả chữ cả số) có độ dài N, ví dụ như sau:
{% codeblock hash.rb %}
  rand_hash(5) #=> "s4xA6"
{% endcodeblock %}
Để giải quyết bài toán này thì có khá nhiều hướng đi:

1. Loop từ 1 đến 5 rồi với mỗi lần loop bạn random ra một số hoặc chữ cái.
2. Tạo ra 1 array có độ dài 64 gồm từ [0..9] [a..z] và [A..Z] và random ra 5 vị trí trong đó (việc này có thể thực hiện rất dễ dàng thông qua Array#sample của ruby).
3. Sử dụng base64. base64 có một đặc điểm là sẽ biến 1 số M thành 1 chuỗi cả chữ cả số có độ dài max là log(64)(M). Do đó để tạo ra một chuỗi random có length N thì chúng ta chỉ cần random một số M nằm trong khoảng 64^(N-1) đến 64^(N) và chuyển nó về base 64.
4. Sử dụng một số kĩ thuật generate 64bit (mà đã được giới thiệu ở [bài viết về generate 64bit uid](http://ktmt.github.io/blog/2013/06/09/xay-dung-he-thong-sinh-64bit-unique-id/) trên KTMT gần đây.

Ở bài viết này chúng ta sẽ sử dụng kĩ thuật số (3). Chúng ta đưa hàm generate hash vào trong helper của sinatra thông qua hàm helpers như sau:
{% codeblock hash.rb %}
class UrlShort < Sinatra::Base
  ..
  helpers do
    def rand_hash(length)
      gap = 64**(length) - 64**(length-1)
      (rand(gap) + 64**(length-1)).to_s(64) 
    end
  end 
  ...
{% endcodeblock %}

Tiếp theo chúng ta sẽ làm nhiệm vụ gắn hash thu được với url thành một cặp key-value và ghi vào redis. Để làm nhiệm vụ này thì đầu tiên chúng ta cần khởi tạo redis, mình khởi tạo redis bằng cách overwrite constructor của app và đưa redis instance vào thành 1 instance property. Ngoài ra, chúng ta cũng không muốn 1 url mà mỗi lần request lại tạo một hash khác nhau , rất tốn tài nguyên, do đó mỗi lần gen hash mình sẽ lưu duplicate thành 2 cặp key-value. Một cặp chứa url làm key và hash làm value, và một cặp chứ hash làm key và url là value, điều này đảm bảo mối liên hệ giữa url/hash là 1/1.

{% codeblock implement.rb %}
post '/' do 
  @error = nil
  @error = 'please enter url' if URI.regexp.match(params[:url]).nil?
  @success = false
  
  unless @error
    if params[:url] and not params[:url].empty?
      @url = params[:url]
      @hash = rand_hash(5)
      exist = @redis.setnx "url:#{@url}", @hash
      if exist #key not set
        @redis.setnx "hash:#{@hash}", @url
      else
        @hash = @redis.get "url:#{@url}"
      end
      @success = true
    end
  end

  erb :index
end
{% endcodeblock %}

Như vậy chúng ta đã có @hash để trả về cho user, chúng ta sẽ ghep hash vào trong views để hiển thị cho user (views/index.rb)
{% codeblock index.erb %}
<form id="form" method="post">
  <input type="text" value="" name="url" id="url"/>
  <input type="submit" value="shorten" id="submit" class="submit"/>
</form>
<hr/>
<div class="mes">Result</div>
<% if @error %>
  <div id='error'>
    <%= @error %>
  </div>
<% else %>
  <% if @success %>
    <a id="result" href='<%= "#{escape_html(url)}#{@hash}" %>'><%= "#{escape_html(url)}#{@hash}" %></a>
    <input data-clipboard-text='<%="#{escape_html(url)}#{@hash}" %>' type="button" id="yank" class="submit" value="yank"/>
  <% end %>  
<% end %>
{% endcodeblock %}

Phần việc còn lại chúng ta phải giải quyết là khi user click vào link. Link của chúng ta có dạng là www.my-application.com/#{hash}, với sinatra để lọc phần hash hết sức đon giản vì sinatra đã tự động lọc hộ chúng ta và đưa vào biến global params, do đó chúng ta chỉ cần lấy hash từ params, tìm trong redis, và redirect user là ok:

{% codeblock redirect.rb %}
  get '/:hash' do
    url = @redis.get "hash:#{params[:hash]}" 
    redirect url
  end
{% endcodeblock %}

Như vậy chúng ta đã có một flow hoàn chỉnh rồi, thêm tí css và sử dụng [ZeroClipboard](https://github.com/zeroclipboard/ZeroClipboard) để có nút yank để copy url vào clipboard, chúng ta đã có một dịch vụ rút gọn url cho riêng mình!

{% img /images/urlshorten/background.png %}

Toàn bộ source code cho tutorial này mình đang để ở đây, mọi người có thể sử dụng tùy ý :). 
[https://github.com/ktmt/link_shorttener](https://github.com/ktmt/link_shorttener)
 

