---
layout: post
title: "Giới thiệu về Unix process"
date: 2013-04-01 00:39
comments: true
categories:
- unix
---

Là một kỹ sư lập trình hệ thống, một server guy, hay là một sys admin, sys dev,
sys ops,... phần lớn thời gian bạn sẽ phải làm việc trên hệ thống Unix.
Để làm việc trên Unix, chúng ta tương tác với hệ điều hành thông qua các
lệnh (command). Mỗi lệnh trên Unix khi thực thi sẽ run một process hoặc một
group các processes.

Trong bài viết này mình giới thiệu các kiến thức và kỹ thuật cơ bản để làm việc
với Process trên Unix. Bài viết sẽ trình bày với code minh hoạ bằng Ruby (rồi
bạn sẽ thấy Ruby rất đơn giản). Tất cả các code mình hoạ được chạy trên
môi trường Unix (Linux của chính là Unix - nếu bạn chưa biết, vì thế đừng ngần
ngại thử nó trên máy bạn).

Dù mình đã rất cố gắng, nhưng có thể vẫn có sai sót, mình rất cám ơn các ý kiến
đóng góp

## I. Một số kiến thức tổng quan
Tất cả các chương trình trong Unix thực chất đều là các processes. terminal bạn
chạy, apache, nginx, vim, hay bất cứ lệnh nào bạn gõ vào terminal. Process chính
là đơn vị cấu thành nên Unix. Nó chính là một instance của chương trình bạn viết
ra. Nói cách khác mỗi dòng code của bạn, sẽ được thực thi trên một process.

Unix cung cấp tool `ps` để list ra tất cả các process đang chạy trên hệ thống

{% highlight bash %}
$> ps -e -opid,ppid,user,rss,command
PID   PPID  USER     RSS      COMMAND
1     0     root     152      init [2]
1695  1     root     428      /usr/sbin/sshd
1863  1     root     48       /sbin/getty 38400 tty1
1864  1     root     48       /sbin/getty 38400 tty2
1865  1     root     48       /sbin/getty 38400 tty3
1866  1     root     48       /sbin/getty 38400 tty4
1867  1     root     48       /sbin/getty 38400 tty5
1868  1     root     48       /sbin/getty 38400 tty6
24477 1695  root     2888     sshd: vagrant [priv]
24479 24477 vagrant  1996     sshd: vagrant@pts/0
24480 24479 vagrant  2328     -bash
24591 24480 vagrant  1060     ps -e -opid,ppid,user,rss,command
{% endhighlight %}


Ở đây, mình chạy lênh `ps` và show ra các thuộc tính `pid,ppid,user,rss,command`
của process (chú ý (1) `ps` có rất nhiều option để chạy, nếu bạn muốn hiểu chỉ
tiết, hãy sử dụng `man ps` để biết, (2) kểt quả trả về chỉ là một phần các
process trên máy mình). Các thông tin mình muốn hiện thị ở đây bao gồm:

1. PID - Process ID (id của process),
2. PPID - Parent Process ID (id process cha của process đó),
3. USER (tên user trên Unix start process),
4. RSS (Resident Set Size) có thể coi bộ nhớ mà process sử dụng,
5. COMMAND - command mà user sử dụng để chạy processs

Chú ý rằng dòng cuối trong kết quả trả về show ra COMMAND là
`ps -e -opid,ppid,user,rss,command` - chính là lệnh mà chúng ta dùng để chạy.
Điều đó chứng tỏ, mỗi một command chính là một process !?

Ngoài ra lệnh ps cũng cho chúng ta thấy, mỗi một Process sẽ có một Process ID,
và thuộc về một Process cha nào đó. Process ID là duy nhất đối với mỗi một
process, tức là 2 process khác nhau chắc chắn phải có PID khác nhau. Ngoài ra
Process ID là không thể thay đổi trong khi chạy process.

###1. Làm sao hệ điều hành đánh số các Process ID?

Process ID được đánh số theo thứ tự tăng dần. Bắt đầu từ 0 và tăng lên cho tới
khi gặp giá trị maximum. Giá trị maximum của Process ID là có thể cấu hình được
tuỳ vào từng hệ thống.

Trên Linux bạn có thể xem và thay đổi giá trị mặc định của Process ID maximum
bằng cách thay đổi file `/proc/sys/kernel/pid_max`

