---
layout: post
title: "Quy tắc xoắn ốc"
date: 2013-05-21 21:50
comments: true
categories: programming c++
---

### Quy tắc xoắn ốc
 
Có một quy tắc gọi là "quy tắc xoắn ốc" cho phép lập trình viên C/C++ phân tích trong đầu bất cứ khai báo nào. Quy tắc này rất đơn giản như sau:

* Bắt đầu bằng tên biến và di chuyển **xoắn ốc** theo chiều kim đồng hồ.
* Nếu gặp từ khóa const thì đối tượng nằm trên đường xoắn ốc trước const không đổi.
* Nếu gập ký tự * thì đối tượng trước khi đến * là một con trỏ.
* Nếu gặp [] thì đối tượng trước [] là một mảng.
* Nếu gặp (kiểu dữ liệu 1, kiểu dữ liệu 2), đối tượng trước đó là một function.


### Áp dụng

Ta tử áp dụng quy tắc trên để phân tích thử 1 số khai báo.

#### 1. Khai báo đơn giản

                     +-------+
                     | +-+   |
                     | ^ |   |
                char *str[10];
                 ^   ^   |   |
                 |   +---+   |
                 +-----------+

**Ý nghĩa**: str là một mảng (10 ký tự) con trỏ có kiểu dữ liệu ký tự (char).

#### 2. Con trỏ hàm

              +--------------------+
              | +---+              |
              | |+-+|              |                    
              | |^ ||              |
         char *(*fp)( int, float *);
          ^   ^ ^  ||              |
          |   | +--+|              |
          |   +-----+              |
          +------------------------+


**Ý nghĩa**: fp là 1 con trỏ, trỏ đến 1 function (nhận 2 đối số là int, và con trỏ kiểu float), trả về 1 con trỏ  có kiểu dữ liệu ký tự (char).

#### 3. Const

* Ví dụ 1	 

        char greeting[] = "Hello";
               +-----------------+
               |   +-----------+ |
               |   | +-------+ | |
               |   ^ ^       v | | 
        const char * p = greeting;
           ^   ^   ^         | | |
           |   |   |         | | |
           |   |   +---------+ | |
           |   +---------------+ |   
           +---------------------+

**Ý nghĩa**: p có giá trị giống greeting, và là 1 con trỏ, trỏ đến dữ liệu kiểu char, giá trị này là hằng số (không thay đổi).

* Ví dụ 2

        char greeting[] = "Hello";
                 +------------------------+   
                 | +-------------------+  |
                 | |     +-----------+ |  |
                 | |     | +-------+ | |  |
                 | |     ^ ^       v | |  |
        const char * const p = greeting;  |
           ^     ^ ^     ^         | | |  |
           |     | |     |         | | |  |
           |     | |     +---------+ | |  |
           |     | +-----------------+ |  |
           |     +---------------------+  |
           +------------------------------+

**Ý nghĩa**: p có giá trị giống greeting, giá trị của p không đổi, và nó là 1 con trỏ, trỏ đến dữ liệu kiểu chả, và dữ liệu của là hằng số.

### Cuối cùng

Quy tắc **xoắc ốc** giúp ta hiểu ý nghĩa khai báo C/C++ một cách dễ dàng. Bây giờ với quy tắc này, bạn chắc chắn khai báo dưới đây dễ hiểu như ăn kẹo rồi phải không?
    void (*signal(int, void (*fp)(int)))(int);
