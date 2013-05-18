---
layout: post
title: "Ý nghĩa của từ khóa volatile trong C" 
date: 2013-05-09 15:31
comments: true
categories: 
---

#Mở đầu#

Trong lập trình nhúng (embedded system), ta rất thường hay gặp khai báo biến với từ khóa volatile. Việc khai báo biến volatile là rất cần thiết để tránh những lỗi sai khó phát hiện do tính năng optimization của compiler. Trong bài viết này, ta sẽ tìm hiểu ý nghĩa của từ khóa này, cách sử dụng nó và giải thích tại sao nó quan trọng trong một số trường hợp lập trình với hệ thống nhúng và lập trình ứng dụng đa luồng.  

#Tại sao cần phải có biến volatile#

Cách khai báo biến với từ khóa volatile:

{% codeblock %}
volatile int foo;//both this way...
int volatile foo;//... and this way is OK! Define a volatile integer variable

volatile uint8_t *pReg;//both this way...
uint8_t volatile *pReg;//... and this way is OK! Define a pointer to a volatile unsigned 8-bit integer
{% endcodeblock %}

Một biến cần được khai báo dưới dạng biến volatile khi nào? Khi mà giá trị của nó có thể thay đổi một cách không báo trước. Trong thực tế, có 3 loại biến mà giá trị có thể bị thay đổi như vậy: 

+ Memory-mapped peripheral registers (thanh ghi ngoại vi có ánh xạ đến ô nhớ)
+ Biến toàn cục được truy xuất từ các tiến trình con xử lý ngắt (interrupt service routine)
+ Biến toàn cục được truy xuất từ nhiều tác vụ trong một ứng dụng đa luồng. 

##Thanh ghi ngoại vi##

Trong các hệ thống nhúng thường có các thiết bị ngoại vi (ví dụ như cổng vào ra đa chức năng GPIO, cổng UART, cổng SPI, ...), và các thiết bị ngoại vi này chứa các thanh ghi mà giá trị của nó có thể thay đổi ngoài ý muốn của dòng chương trình (program flow). Ví dụ một thanh ghi trạng thái pStatReg, ta cần phải thực hiện polling thanh ghi trạng thái này đến khi nó khác 0 
(Đoạn code minh họa với Keil ARM compiler, trên vi điều khiển ARM LPC2368)

{% codeblock mappedIOi_nonvolatile.c%}
unsigned long * pStatReg = (unsigned long*) 0xE002C004;
//Wait for the status register to become non-zero
while(*pStatReg == 0) { }
{% endcodeblock %}

