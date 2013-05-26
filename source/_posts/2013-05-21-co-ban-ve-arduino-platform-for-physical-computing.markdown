---
layout: post
title: "Cơ bản về Arduino - Platform for Physical Computing"
date: 2013-05-21 09:37
comments: true
categories: 
- arduino
- physical computing
- embedded
---

#Giới thiệu về Arduino và Physical Computing#

Có thể bạn đã quen lập trình trên PC, với những ngôn ngữ như C, C++, C#, Java, Python, Ruby...  

Nhưng bạn có biết là phần mềm trên PC chỉ chiếm khoảng 10% sản lượng phần mềm trên thị trường. 90% còn lại là code điều khiển tivi, máy giặt, điều hòa, tủ lạnh... tóm lại là tất cả các thiết bị điện tử xung quanh bạn. Đây cũng là một mảng theo tôi là khá thú vị. Lập trình theo hướng này được gọi là embedded computing, hay physical computing, tức là lập trình để con người tương tác với các thiết bị thực.  

Để người thiết kế có thể nhanh chóng đưa ra được mẫu thể hiện ý tưởng của mình, rất cần phải có những platform để dễ dàng prototyping. Và một trong những platform đang được sử dụng rất nhiều trong prototyping là Arduino. 

Vậy Arduino là gì và vì sao nó được sử dụng rộng rãi như vậy?  

Arduino là một bo mạch xử lý được dùng để lập trình tương tác với các thiết bị phần cứng như cảm biến, động cơ,... Điểm hấp dẫn ở Arduino với anh em lập trình là ngôn ngữ cực kì dễ học (giống C/C++), các ngoại vi trên bo mạch đều đã được chuẩn hóa, nên không cần biết nhiều về điện tử, chúng ta cũng có thể lập trình được những ứng dụng thú vị. Thêm nữa, vì Arduino là một platform đã được chuẩn hóa, nên đã có rất nhiều các bo mạch mở rộng (gọi là shield) để cắm chồng lên bo mạch Arduino, có thể hình dung nôm na là "library" của các ngôn ngữ lập trình. Ví dụ, muốn kết nối Internet thì có Ethernet shield, muốn điều khiển động cơ thì có Motor shield, muốn kết nối nhận tin nhắn thì có GSM shield,... Rất đơn giản, và ta chỉ phải tập trung vào việc "lắp ghép" các thành phần này và sáng tạo ra các ứng dụng cần thiết :)

Có thể kể ở đây một số ứng dụng hay ho của Arduino: 

- Robot: Arduino được dùng để làm bộ xử lý trung tâm của rất nhiều loại robot. Đó là nhờ vào khả năng đọc các thiết bị cảm biến, điều khiển động cơ,... của Arduino.  

