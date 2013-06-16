---
layout: post
title: "Cách tính căn bậc 2"
date: 2013-06-16 21:23
comments: true
categories: computation
---

## Câu chuyện 

Trong một buổi phỏng vấn kỹ thuật tại công ty XXX, một lập trình viên "lão thành" chịu trách nhiệm phỏng vấn Tèo hỏi Tèo một câu:

> "Hãy viết chương trình C tính căn bậc 2 của số nguyên x"

Tèo cười thầm và tự nghĩ "Công ty công nghệ hàng đầu Việt Nam gì mà hỏi một câu dễ vậy. Nó đâu phải là thằng mới học lập trình!"

Và Tèo trong chớp mắt đưa ra ngay lời giải với đoạn code như dưới đây:

{% codeblock sqrt.c %}
#include <stdio.h>
#include <math.h>

int main()
{
    int x;
    printf("Input x: ");
    scanf("%d", &x);
    printf("Sqrt of %d = %f\n", x, sqrt(x));
}
{% endcodeblock %}

{% highlight bash %}
Input x: 3
Sqrt of 3 = 1.732051
{% endhighlight %}

Chương trình compiled không có 1 lỗi và kết quả đúng.

Tèo tự tin. Không ngờ công ty XXX nổi tiếng mà lại hỏi một câu ngớ ngẩn đến thế! Nó nghĩ.

Lập trình viên kinh nghiệm nhìn code của Tèo và khen: "Cậu có căn bản!". Tèo sung sướng và nghĩ rằng mình đã chắc chắn 100% được nhận vào làm việc. Đúng lúc đấy vị lập trình viên già kia hỏi tiếp: 

> "Cậu hãy trả lời lại câu hỏi trên, lần này không dùng hàm sqrt của thư viện C"

"Chà câu hỏi có vẻ khó hơn. Tèo bắt đầu suy nghĩ. Sau một lúc cậu bắt đầu gãi đầu gãi tai. Làm thế nào để tính bây giờ? Tèo nghĩ mãi nghĩ mãi..."

Hết giờ! Người phỏng vấn Tèo nhận xét: "Cậu vẫn còn phải học nhiều". Tèo buồn bã vì biết rằng mình đã trượt. Tuy vậy, nó nghĩ dù trượt nhưng nó nên ra về biết thêm 1 điều gì mới, nó liền hỏi người phỏng vấn: 

"Làm thế nào tôi có thể tính được căn bậc hai? Phải chăng tôi cần một thuật toán phức tạp với rất nhiều dòng mã?". 

Vị lập trình viên "lão thành" cười và trả lời: "Máy tính làm phép tính rất nhanh, thay vì có câu trả lời tuyệt đối, ta có thể bắt nó đoán câu trả lời cho ta!". Nhìn mặt Tèo lớ ngớ, vị kỹ sư già vừa cười vừa từ tốn giải thích tiếp.

Căn bậc hai của y được định nghĩa là số x sao cho: x^2 == y hay x = y / x. Nếu x là kết quả thì x = y / x, còn nếu không kết quả sẽ phải là 1 số x' nằm trong khoảng x và y/x. Ta không biết số này là bao nhiêu, nhưng ta có 1 cách để đoán lấy 1 số trong khoảng này đó là trung bình cộng!

Tèo gật gù.

Ví dụ: cần tính căn bậc 2 của 3. Ta đoán kết quả là 1.0. Kết quả này không đúng rồi, nên đáp số sẽ nằm trong khoảng 1.0 và 3/1.0 = 2.0. Lấy trung bình cộng lần 1 ta có kết quả là 1.5. Lại thử với 1.5 và 3/1.5 = 2.0 ta có kết quả là 1.75! Sau nhiều lần lặp ta sẽ có kết quả tiệm cận với đáp số!

Tèo sáng mắt! Vị kỹ sư cười và tiếp tục.

Vì ta không có kết quả chính xác, nên số lần lặp sẽ là vô hạn. Tuy vậy tại mỗi bước lặp, ta sẽ thử xem kết quả đủ chính xác theo yêu cầu chưa. Ví dụ nếu đáp số hiện tại là x = 1.73, x^2 = 2.99 và ta chỉ cần độ chính xác đến 2 số sau dấu phẩy, thì 1.73 là đáp án phù hợp. Do vậy ta sẽ có chương trình tính căn bậc 2 như sau:

{% codeblock sqrt.c %}
#include <stdio.h>
#include <math.h>

#define PRECISE 0.0001f

double mysqrt(int x)
{
    double guess = 1.0f;
    while (fabs(guess*guess - x) >= PRECISE)
        guess = (x/guess - guess) / 2 + guess;
    return guess;
}

int main(void)
{
    int x;
    printf("Input x: ");
    scanf("%d", &x);
    printf("Sqrt of %d = %f\n", x, mysqrt(x));
    return 0;
}
{% endcodeblock %}

{% highlight bash %}
Input x: 3
Sqrt of 3 = 1.732051
{% endhighlight %}

Và Tèo được khai sáng!

## Tham khảo
1.[Structure and Interpretation of Computer Programs][]
2.[Newton method][]

[Structure and Interpretation of Computer Programs]: http://mitpress.mit.edu/sicp/full-text/book/book.html
[Newton method]: https://en.wikipedia.org/wiki/Newton's_method