{% highlight bash %}
# read current maximum value of process id
$> cat /proc/sys/kernel/pid_max
32768

# set maximum value for process id
$> echo 40000 > /proc/sys/kernel/pid_max
{% endhighlight %}

Khi process ID tăng đến giá trị maximum value, hệ điều hành (OS) sẽ quay trở lại
đánh số từ một giá trị cụ thế (một số tài liệu nói giá trị này với Linux là 300,
và với Mac OS là 100 - mình chưa biết cách để kiểm nghiệm điều này một cách an
toàn)

UNIX cung cấp syscall `getpid` trả về Process ID của process hiện tại. Bạn có thể
viết một chương trình C đơn gian để lấy ra process id với `getpid`. Tuy nhiên,
bài viết này của tôi sẽ tập trung vào ngôn ngữ Ruby

Trong Ruby, muốn lấy Process ID của process hiện tai, bạn sử dụng `Process.pid`.

{% highlight ruby %}
# file test_pid.rb
puts "Process pid: #{Process.pid}"
{% endhighlight %}

Dòng code trên gọi tới hàm `puts` - hàm này có tác dụng in một String ra màn hình.
Chúng ta có thể manipulate các String trong Ruby thông qua các syntax #{}. Code
ruby trong #{ } sẽ được thực hiện trước khi truyền cho String

{% highlight ruby %}
$> irb

irb(main):001:0> puts "Example for String manipulate: 1 + 2 = #{1 + 2}"
Example for String manipulate: 1 + 2 = 3
=> nil

{% endhighlight %}

(Các file Ruby có extension là .rb. Để chạy một file ruby, bạn dùng lệnh
 `ruby <file_name>`. Không cần phải compile, rất đơn giản phải không)

###2. Liệu có phải process nào cũng có Process cha?

Ở  trên tôi đã nói rằng, mỗi một process đều thuộc về một Process cha nào đó.
Nếu bạn suy nghĩ kỹ, bạn sẽ thấy có điều gì đó không ổn? À, thực ra điều này
liên quan đến quá trình khởi động của UNIX. Khi UNIX được khởi động, nó sẽ start
một process số 0 (với PID = 0) (process này là process của Kernel UNIX). Process
0 sẽ tạo ra cho nó một Process con, Process 1. Trong phần lớn hệ thống, Process 1
được đặt tên là init process, các process khác được tạo ra đều từ init process.

Hãy quay lại ví dụ về lệnh `ps` như ở phần đầu mục I. Bạn có thể để ý thấy PPID
của dòng đầu tiên là 0. Đó chính là process đầu tiên của OS.

Vậy là process trong Unix thực chất được tổ chức dưới dạng cây. Mỗi một node
trong cây đại diện cho một process trong Unix. Gốc chính là process 0, các con
của một node chính là các process con của process ứng với node đó.

Trong Ruby, để lấy ra parent process id của một process, chúng ta sử dung `Process.ppid`

{% highlight ruby %}
# file test_ppid.rb
puts "Process id #{Process.pid}, parent process id #{Process.ppid}"
{% endhighlight %}

Cũng rõ ràng đấy chứ. Liệu tôi có quên gì nữa không nhỉ?

Vấn đề là làm sao một process  có thể sinh ra một process con? À đừng lo, tôi
sẽ nói kỹ về điều này ở phần 2

###3. Process Resource

Ngoài ra lệnh `ps` của chúng ta còn cho thấy, mỗi Process đều có RSS khác nhau.
RSS chính là bộ nhớ mà Process sử dụng. Các process khác nhau, có bộ nhớ khác nhau.
Nói cách khác, không gian địa chỉ của các Process là riêng biệt. Nhớ thiết kế này
mà các Process là độc lập với nhau. Nếu một Process bị chết, thì nó cũng không
ảnh hưởng gì tới các Process khác.

Ngoài bộ nhớ, hệ điều hành còn cấp phát cho Process các tài nguyên khác đó là các
file descriptor. Nhớ rằng trên UNIX, mọi thứ đều là file. Điều đó có nghĩa là,
devide được coi như file, socket được coi như file, pipe cũng là file, và file
cũng là file!!! Để cho đơn giản, chúng ta sẽ dùng Resource thay cho khái niệm
file nói chung, và file đại diện cho khái niệm file thông thường.