- Game tương tác: chúng ta có thể dùng Arduino để tương tác với Joystick, màn hình,... để chơi các trò như Tetrix, phá gach, Mario... Còn nhiều game rất sáng tạo nữa, ví dụ bạn có thể tham khảo ở đây: 
[http://wn.com/arduino_game](http://wn.com/arduino_game)

- Máy bay không người lái

- Mô phỏng Ipod :D (ví dụ ở đây: [http://www.youtube.com/watch?v=5gy7w6R091M](http://www.youtube.com/watch?v=5gy7w6R091M))

- và nhiều nhiều ứng dụng khác nữa ... 
 
#Để lập trình Arduino cần những gì? #

Như vậy, bạn đã biết là tuy là một bo mạch nhỏ như thế, Arduino có thể dùng vào rất nhiều ứng dụng thú vị khác nhau. Vậy để phát triển ứng dụng dựa trên Arduino, ta cần những gì? 
Rất đơn giản, bạn chỉ cần IDE phát triển (download ở [đây](http://arduino.cc/)), một dây kết nối USB loại A-B, và một bo mạch Arduino là bạn có thể bắt đầu được rồi. 

Ngôn ngữ lập trình của Arduino dựa trên ngôn ngữ lập trình Wiring cho phần cứng. Chắc bạn đã quá quen thuộc với ngôn ngữ C/C++, như vậy việc viết code Wiring là rất dễ dàng. Cộng thêm, trên [website](http://arduino.cc/), có khá nhiều các library viết sẵn để điều khiển ngoại vi: LCD, sensor, motor... nên việc bạn cần làm chỉ là kết hợp chúng với nhau để tạo ứng dụng cho riêng bạn.  

#Cận cảnh phần cứng của Arduino#

{% img /images/arduino-intro/arduino-overview.gif  %}

Hình trên là cận cảnh con Arduino Uno. Đối với chúng ta lập trình cho Arduino thì trước tiên quan tâm những thành phần được đánh số ở trên: 

1. Cổng USB (loại B): đây là cổng giao tiếp để ta upload code từ PC lên vi điểu khiển. Đồng thời nó cũng là giao tiếp serial để truyền dữ liệu giữa vi điểu khiển với máy tính.

2. Jack nguồn: để chạy Arduino thì có thể lấy nguồn từ cổng USB ở trên, nhưng không phải lúc nào cũng có thể cắm với máy tính được. Lúc đó, ta cần một nguồn 9V đến 12V. 

3. Hàng Header: đánh số từ 0 đến 12 là hàng digital pin, nhận vào hoặc xuất ra các tín hiệu số. Ngoài ra có một pin đất (GND) và pin điện áp tham chiếu (AREF).

4. Hàng header thứ hai: chủ yếu liên quan đến điện áp đất, nguồn. 

5. Hàng header thứ ba: các chân để nhận vào hoặc xuất ra các tín hiệu analog. Ví dụ như đọc thông tin của các thiết bị cảm biến. 

6. Vi điều khiển AVR: đây là bộ xử lý trung tâm của toàn bo mạch. Với mỗi mẫu Arduino khác nhau thì con chip này khác nhau. Ở con Arduino Uno này thì sử dụng ATMega328. 

#"Hello World" trên nền Arduino#

Với việc học bất cứ một ngôn ngữ nào, thường người ta hay bắt đầu bằng ví dụ "Hello World", tức là bắt máy tính bắn ra màn hình dòng chữ "Hello, World!". Với các bạn có kinh nghiệm lập trình, việc này có lẽ quá dễ dàng, chỉ vài dòng code là được, ngôn ngữ nào cũng vậy (C, C++, Java, Python, Ruby...). 

Nhưng với lập trình trên Arduino thì sao? Việc bắt cái bo mạch Arduino đưa ra một thông tin báo hiệu nào đó cho ta là nó đang chạy, phải thực hiện thế nào? Nói cách khác, output của Arduino sẽ là như thế nào đây:

1. Nháy LED

2. Kết nối với PC qua đường UART, bắn lên dòng chữ Hello World cho ta ngắm. 

3. Kết nối với một cái màn LCD, cũng bắt nó bắn lên Hello World cho ta nhìn.

... vài cách nữa 

Trong bài mở đầu này, tôi chọn cách dễ nhất là Nháy LED. Nháy LED cũng được coi là Hello World của lập trình nhúng, với mỗi con chip mới, điều đầu tiên nên làm là nháy LED, để kiểm tra xem mình đã kiểm soát được đầu vào đầu ra cho con chip chưa :)  

Đầu tiên là đoạn code nháy LED:

{% codeblock blink_series.c %}
/* 
  Multiple blink 
  Turns on and off a LED series, using Arduino pin 4,5,6,7
  
  written by Viet Nguyen
 */
 
 int led;
 
 //the setup routine runs once when you reset the Arduino
 void setup()
 {
   //initialize the digital pin as an output
   for(led = 4; led < 8; led ++)
   {
     pinMode(led, OUTPUT); //init the digital pin as output.
   }
 }
 
 // the loop routine runs over and over again
 void loop()
 {
   for(led = 4; led < 8; led++)
   {
     digitalWrite(led, HIGH);  //turn the LED on (HIGH is the voltage level)
     delay(100);      //100 ms
     digitalWrite(led, LOW);  //turn the LED off by making the volage LOW
     delay(100);      //100 ms
   }
 }
{% endcodeblock %} 

Bạn thấy đó, đoạn code trên rất đơn giản và mang phong cách giống C/C++. Một chương trình như trên được gọi là sketch, sẽ được upload lên bo mạch Arduino qua cổng USB. 

Phân tích chương trình: có 2 method quan trọng nhất là setup() và loop(). 

- setup() làm nhiệm vụ khởi tạo mode cho các ngoại vi của Arduino. Hàm này sẽ được chạy một lần khi bo mạch Arduino được reset. Ở chương trình này, setup() chỉ làm nhiệm vụ đặt các chân 4,5,6,7 của Arduino sang mode output. 

- loop() là chương trình chính của Arduino. Đoạn code trong loop() sẽ được Arduino chạy vô hạn. Trong chương trình này, có hàm digitalWrite() để đặt các chân (pin) ở mức điện áp cao (HIGH) hay thấp (LOW). Hàm tiếp theo là delay(), nhận đối số là một số nguyên, thẻ hiện số mili giây ta muốn chương trình tạm ngưng.

Đó là tất cả về phần code chạy, còn nối dây như thế nào? Dưới đây là sơ đồ nối dây: 

{% img /images/arduino-intro/arduino_led.png %}

Giải thích một chút, đoạn code trên sẽ lần lượt xuất điện áp 5V ra các pin 4,5,6,7 rồi tắt. Để kiểm nghiệm, nối LED với một con trở giữa các pin đó với đất, ta sẽ thấy các đèn LED bật tắt nhịp nhàng :) 

Sau đây là video demo :P 

<iframe width="560" height="315" src="http://www.youtube.com/embed/4EOGnKN2RiE" frameborder="0" allowfullscreen></iframe>

#Kết luận# 

Bài này đã giới thiệu những kiến thức mở đầu về Arduino, cách lập trình trên platform này và demo bài "Hello World" của Arduino. Với cộng đồng chia sẻ rất lớn, nhiều ứng dụng, Arduino rất đáng để học, cũng là một cách để bạn tiếp cận dễ dàng hơn với electronics :D  

#Tham khảo#

1. [http://arduino.cc/en/](http://arduino.cc/en/) 
