---
layout: post
title: "Githook và server hook (tiếp)"
date: 2013-07-07 22:54
comments: true
categories: git
---

Ở bài viết [trước](/blog/2013/06/25/using-githook-to-automatically-test-your-app/), tôi đã giới thiệu về githook, client hook và các user case hay sử dụng với client hook. Bài viết này, tôi sẽ giới thiệu thêm về server hook và các ứng dụng của chúng trong thực tế

# Server-side hooks
Bên cạnh việc sử dụng các client-side hooks, bạn có thể sử dụng một vài server-side hook như là một hệ thống admin để áp đặt một cơ chế quán lý cho project của bạn. Những script này sẽ được chạy trước và sau khi commit được đẩy lên server. Những pre-hooks có thể trả về giá trị khác 0 ở bất cứ thời điểm nào để loại bỏ một push từ client, cũng như để in ra một error message cho client

## pre-receive và post-receive
Script đầu tiên được chạy khi server nhận được một push từ client đó là `pre-receive`. Script này nhận một list các tham chiếu sẽ được push từ stdin. Nếu nó trả về giá trị khác 0, không có tham chiếu nào được chấp nhận. Bạn có thể sử dụng hook này để làm những việc như đảm bảo không có bất cứ tham chiếu nào là `non-fast-forwards`.

`post-receive` hook chạy sau khi toàn bộ quá trình được hoàn tất và có thể sử dụng để update các service khác hoặc để notify uer. Nó nhận cùng dữ liệu từ stdin như `pre-receive` hook. Ví dụ bao gồm gửi email chó một list các developer liên quan, notify CI server, hoặc update ticket tracking system. Bạn thậm chí có thể parse commit message để kiểm tra xem có bất cứ ticket nào cần open, modified hoặc update hay không. `post-receive` không thể làm ngừng lại quá trình push, nhưng client sẽ không đóng kết nối tới server cho đên khi `post-receive` kết thúc. Ví thế hãy cẩn thận khi bạn muốn làm những việc tốn thời gian. Cách tốt nhất là hãy sử dụng các background process để xử lý các tác vụ tốn thời gian.

## update
Update script là tương tự với `pre-receive` script, ngoại trừ việc nó chỉ chạy một làn cho mỗi branch mà pusher muốn update. Nếu pusher muốn update nhiều branch, `pre-receive` chỉ chạy duy nhất một lần, nhưng update sẽ chạy một lần cho mỗi branch mà chúng được push. Thay vì đọc dữ liệu từ stdin, script này sẽ nhận 3 tham số đầu vào: tên của branch, SHA-1 trỏ đến commit trước khi được push, và SHA-1 user đang muốn push. Nếu update script trả về kết quả khác 0, chỉ branch ứng với script này bị reject, các branch khác vẫn được update bình thường

# Ví dụ
Trong ví dụ này, chúng ta sẽ bắt buộc mỗi commit message phải có phần mở đầu của message tuân theo một định dạng. Cụ thể mỗi mesage phải có dạng "ref:1234" bởi vì mỗi một commit sẽ ứng với một ticket trong hệ thống.

Để làm việc này, sẻver sẽ phải kiểm tra tất cả các commit được push để xem string trong commit message có đúng format hay không. Nếu commit message là không đúng format, trả về giá trị khác 0 và reject push.

Chúng ta sẽ viết một update hook để làm việc này. Chú ý rắng, update hook nhận 3 giá trị đầu vào: tên của branch được update, SHA-1 của commit trước khi được push, và SHA-1 của commit sau khi được push. Các đoạn code dưới đây được minh hoạ bằng ruby, bạn có thể sử dụng ngôn ngữ lập trình khác nếu muốn


{% codeblock lang:ruby update %}
#!/usr/bin/env ruby

$refname = ARGV[0]
$oldrev  = ARGV[1]
$newrev  = ARGV[2]

{% endcodeblock %}

Để lấy các commit từ `$oldrev` tới `$newrev`, chúng ta sử dụng lệnh `git rev-lít`. Lệnh này sẽ trả về danh sách các SHA-1 cho các commit nằm giữa 2 commit mà chúng ta truyền vào

{% codeblock lang:bash %}
$ git rev-list 538c33..d14fc7
d14fc7c847ab946ec39590d87783c69b031bdfb7
9f585da4401b0a3999e84113824d15245c13f0be
234071a1be950e2a8d078e6141f5cd20c1e61ad3
dfa04c9ef3d5197182f13fb5b9b1fb7717d2222a
17716ec0f1ff5c77eff40b7fe912f9f6cfd0e475
{% endcodeblock %}

Sau đó, chúng ta sử dụng lệnh `git cat-file` đẻ duyệt qua từng commit và lấy nội dụng của commit message.

{% codeblock lang:bash %}
$ git cat-file commit ca82a6
tree cfda3bf379e4f8dba8717dee55aab78aef7f4daf
parent 085bb3bcb608e1e8451d4b2432f8ecbe6306e7e7
author kiennt <kiennt@gmail.com> 1205815931 -0700
committer kiennt <schacon@gmail.com> 1240030591 -0700

Add new post about githook
{% endcodeblock %}

Cách đơn giản để lấy commit message từ một commit là khi có SHA-1 , chúng ta xác định dòng blank đầu tiên và lấy tất cả phần đằng sau nó. Chúng ta có thể sử dụng `sed` để làm điều này

{% codeblock lang:bash %}
$ git cat-file commit ca82a6 | sed '1,/^$/d'
Add new post about githook
{% endcodeblock %}

Sau đây là toàn bộ đoạn code ruby để hoàn thành tác vụ trên

{% codeblock lang:ruby update %}
#!/usr/bin/env ruby

$refname = ARGV[0]
$oldrev  = ARGV[1]
$newrev  = ARGV[2]
$regex = /\[ref: (\d+)\]/

# enforced custom commit message format
def check_message_format
  missed_revs = `git rev-list #{$oldrev}..#{$newrev}`.split("\n")
  missed_revs.each do |rev|
    message = `git cat-file commit #{rev} | sed '1,/^$/d'`
    if !$regex.match(message)
      puts "[POLICY] Your message is not formatted correctly"
      exit 1
    end
  end
end
check_message_format
{% endcodeblock %}


# Kết luận

Qua 2 bài viết về githook, bạn đã nắm được phần nào các hooks trong git, và các ứng dụng liên quan đến chúng. Giờ bạn có thể sử dụng githook để tạo nên workflow phù hợp nhất với git cho project của mình

# Tham khảo
[Githook documentation](http://git-scm.com/book/en/Customizing-Git-Git-Hooks)
[Customizing Git](http://git-scm.com/book/en/Customizing-Git-An-Example-Git-Enforced-Policy)
