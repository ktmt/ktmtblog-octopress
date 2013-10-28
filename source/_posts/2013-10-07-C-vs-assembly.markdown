---
layout: post
title: "Assembly vs C"
date: 2013-10-07 19:05
comments: true
categories: 
---

# Giới thiệu

> "Không ngôn ngữ lập trình nào có thể sinh mã chạy nhanh hơn mã assembly được viết cẩn thận"

Đây là điều đã được nói đến rất nhiều tại nhiều diễn đàn và blog công nghệ nhưng hầu như không có ví dụ minh hoạ nào cụ thể?? Để kiểm chứng tuyên bố trên, mình đã thử viết 1 chương trình bằng ngôn ngữ C, sau đó thử optimize chương trình bằng mã assembly, và cuối cùng đo thời gian chạy của 2 phiên bản. Điều mình rút ra là thực sự 1 chương trình assembly chạy nhanh hơn hẳn chương trình C tương tự, đúng như tuyên bố.

Bài viết này viết về quá trình mình kiểm chứng cũng như những điều rút ra từ quá trình này.

# Bài toán

Ta sẽ giải quyết bài toán: "biểu diễn tập con bằng số nhị phân". 

Ta có thể biểu diễn tập hợp con của 1 tập hợp bằng 1 chuỗi bit. Ví dụ xét tập hợp 4 phần tử, thì "0101" là 1 tập con. Ta có thể diễn giải chuỗi trên như sau: tập con có sự **xuất hiện** của phần tử vị trí 0 và 2. Nói 1 cách mình hoạ xét chuỗi ký tự "abcd" thì với chuỗi nhị phân ở trên ta có tập con "bd".

Bài toán là làm thế nào để liệt kê tất cả các tập con 2 phần tử của tập hợp trên. Nói cách khác liệt kê các xâu có 2 ký tự từ xâu "abcd"

# Thuật toán
Ta sẽ sử dụng thuật toán được **nghĩ ra** bởi Bill Gosper được lưu lại trong [HAKMEM][] số 175 (Hacker Memo) nổi tiếng của phóng thí nghiệm trí tuệ nhân tạo của trường MIT.

Thuật toán như sau:
Giả sử có chuỗi bit **x = xxx0 1111 0000** (xxx là 1 chuỗi bit 0 bất kỳ). Ta cần tìm cách sinh ra chuỗi bit có số lượng bit 1 không đổi. Nói cách khác kết quả của hàm sinh sẽ từ chuỗi hiện tại phải là **xxx1 0000 0111**. Các bước sinh diễn ra như sau: 

1. Thuật toán bắt đầu bằng cách tìm bit 1 cuối cùng bên phải bằng công thức s = x & -x cho ra kết quả **xxx0 0001 0000**
2. Cộng kết quả hiện tại với x cho ra kết quả r = xxx1 0000 0000. Bit 1 ở đây là 1 bit trong kết quả.
3. Đối với các bit kết quả còn lại, chúng ta tiến hành **điều chỉnh** n-1 bit 1, trong đấy n là số lượng bit 1 của nhóm bit 1 nằm bên phải nhất. Cụ thể ở đây là nhóm 1111.
   Ta có thể làm điều này bằng cách đầu tiên exclusive or (xor) r với x cho kết quả **xxx1 1111 0000**. Ta chia kết quả này cho s (là luỹ thừa của 2) và dịch kết quả có được thêm 2 vị trí nữa để loại bỏ bit không cần thiết. Kết quả có được là giá trị điểu chỉnh cuối cùng này or với r.

Công thức đại số để tính các bước ở trên như sau:

	 s <- x & -x
	 y <- s + x
	 y <- r | (((x xor r) >> 2) / s)


# Chương trình.

Ta sẽ benchmark bằng cách đo thời gian chạy của thuật toán viết bằng ngôn ngữ C và assembly rồi so sánh thời gian chạy của 2 chương trình viết bằng 2 ngôn ngữ với nhau.

## Chương trình viết bằng C
Để benchmark ta viết chương trình C biểu diễn thuật toán trên. binreprlà hàm giúp in giá trị nhị phân giúp quá trình kiểm tra được dễ dàng hơn. Nội dung thuật toán được viết trong hàm snoob_c:

{% codeblock snoob.c %}
#include <stdio.h>

