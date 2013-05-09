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

Trong các hệ thống nhúng thường có các thiết bị ngoại vi (ví dụ như cổng vào ra đa chức năng GPIO, cổng UART, cổng SPI, ...), và các thiết bị ngoại vi này chứa các thanh ghi mà giá trị của nó có thể thay đổi ngoài ý muốn của dòng chương trình (program flow). Ví dụ một thanh ghi trạng thái 8 bit được đánh địa chỉ 0xFEEF. Ta cần phải thực hiện polling thanh ghi trạng thái này đến khi nó khác 0 
{% codeblock mappedIO.c%}
uint8_t * pStatReg = (uint8_t *) 0xFEEF;

//Wait for the status register to become non-zero
while(*pStatReg == 0) { }
{% endcodeblock %}

Đoạn code này có gì không ổn? Nó sẽ chạy sai khi ta bật chức năng tối ưu (optimization) của compiler. Compiler đã đọc được giá trị mà con trỏ pStatReg trỏ đến sau dòng thứ nhất. Tiếp theo, khi đến vòng lặp while, compiler nhận thấy không cần thiết phải đọc lại giá trị mà con trỏ pStatReg trỏ đến nữa, vì nó không thấy đoạn code nào ở giữa có thể thay đổi giá trị này được. Như vậy, *pStatReg luôn giữ nguyên một giá trị, và do đó vòng lặp while sẽ chạy vô tận, hoặc không chạy gì cả (tùy theo giá trị ban đầu mà pStatReg trỏ đến).

 Trong hệ thống nhúng, một thanh ghi có thể bị thay đổi giá trị do những điều kiện bên ngoài. Ví dụ như mức điện áp không vượt quá ngưỡng, làm cho giá trị 0 thành 1, 1 thành 0. Hoặc, khi cổng UART nhận được đầy buffer thì thanh ghi BUFFER_READY tự động chuyển 0 thành 1... Bằng cách sử dụng biến volatile, chương trình C được compiler biên dịch sẽ đảm bảo luôn luôn đọc lại giá trị của thanh ghi, tránh mọi assumption của compiler.  

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
