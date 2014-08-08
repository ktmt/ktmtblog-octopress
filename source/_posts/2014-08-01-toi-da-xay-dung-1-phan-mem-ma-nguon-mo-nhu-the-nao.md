---
layout: post
title: "Tôi đã xây dựng 1 phần mềm mã nguồn mở như thế nào"
date: 2014-08-01 20:00
comments: true
categories:
  - programming
  - linux
  - macosx
  - twitter
  - python

---

*Lưu ý trước khi đọc tiếp: Ở bài viết này tác giả dùng chữ "hacker", không phải theo nghĩa chỉ những người làm trong lĩnh vực bảo mật hay an toàn thông tin. "Hacker" ở đây là những kỹ sư, những nhà phát triền có năng lực tự tìm hiểu, mày mò, có kỹ năng "bắt máy tính phục vụ sở thích của mình".*


# Ý tưởng

Nếu bạn là một hacker làm việc nhiều với Mac hoặc Linux, chắc các bạn chẳng xa lạ gì với terminal - giao diện dòng lệnh cơ bản nhất của hệ điều hành Unix. Tôi là một hacker bị "cuồng terminal", `zsh`, `prezto`, `tmux`, `irssi`, `vim`, `tig` là những tools ưa thích nhất. Tôi từng có ước mơ muốn từ bỏ các giao diện đồ hoạ, có thể lập trình, chat chit, nghe nhạc v.v.. ngay trên môi trường không-đồ-hoạ. 

Bên cạnh đó, mặc dù không mấy mặn mà với Facebook nhưng gần đây lại bị nghiện Twitter, trong đầu tôi luôn hiện lên câu hỏi: làm thế nào để cũng có thể tương tác với Twitter chỉ qua terminal của MacOSX ?

Trên thực tế đã có khá nhiều thư viện mã nguồn mở có thể đáp ứng được nhu cầu trên. [t][1] hay [earthquake][2] là những gem(Ruby) được viết rất bài bản và đa tính năng. Tuy nhiên tôi đã quyết định tự viết một phần mềm của riêng mình, bởi tự phát triền và làm sản phẩm của mình được cộng đồng đón nhận là một mục tiêu mới mẻ và đầy thử thách.

Trong bài viết này, tôi sẽ giới thiệu với các bạn tôi đã xây dựng một phần mềm mã nguồn mở như thế nào, về cả kỹ năng phát triển và cách mang phần mềm của mình đến với cộng đồng hacker trên thế giới.


# Xác định mục tiêu

Khi bạn bắt đầu viết một phần mềm mã nguồn mở, điều quan trọng đầu tiên sẽ là : **đã có ai thực hiện ý tưởng của bạn chưa** và họ **đã thực hiện được tốt đến đâu**. Khi chuẩn bị viết phần mềm của mình, tôi nhận thấy [t][1] giống như *1 twitter command trên Unix*, focus vào khả năng pipe với các command khác. Ngược lại, [earthquake][2] là 1 app hoàn chỉnh nhưng *xử lý hiển thị tweets lại chưa thật tốt*. 

Và từ đó [Rainbow Stream][3] ra đời. Bạn có thể nhận ra 2 điểm nêu trên khi nhìn vào cách thức hoạt động của app dưới đây:

![][4]


# Tạo nên sự khác biệt

Để gây được ấn tượng với người dùng, sản phẩm của bạn vẫn cần có 1 đến 2 tính năng nổi trội. Bạn sẽ không muốn phần mềm mình viết ra mãi chỉ là  "alternative to xxx or yyy, can consider if zzz stops development". Ở đây, tôi xây đựng [Rainbow Stream][3] tập trung vào 2 tính năng chính:

* Khả năng hiển thị màu sắc trên các terminal hỗ trợ 256 màu, cung cấp sẵn 1 số themes nổi tiếng.
* Hiện thị ảnh *trực tiếp trên terminal*.

Chúng ta sẽ đi vào cụ thể trong các phần tiếp theo.

## Hiển thị màu của terminal

Hầu hết các terminal hiện đại đều hỗ trợ hiển thị *256 ANSI colors*. Trên shell bạn có thể dễ dàng in ra chữ theo các màu định sẵn bẳng các dùng *Escape character* như dưới đây

{%codeblock color - color.sh %}
$ echo -e "\e[31mRed"
$ echo -e "\e[32mGreen"
$ echo -e "\e[33mYellow"
$ echo -e "\e[34mBlue"
$ echo -e "\e[35mMagenta"
$ echo -e "\e[36mCyan"
$ echo -e "\e[37mLight gray"
{%endcodeblock%}

Hiện thị màu trên Python có thể được viết gọn theo function như sau

