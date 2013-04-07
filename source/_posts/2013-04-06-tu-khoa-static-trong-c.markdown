---
layout: post
title: "Ý nghĩa của từ khóa static trong C"
date: 2013-04-06 00:00
comments: true
categories:
- programming
---

## Mở đầu ##

Khi học C cơ bản, chắc hẳn bạn sẽ gặp cách dùng từ khoá static như ví dụ dưới đây:

{% highlight c %}
#include <stdio.h>

void count(int i)
{
    static int num = 0;
    num += i;
    printf("current value of num: %d\n", num);
}

int main()
{
    count(1);
    count(3);
    return 0;
}
{% endhighlight %}

Kết quả khi chạy chương trình sẽ là:

{% highlight bash %}
current value of num: 1
current value of num: 4
{% endhighlight %}

Biến num khai báo static như trên có 2 đặc điểm:

1. Do được khai báo static nên chỉ được khởi tạo 1 lần duy nhất và tồn tại suốt thời gian chạy của chương trình. Giá trị của biến count sẽ được tích luỹ mỗi khi hàm count được gọi.
2. Do khai báo trong nội bộ hàm count nên biến chỉ có thể được nhìn thấy bởi các câu lệnh trong hàm count. Nói cách khác, biến nm là 1 biến nội bộ (local variable).

Tuy vậy bạn sẽ bất ngờ khi bắt gặp những cách sử dung static trong như ví dụ dưới đây:

{% highlight c %}
#include <stdio.h>

static int a = 0;

static void count(int i)
{
    static int num = 0;
    num += i;
    printf("current value of num: %d\n", num);
}

int main()
{
    a += 1;
    printf("value of a: %d\n", a);
    count(1);
    count(3);
    return 0;
}
{% endhighlight %}

ta bắt gặp static ở 2 nơi nữa:

1. static trong khai báo hàm
2. static trong khai báo biến toàn cục

## 2 từ khoá static này có ngữ nghĩa như thế nào? ##

Để hiểu được ngữ nghĩa mới của static này, ta cần hiểu 1 khái niệm: đơn vị biên dịch (translation unit).

Mỗi project thường được viết trên nhiều file (vì mục đích phân chia module, đảm bảo tính dễ bảo trì). Mỗi file.c trong dự án sẽ là 1 đơn vị biên dịch. Quá trình biên dịch 1 project C sẽ là: biên dịch các đơn vị độc lập *.c ra các object file *.o (*.obj) và liên kết (link) các đơn vị object file thành chương trình.

Mỗi đơn vị sẽ có các thủ tục (procedure) hoặc function riêng. Code ở 1 đơn vị biên dịch có thể sử dụng thủ tục hoặc hàm, hay cả biến toàn cục ở đơn vị biên dịch khác. Ví dụ:

{% highlight c %}
//-----------------------
//A.c

int avar;

void a() {};

void b() {};

// -----------------------
//C.c

extern int avar;

void c() {};

void d() {};
{% endhighlight %}

thì trong a() của A.c ta có thể gọi c() một cách thoải mái. Biến avar sẽ được sử dụng cả ở A.c và C.c (biến toàn cục thực thụ!)

Để hạn chế việc sử dụng này (tránh va đụng tên hàm giữa các đơn vị biên dịch), người ta đưa khái niệm hàm tĩnh (static function) và biến tĩnh (static global variable).

Ngữ nghĩa:

* Biến toàn cục tĩnh sẽ có phạm vi trên đơn vị biên dịch. Điều đó có nghĩa là đơn vị khác không có cách nào truy cập được biến này.
* Hàm tĩnh sẽ có phạm vi trên đơn vị biên dịch. Điều đó có nghĩa đơn vị khác không thể truy cập được hàm này.

Do đó

{% highlight c %}
//-----------------
//A.c

static int avar;

static void a() {};

void b() {};

//------------------
//C.c

extern int avar;

void c() {};

void d() {};
{% endhighlight %}

Nếu ta khai báo static như trên, các hàm c, d trong C.c sẽ không thể nào truy cập được hàm a cũng như biến avar (dù rằng avar được khai báo extern trong C.c).

## Tóm lược ##

static có 2 ngữ nghĩa:

* Khi được sử dụng trong phạm vi toàn cục của 1 đơn vị biên dịch, static hạn chế truy cập từ các đơn vị biên dịch khác (áp dụng với cả hàm và biến toàn cục).
* Khi được sự dụng trong phạm vi cục bộ của 1 thủ tục hay hàm, static có nghĩa là biến được khai báo tồn tại trong suốt thời gian chạy của chương trình và chỉ được khởi tạo 1 lần duy nhất.