Bất cứ khi nào bạn mở một Resource trong một process, resource đó sẽ được gán với
một số file descriptor. File descriptor là không được chia sẽ giữa các process
không liên quan. Các resource sẽ sống và tồn tại cùng  với process mà nó thuộc về.
Khi process chết đi, các resource gắn với nó sẽ được close và exit.

Mỗi một process sẽ có 3 files descriptor mặc định, bạn hẳn rất quen thuộc với
chúng, đó chính là stdin, stdout và stderr. Các file descriptor được đánh số tăng
dần từ 0 đến giá trị lớn nhất. Mỗi một process sẽ có một số giới hạn các file
descriptor nó được quyền sử dụng.


##II. forking

Ở phần I.2, chúng ta đã nói về  process cha và process con, và đưa ra câu hỏi,
làm sao một process có thể sinh ra các process khác.

UNIX cung cấp một công cụ tuyệt vời để làm điều đó.
Bạn chắc đã đoán ra, đó chính là `fork`.
Theo cá nhân tôi, `fork` có lẽ là một trong những chức năng tốt nhất của UNIX.
Vì sao ư? Vì process con được tạo ra với fork có 2 đặc điểm:

+ process con được copy tất cả các memory từ process cha.
+ process con sẽ được kế thứa từ process cha các resource

Điều này có nghĩa là nếu trong process cha, bạn đã định nghĩa biến a, và gán
giá trị cho nó, process con cũng có thể sử dụng biến đó.

Uhm... Không phải như thế sẽ dẫn đến tình trạng 2 process cùng thay đổi một biến
hay sao, vả lại chẳng phải các process là độc lập về bộ nhớ.

À, tức là thế này, khi fork một process mới, bộ nhớ của process con và process
cha vẫn là độc lập, nhưng hệ điều hành sẽ sử dụng cơ chế copy-on-wright (COW) để
thực hiện việc đó. Tức là nếu process con không thay đổi các giá trị trong
process cha, process con và process cha sẽ vẫn dùng chung bộ nhớ. Điều này làm
cho các process con chỉ đọc, sẽ có memory rất nhỏ. Hay nói cách khác, UNIX cung
cấp cho chúng ta một công cụ để chạy các multiprogram với một lượng resource vửa đủ.

Điều này đặc biết tốt khi bạn cần load các library. Process cha sẽ đảm nhiệm việc
load các library khác nhau. Sau khi load xong, nó fork ra các process con, và thực
hiện việc điều khiển các process con. Các process con nhờ cơ chế COW, không cần
phải tốn thời gian load library nữa mà vẫn có thể truy xuất vào các library

Ngoài ra các process cha chia sẻ với process con các resource cũng dẫn đến một
kỹ thuật khá thú vị: pre-forking - đặc biệt hiệu quả trong việc lập trình server.

Kỹ thuật này được mô tả như sau:

+ Main process khởi tạo một listening socket
+ Main process fork ra một list các children process. Chú ý các children process
này cũng sẽ listen trên socket mà main process tạo ra. Nhưng việc dispatch các
incomming connection tới các children process là được thực hiện trên kernel.
Điều này làm cho việc dispatch các incomming connection là rất nhanh
+ Mỗi process sẽ accept các connection từ shared socket và xử lý chúng riêng biệt
+ Main process sẽ kiểm soát các children process. (cung cấp lệnh để tắt tất cả
các children process, tạo một child process mới khi một child process bị crash...)

Kỹ thuật pre-forking được sử dụng rất nhiều. ví dụ: apache (httpd), nginx,
    celery, postgresql, rabbitmq, ....


Process trong Unix là một lĩnh vực rất thú vị, đặc biệt là trong lập trình hệ
thống và lập trình server. Bài viết chỉ mới đề cập đến một vài kiến thức và kỹ
thuật ban đầu với Process. Còn rất nhiều vấn đề chưa đề cập, như

+ Tương tác giữa các process (IPC)
+ Điều khiển các process
+ Orphaned, daemon, zoombie, process ...

Hy vọng trong tương lai, mình sẽ có thể viết về các vấn đề này kỹ hơn.

## Update

Bản slide tôi trình bày tại công ty Framgia về UNIX Process

<script async class="speakerdeck-embed" data-id="ce0d6da05a2e0130b5ab22000a8f8802" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

Bài viết được lấy từ blog [http://kiennt.com](http://kiennt.com/blog/2013/01/20/introduction-to-unix-process.html)