Đoạn code này có gì không ổn? Nó sẽ chạy sai khi ta bật chức năng tối ưu (optimization) của compiler. 
Quan sát mã assembly mà compiler xuất ra của đoạn code trên như sau: 
{% codeblock mappedIO_nonvolatile.s%}
        LDR      r0,|L2.564|
        SUB      sp,sp,#0x10
        LDR      r0,[r0,#0]
|L2.22|
        CMP      r0,#0
        BEQ      |L2.22|
        LDR      r1,|L2.564|
...
|L2.564|
        DCD      0xe002c004
{% endcodeblock %}

Trước khi vào label |L2.22|, tương ứng với vòng lặp while, thanh ghi r0 được ghi vào giá trị được lưu trong ô nhớ 0xE002C004. Khi vào vòng lặp while, compiler thực hiện ngay việc so sánh giá trị của thanh ghi r0 với 0. Tại sao lại như vậy? Vì compiler nhận thấy biến pStatReg là một biến normal, giá trị của nó được hiểu là không thể thay đổi một cách bất thường. Do vậy, khi bật tối ưu, compiler sẽ chỉ thực hiện so sánh giá trị của r0 mà không load lại giá trị này từ ô nhớ 0xE002C004, vì theo flow của chương trình thì biến pStatReg không bị thay đổi ở bất cứ đâu. Do đó, vòng lặp while sẽ chạy vô tận, hoặc không chạy gì cả (tùy theo giá trị ban đầu mà pStatReg trỏ đến). 

Điều gì sẽ xảy ra nếu ta đổi biến pStatReg sang volatile? 

{% codeblock mappedIO_volatile.c%}
volatile unsigned long * pStatReg = (unsigned long*) 0xE002C004;
//Wait for the status register to become non-zero
while(*pStatReg == 0) { }
{% endcodeblock %}

Mã assembly mà compiler xuất ra sẽ như sau: 

{% codeblock mappedIO_volatile.s%}
	SUB      sp,sp,#0x10
        LDR      r0,|L3.544|
|L3.4|
        LDR      r1,[r0,#0]
        CMP      r1,#0
        BEQ      |L3.4|
        LDR      r1,|L3.544|
...
|L3.544|
        DCD      0xe002c004
{% endcodeblock %}

Điều gì khác biệt ở đây? Đầu tiên, ở dòng LDR trước label |L3.4|, compiler đã đặt địa chỉ 0xE002C004 vào thanh ghi r0. Ở dòng LDR đầu tiên ngay sau label |L3.4|, ta thấy compiler đã LOAD LẠI GIÁ TRỊ của ô nhớ 0xE002C004 vào ô nhớ r1! Sau đó nó mới thực hiện so sánh giá trị của ô nhớ r1 này với 0.  

Lý do là gì? Vì ta đã đặt biến pStatReg là biến volatile, để báo hiệu là biến này có thể thay đổi một cách bất thường, ngoài flow của chương trình. Do vậy nên, để "đề phòng", compiler lúc nào cũng phải load lại giá trị mới của ô nhớ 0xE002C004, để đảm bảo mình có giá trị mới nhất! 

Đến đây, bạn có thể hỏi là "giá trị bị thay đổi một cách bất thường" là như thế nào? Hiện tượng này đặc biệt hay xảy ra khi lập trình nhúng.  Trong hệ thống nhúng, một thanh ghi có thể bị thay đổi giá trị do những điều kiện bên ngoài. Ví dụ như mức điện áp không vượt quá ngưỡng, làm cho giá trị 0 thành 1, 1 thành 0. Hoặc, khi cổng UART nhận được đầy buffer thì thanh ghi BUFFER_READY tự động chuyển 0 thành 1... Bằng cách sử dụng biến volatile, chương trình C được compiler biên dịch sẽ đảm bảo luôn luôn đọc lại giá trị của thanh ghi, tránh mọi assumption của compiler.  

##Tiến trình con xử lý ngắt (Interrupt Service Routine)##  

Ngắt là một khái niệm quan trọng trong hệ thống nhúng. Có nhiều loại ngắt khác nhau như ngắt vào ra (I/O), ngắt SPI, ngắt UART... Mỗi khi xảy ra ngắt, stack pointer sẽ nhảy đến chương trình con xử lý ngắt (ISR). Thường thì các chương trình con xử lý ngắt này sẽ thay đổi giá trị của biến toàn cục và trong chương trình chính sẽ đọc những giá trị này để xử lý.

Để dễ hiểu, lấy ví dụ ngắt cổng serial (UART) kiểm tra các kí tự nhận được xem có phải là 0xFF không. Nếu là kí tự 0xFF, ISR sẽ set một biến cờ toàn cục. Nếu không có volatile, code như sau: 

{% codeblock isr.c %}
int etx_rcvd = FALSE;

void main()
{
	...
	while(!ext_rcvd)
	{
		//Wait...
	}
	...
}

interrupt void rx_isr(void)
{
	...
	if(0xFF == rx_char)
	{
		...
		etx_rcvd = TRUE;
	}
	...
}
{% endcodeblock %}

Ta để ý trong main(): compiler không thể biết được là biến ext_rcvd có thể bị thay đổi trong ISR. Compiler dò đoạn code, thấy rằng biểu thức !ext_rcvd luôn đúng, vì thế không thể thoát được vòng lặp while. Nếu compiler được bật optimization lên, tất cả đoạn code sau vòng lặp while sẽ bị loại bỏ. Nếu không có warning cẩn thận, chương trình của ta có thể bị lỗi mà phát hiện rất khó. 

Giải pháp là đặt biến ext_rcvd là biến volatile. compiler sẽ biết đó là biến có thể bị thay đổi theo một cách nào đó ngoài ý muốn (ở đây là do ISR). Compiler sẽ bị buộc phải check giá trị của biến ext_rcvd. 

##Ứng dụng đa luồng ##

Trong các ứng dụng đa luồng, thường xảy ra trường hợp các tác vụ trao đổi thông tin với nhau thông qua một biến toàn cục. Như vậy, một tác vụ thay đổi giá trị của biến toàn cục cũng sẽ giống như trường hợp ISR ở trên. Nếu compiler mà bật tính năng optimization thì sẽ xảy ra vấn đề. 

Ví dụ đoạn code 
{% codeblock multithreaded.c %}
int cntr;

void task1(void)
{
	cntr = 0;
	
	while(cntr == 0)
	{
		sleep(1);
	}
	//code follows...
}

void task2(void)
{
	//...code...
	cntr ++;
	sleep(10);
	//...code...
}

{% endcodeblock %}

Cách khắc phục vấn như cũ: đặt biến cntr thành biến volatile !  