void binrepr(unsigned a) {
    char r[32] = {0};
    int i;
    for (i = 0; i < 32; ++i) {
        r[31 - i] = ((a >> i) & 1) + '0';
    }
    puts(r);
}

unsigned snoob_c(unsigned x)
{
        unsigned smallest, ripple, ones;

        smallest = x & -x;
        ripple = x + smallest;
        ones = x ^ ripple;
        ones = (ones >> 2) / smallest;
        return ripple | ones;
}

int main()
{
    int a, b; 
    scanf("%d", &a);
    binrepr(a);
    b = snoob_c(a);
    binrepr(b);
    return 0;
}
{% endcodeblock %}

{% highlight bash %}
$ gcc -o snoob snoob.c
$ ./snoob
752
00000000000000000000001011110000
00000000000000000000001100000111
{% endhighlight %}

Tuyệt thuật toán chạy đúng! Ta sẽ cho thuật toán trên chạy 100 000 000 lần và đo tổng thời gian. Ta sửa lại hàm main như dưới đây:

{% codeblock snoob.c %}
int main()
{
    int a, b; 
	int i;
	a = 752;
    for (i = 0; i < 100000000; ++i) {
        b = snoob_c(a);
    } 
    return 0;
}
{% endcodeblock %}

{% highlight bash %}
$ gcc -o snoob snoob.c
$ time ./snoob
./snoob  0.83s user 0.00s system 99% cpu 0.832 total
{% endhighlight %}

Chương trình chạy 100 triệu lần hết 0.83s! C quả thực rất nhanh.

## Chương trình viết bằng assembly
Để có thể optimize hàm snoob, ta sẽ thử quan sát mã assembly của hàm snoob_c do gcc sinh ra:

{% highlight bash %}
$ gdb snoob
(gdb) disassemble snoob_c
Dump of assembler code for function snoob_c:
0x0000000100000e20 <snoob_c+0>: push   rbp
0x0000000100000e21 <snoob_c+1>: mov    rbp,rsp
0x0000000100000e24 <snoob_c+4>: mov    DWORD PTR [rbp-0x4],edi
0x0000000100000e27 <snoob_c+7>: mov    eax,DWORD PTR [rbp-0x4]
0x0000000100000e2a <snoob_c+10>:        mov    ecx,0x0
0x0000000100000e2f <snoob_c+15>:        sub    ecx,eax
0x0000000100000e31 <snoob_c+17>:        mov    eax,DWORD PTR [rbp-0x4]
0x0000000100000e34 <snoob_c+20>:        and    ecx,eax
0x0000000100000e36 <snoob_c+22>:        mov    DWORD PTR [rbp-0x10],ecx
0x0000000100000e39 <snoob_c+25>:        mov    eax,DWORD PTR [rbp-0x4]
0x0000000100000e3c <snoob_c+28>:        mov    ecx,DWORD PTR [rbp-0x10]
0x0000000100000e3f <snoob_c+31>:        add    eax,ecx
0x0000000100000e41 <snoob_c+33>:        mov    DWORD PTR [rbp-0x14],eax
0x0000000100000e44 <snoob_c+36>:        mov    eax,DWORD PTR [rbp-0x4]
0x0000000100000e47 <snoob_c+39>:        mov    ecx,DWORD PTR [rbp-0x14]
0x0000000100000e4a <snoob_c+42>:        xor    eax,ecx
0x0000000100000e4c <snoob_c+44>:        mov    DWORD PTR [rbp-0x18],eax
0x0000000100000e4f <snoob_c+47>:        mov    eax,DWORD PTR [rbp-0x18]
0x0000000100000e52 <snoob_c+50>:        shr    eax,0x2
0x0000000100000e55 <snoob_c+53>:        mov    ecx,DWORD PTR [rbp-0x10]
0x0000000100000e58 <snoob_c+56>:        xor    edx,edx
0x0000000100000e5a <snoob_c+58>:        div    ecx
0x0000000100000e5c <snoob_c+60>:        mov    DWORD PTR [rbp-0x18],eax
0x0000000100000e5f <snoob_c+63>:        mov    ecx,DWORD PTR [rbp-0x14]
0x0000000100000e62 <snoob_c+66>:        or     ecx,eax
0x0000000100000e64 <snoob_c+68>:        mov    DWORD PTR [rbp-0xc],ecx
0x0000000100000e67 <snoob_c+71>:        mov    DWORD PTR [rbp-0x8],ecx
0x0000000100000e6a <snoob_c+74>:        mov    eax,DWORD PTR [rbp-0x8]
0x0000000100000e6d <snoob_c+77>:        pop    rbp
0x0000000100000e6e <snoob_c+78>:        ret
0x0000000100000e6f <snoob_c+79>:        nop
End of assembler dump.
(gdb)
{% endhighlight %}

