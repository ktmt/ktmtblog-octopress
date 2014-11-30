---
layout: post
title: "blogging with github and octopress"
date: 2013-04-30 23:20
comments: true
categories: 
  - tutorial
  - github
  - tips
---

### 1. Tạo blog trên github
Hẳn là một github user, hẳn bạn biết github hỗ trợ cho user tạo một static blog trên domain của github (xxx.github.io).
Để tạo blog cá nhân thì bạn có thể tham khảo chi tiết ở [đây](http://pages.github.com/). Hiện tại thì để tạo github page
thì đã có giao diện rất dễ sử dụng nên mình sẽ không nói thêm ở đây. Về mặt bản chất thì github page chỉ là một **repo** 
trên github, trong đấy có chứa các static file, và được trỏ đến domain xxx.github.io.

### 2. Jekyll và github page
Khi bạn push bất kì thứ gì lên repo của github page, github sẽ chạy site generator sử dụng jekyll. 
Tại sao phải sử dụng site generator? Vì github không chỉ hỗ trợ html mà còn hộ trợ markdown, một markup language khá đơn giản và dễ sử dụng (
bạn có thể tham khảo thêm ở [đây](http://en.wikipedia.org/wiki/Markdown). Vậy bạn có thể đoán ra jekyll là gì: jekyll là 
một sản phẩm của Tom Preston-Werner, ceo của github. Jekyll sẽ nhận input là một template directory, chạy qua một cái converter
engine để convert từ (Textile | Markdown | Liquid) sang html, tạo ra một static website.
Như vậy bạn đã có thể hình dung ra cách để tạo ra một github page:

{% img /images/OctopressGuide/octopress1.png %}

### 3. Sử dụng octopress để gen blog trên github page
Octopress là một framework design cho jekyll. Gọi là framework nghe hơi lớn, nhưng nói một cách ngắn gọn, octopress là một bộ template/tools/
plugin giúp cho việc generate static site đơn giản hơn. Những tính năng chính của octopress bao gồm:

*  Responsive design template (gồm css, js, html)
*  Build-in 3rd supports cho một số mạng xã hội (như like button của facebook, tweet button của twitter), và đặc biệt có comment của disqus khá tiện
*  Build-in web server để review sau khi generate qua jekyll
*  Hệ thống theming rất tốt với Compass và Sass

Nói lý thuyết nhiều quá, giờ vào cụ thể về cách cài đặt và sử dụng:

Prerequisite: máy bạn phải install git và ruby, cách install các bạn có thể google :D
Sau đấy bạn clone octopress về máy, install bundler rồi install các dependencies như sau:

{% codeblock install install.sh %}
git clone git://github.com/imathis/octopress.git octopress
cd octopress
gem install bundler 
bundle install
{% endcodeblock%}

Ok, như vậy bạn đã có một môi trường đẹp đẽ để chuẩn bị viết blog rồi. Về mặt trình tự thì để có 1 blog trên github page bạn sẽ phải:
Viết blog (dùng markdown/..) => generate qua jekyll => deploy lên github page

{% img /images/OctopressGuide/octopress2.png %}

Octopress đã chuẩn bị sẵn cho bạn một Rakefile (bạn có thể tìm hiểu về rake ở [đây](http://rake.rubyforge.org/doc/rakefile_rdoc.html)
.Trong đấy có rất nhiều task octopress đã chuẩn bị sẵn cho bạn để giúp cho việc cài theme, deploy lên github page trở nên đơn giản 
hơn bao giờ hết.

Đầu tiên bạn sử dụng  
{% codeblock theme theme.sh %}
rake install 
{% endcodeblock%}
để instal theme.

Sau khi đã install xong theme, chúng ta sẽ viết blog. Bước đầu tiên là setup repository để cho việc deploy lên github pages thuận tiện hơn:
{% codeblock theme theme.sh %}
rake setup_github_pages
{% endcodeblock%}

Khi làm bước này thì octopress sẽ prompt ra một cái để hỏi về repo của github pages của bạn (repo của cái xxx.github.io mà mình đã nói ở trên)

{% img /images/OctopressGuide/octopress3.png %}

Như hướng dẫn đã ghi, bạn sẽ phải điền repo của bạn với format git@github:your_username/your_username.github.com
Ví dụ như trong trường hợp blog ktmt thì sẽ là git@github:ktmt/ktmt.github.com.git
Bạn điền vào, press OK, như vậy là đã xong bước setup.
Sau bước này thì thì octopress sẽ tạo ra một cái git repo trong octopress/_deploy/.git/ link đến git@github:ktmt/ktmt.github.com.git.
Như vậy bạn có thể hình dung là sau này khi deploy thì octopress sẽ gen ra file vào trong _deploy và git push lên git@github:ktmt/ktmt.github.com.git
.  
Một chú ý nữa là sau bước này octopress sẽ:

-  Đổi tên remote branch hiện tại của bạn từ 'origin' sang 'octopress'
-  Add git@github:your_username/your_username.github.com vào remote branch và đổi thành 'origin'

{% img /images/OctopressGuide/octopress4.png %}

Note là octopress branch của mình đang không phải là git://github.com/imathis/octopress.git như các bạn mà đang là https://github.com/ktmt/ktmtblog-octopress.git. Thực ra cái ktmtblog-octopress chỉ là một bản được fork về của octopress, và được tạo nên để giữ các bài viết trên github của bọn mình thôi.

Vậy là setup xong, tiếp theo là việc quan trọng nhất, viết blog.
Để viết blog thì đầu tiên bạn sẽ phải generate ra file markdown thông qua
{% codeblock theme theme.sh %}
rake new_post["post_title"]
{% endcodeblock%}

Kết quả là một file markdown đã được tạo ra ở thư mục _source/_post

{% img /images/OctopressGuide/octopress5.png %}

Sau khi đã hoàn thành việc viết blog, việc tiếp theo bạn phải làm là generate cái file markdown đó + đống template thành static page thông qua jekyll. Octopress đã chuẩn bị sẵn cho bạn một rake task là generate, nên việc bạn phải làm chỉ là 
{% codeblock theme theme.sh %}
rake generate
{% endcodeblock%}

Kết quả là 

{% img /images/OctopressGuide/octopress6.png %}

Để preview thành quả của mình, octopress cung cấp cho bạn cả httpserver để preview, bạn gõ
{% codeblock theme theme.sh %}
rake preview
{% endcodeblock%}
Và truy cập vào localhost:4000 thông qua browser là đã có thể preview thành quả của mình rồi.

Cuối cùng, bạn sẽ deploy lên github page thông qua 
{% codeblock theme theme.sh %}
rake deploy 
{% endcodeblock%}

Và như thế là bạn đã deploy thành công blog của bạn lên github page (với điều kiện là bạn không viết sai syntax markdown :D).
Chú ý là khi bạn rake deploy thì octopress sẽ copy đè "toàn bộ" cái repo your_username/your_username.github.com của bạn thay bằng cái thư mục _deploy của nó, **kể cả commit tree**. Vậy nên để lưu giữ các bài viết của cá nhân thì các bạn nên làm như mình là: fork octopress về thành một repo cá nhân, và mỗi lần viết xong thì bạn push ngược lại vào **octopress repo** đó. Lưu ý là octopress repo nhé:
{% codeblock theme theme.sh %}
git push octopress master
{% endcodeblock%}

Cá nhân mình thì mình viết thêm 1 cái task vào Rakefile để cho đỡ bị nhầm lẫn repo:
{% codeblock rake Rakefile.rb %}
desc "push to octopress also"
task :push_octopress do
  puts "pushing to octopress repo"
  system "git checkout master"
  system "git pull octopress master"
  system "git add ."
  system "git commit -m ¥"Octopress push new post¥""
  system "git push octopress master"
end
{% endcodeblock%}

Và như vậy sau mỗi lần deploy bạn chỉ cần
{% codeblock theme theme.sh %}
rake push_octopress
{% endcodeblock%}
Là đã synchronize thành công.

### Kết luận:
Như vậy sau lần đầu setting có vẻ loằng ngoằng, từ bây giờ khi muốn viet blog bạn chỉ cần:

{% img /images/OctopressGuide/octopress7.png %}

Rất đơn giản đúng không :D. Happy blogging.