{%codeblock color - color.py %}
def basic_color(code):
    """
    16 colors supported
    """
    def inner(text, bold=True):
        c = code
        if bold:
            c = "1;%s" % c
        return "\033[%sm%s\033[0m" % (c, text)
    return inner


def term_color(code):
    """
    256 colors supported
    """
    def inner(text):
        c = code
        return "\033[38;5;%sm%s\033[0m" % (c, text)
    return inner
{%endcodeblock%}

Sử dụng những function ở trên thực tế rất đơn giản:

{%codeblock color - color.py %}
black = basic_color('30')
red = basic_color('31')
green = basic_color('32')
yellow = basic_color('33')
blue = basic_color('34')
magenta = basic_color('35')
cyan = basic_color('36')
# Print
print green("Green text") 
print term_color('112')("A text with ANSI color 112")
{%endcodeblock%}

Giả sử chúng ta có một tập vô hạn các word không biết trước. muốn mỗi word có một màu và các word lặp lại sẽ có màu giống nhau, chúng ta có thể dùng *Memoization* trong Python như sau:

{%codeblock color - color.py %}
import itertools
from functools import wraps
cyc = itertools.cycle([black,red,green,yellow,blue,magenta,cyan])

def Memoize(func):
    cache = {}
    @wraps(func)
    def wrapper(*args):
        if args not in cache:
            cache[args] = func(*args)
        return cache[args]
    return wrapper

@Memoize
def cycle_color(s):
    return next(cyc)(s)

for s in ["w1","w2","w3","w1","w4"]:
    print cycle_color(s) # Now every word will has its color, while the 1st "w1" and 3nd "w2" ends up with same color
{%endcodeblock%}

Các màu sắc hiển thị trong [Rainbow Stream][3] đều dựa theo nguyên lý nói trên.


## Hiển thị ảnh trên terminal
Để nói cụ thể về phần này sẽ hơi dài dòng, nhưng có thể tóm gọn trong các ý sau đây:

* Python có một thư viện xử lý ảnh rất tốt là `Pillow`. `Pillow` cung cấp những tính năng cở bản để tháo tác với lượng thông tin trong một tấm ảnh. Nhược điểm của `Pillow` là khá buggy khi install và không hỗ trợ Window.
* Tôi dùng `Pillow` để đọc thông tin về từng Pixel trong một ảnh, mỗi pixel sẽ có 4 chỉ số gồm 3 chỉ số màu (R,G,B) và 1 chỉ số về độ trong (A).
* Màu sắc của 1 pixel nói trên được quy đổi về tập 256 màu ANSI hiển thị được trên terminal (phương pháp xem ở dưới).
* Với mỗi pixel, tôi in ra như 1 ký tự Space với màu ANSI tương ứng, sử dụng hàm `term_color` ở đoạn trên.

Trong các bước trên thì bước quy đổi màu là quan trọng nhất. Thuật toán quy đổi dùng ở đây là phương pháp tính khoảng cách vector trong không gian Euclide 3 chiều:

* Mỗi màu RGB coi như 1 vector với 3 chiều là R (Red), G (Green), B (Blue). 
* Mỗi màu ANSI (trong tập 256 màu của terminal) cũng tương ứng với 1 vector 3 chiều. Chúng ta có tập tiêu chuẩn 256 vector ở đây.
* Mỗi vector RGB của 1 pixel sẽ được quy về vector tiêu chuẩn ANSI *gần nhất*. Công thức tính khoảng cách giữa 2 đầu vector như trong hình học 3 chiều : `((x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2)**0.5`

Như vậy "ảnh" ở trên terminal thực chất là các ký tự Space với màu ANSI đã được quy đổi và in ra liên tiếp :)

## Các vấn đề kỹ thuật khác
Để hoàn thiện [Rainbow Stream][3] thực ra cần một kỹ năng khác như lập trình với thread, tạo interactive input bẳng readline, gọi chương trình C compile sẵn hay xử lý chung cho cả Python 2 và Python 3 ... Trong khuôn khổ một bài viết tôi khó có thể trình bày hết những vấn đề trên, vì vậy nếu bạn quan tâm hãy mở thẳng [Github repo][3] và đọc source code. [Rainbow Stream][3] là một phần mềm mã nguồn mở với MIT license.


*(... còn tiếp - Làm thế nào để mang phần mềm của mình đến với thế giới hacker ...)*



[1]:https://github.com/sferik/t
[2]:https://github.com/jugyo/earthquake
[3]:https://github.com/DTVD/rainbowstream
[4]:https://raw.githubusercontent.com/DTVD/rainbowstream/master/screenshot/rs.gif