Quan sát mã assembly ta có vài nhận xét sau:

- Mã rất dài. Bên cạnh các instruction dùng để tính toán, các instruction dùng để di chuyển dữ liệu cũng chiếm khá nhiều thời gian chạy.
- Các kết quả tính toán trung gian được ghi ra bộ nhớ (do ta dùng các biến smalless, ripples, ones)

Theo như ["con số về độ trễ mà mọi lập trình viên nên biết"][], thì truy cập bộ nhớ / cache dù rất nhanh (tốn 0.5ns) vẫn chậm hơn rất nhiều so với truy cập trực tiếp từ thanh ghi. Ta đặt câu hỏi liệu có thể giảm thiểu lượt truy cập bộ nhớ cache được không?

["con số về độ trễ mà mọi lập trình viên nên biết"]: https://gist.github.com/talzeus/2851656

Quay trở lại thuật toán, ta thấy công thức đại số dùng 6 phép tính. Số lượng biến sử dụng chỉ có 4 biến. Do đó ta hoàn toàn có thể loại bổ các truy cập bộ nhớ, tính toán trực tiếp bằng các thanh ghi. Ta có hàm snoob viết bằng assembly như sau:

{% highlight bash %}
section .text
                global _snoob

;;; HAK Item 175
_snoob:
                push ebp
                mov ebp, esp
                mov ecx, [ebp + 8]
                mov ebx, ecx
                mov eax, ecx
                neg ebx
                and ebx, ecx
                add eax, ebx
                mov edi, eax
                xor eax, ecx
                shr eax, 2
                xor edx, edx
                div ebx
                or eax, edi
                pop ebp
{% endhighlight %}

Ta thay code hàm main thay vì gọi đến snoob_c ta gọi đến hàm snoob ở trên:

{% codeblock snoob.c %}
#include <stdio.h>

extern unsigned snoob(unsigned a);

void binrepr(unsigned a) {
    char r[32] = {0};
    int i;
    for (i = 0; i < 32; ++i) {
        r[31 - i] = ((a >> i) & 1) + '0';
    }
    puts(r);
}

int main()
{
    int a, b; 
    scanf("%d", &a);
    binrepr(a);
    b = snoob(a);
    binrepr(b);
    return 0;
}
{% endcodeblock %}


{% highlight bash %}
$ yasm -a x86 -f macho binrepr.asm
$ gcc -m32 -c snoob.c
$ gcc -m32 -o snoob snoob.o binrepr.o
$ ./snoob
752
00000000000000000000001011110000
00000000000000000000001100000111
{% endhighlight %}

Chương trình chạy đúng! Giờ đến phẩn benchmark. Ta sử dụng lại đoạn code benchmark, lần này thay vì gọi hàm snoob_c ta gọi hàm snoob viết bằng assembly. Ta có kết quả như sau:

{% highlight bash %}
$ gcc -m32 -c snoob.c
$ gcc -m32 -o snoob snoob.o binrepr.o
$ time ./snoob
./snoob  0.53s user 0.00s system 99% cpu 0.536 total
{% endhighlight %}

Ta có thể thấy tốc độ thay đổi 1 cách đáng kể! Thời gian chạy chỉ bằng **63.85%** thời gian chạy lần trước đấy.

※*Các đoạn code được chạy trên máy tính có phần cứng: cpu corei7, 8G Ram*

# Kết luận

- Bằng việc trực tiếp kiểm chứng, ta công nhận rằng mã viết bằng assembly nếu được optimize cẩn thận sẽ chạy nhanh hơn hẳn mã sinh bởi các ngôn ngữ bậc cao như C.
- Assembly rất thú vị. Ta có cảm giác kiểm soát toàn bộ máy tính!

# Tham khảo

1. [Hacker Delights][]
2. [HAKMEM][]

[Hacker Delights]: http://www.hackersdelight.org/
[HAKMEM]: http://www.inwap.com/pdp10/hbaker/hakmem/hakmem.html