---
layout: post
title: "Trở lại với cơ bản (2): Load Average"
date: 2014-07-20 19:31
comments: true
categories: programming, linux, sysadmin
---

# Giới thiệu

Load Average -- tạm dịch là "giá trị tải trung bình" -- là một chỉ số liên quan đến CPU rất cơ bản và quan trọng. Việc nắm rõ ý nghĩa của chỉ số này giúp chúng ta đánh giá được hiệu năng hiện thời của máy tính cũng như sử dụng CPU nói riêng, máy tính nói chung một cách hiệu quả nhất

Bài viết này bắt đầu bằng việc giải thích ý nghĩa của "giá trị tải trung bình". Sau đó bài viết sẽ trình bày cách đánh giá chỉ số này trong thực tế. Cuối cùng bài viết đưa ra một trường hợp thực tế về cách đánh giá hiệu năng máy tính theo chỉ số này.

# "Tải trung bình" là gì?

## Ví dụ trạm thu phí

Để hiểu *tải trung bình" là gì ta sẽ xem xét một ví dụ thực tế như sau.

Bạn đang tham gia giao thông trên đường cao tốc và trước mặt của bạn là trạm thu phí đường bộ. Bạn giảm tốc để chuẩn bị qua cửa soát vé. Trạm xoát vé có 4 cửa soát vé. Tất cả các cửa đều trống và bạn chọn cửa số 1 như dưới đây.

		H								<-- Xe ôtô của bạn
	|   1   |   2   |   3   |   4   |	<-- Trạm thu phí

Bạn đánh xe đến cửa số 1, trả phí cho nhân viên soát vé. Nhân viên soát vé mở barrier chắn, và bạn đi qua. Có duy nhất xe bạn qua trạm nên từ phía trạm thu phí, *trạm đang phục vụ 1 xe*.

	|   H   |   2   |   3   |   4   |
	
Giờ tưởng tượng có nhiều xe khác cũng lưu thông trên đường cao tốc. Giả sử có trước khi bạn đến trạm thu phí, đang có 2 xe khác làm thủ tục ở cửa số 1 và số 2, bạn chú ý cửa số 3,4 còn trống nên lái xe qua cửa số 3 và làm thủ tục mà không phải chờ đợi. *Trạm phục vụ 3 xe*.

	|   H'   |   H'   |   H   |   4   |

Có thể thấy ở 2 trường hợp trên, trạm thu phí đang làm việc khá *hiệu quả*. Các xe ôtô đi qua với thời gian chờ đợi bằng 0. Các xe ôtô đi qua trạm xoát vé một cách nhanh chóng. Người lái xe là bạn cảm thấy thoải mái vì không phải chờ đợi.

Giả sử hôm nay là ngày nghỉ lễ, mọi người về quê đông nên xe khách chạy rất đông. Các gia đình tranh thủ ngày lễ nên cũng đánh xe đi chơi xa. Đường cao tốc trở nên đông đúc. Bạn đến trạm thu phí và nhận ra rằng 4 cửa đang có xe làm thủ tục. Chưa kể bạn còn đến sau 2 xe khác và phải đợi xếp hàng sau 2 xe này.

		H									<-- Xe ôtô của bạn
		H'
		H'
	|   H'   |   H'   |   H'   |   H'   |	<-- Trạm thu phí

Trong trường hợp này, bạn chắc chắn sẽ phải chờ, không những chờ các xe đang làm thủ tục tại cửa trạm mà còn chờ cả các xe đến trước bạn. Thời gian có thể bị kéo dài vì nhiều lý do như 1 xe làm thủ tục mất thời gian hơn các xe khác hoặc có sự cố ở cửa soát vé. Đứng từ góc độ của trạm thu phí, trạm đang phải xử lý số lượng xe (7 xe) nhiều hơn khả năng của trạm (4 cửa). Tại thời điểm hiện tại, trạm đang bị *quá tải*.

Ta định nghĩa số lượng tải trung bình của trạm là số lượng xe mà trạm phải phục vụ trong một đơn vị thời gian. Như vậy ở ví dụ trên *trung bình tải* của trạm thu phí tại thời điểm bạn đến là 7.

## Load Average của CPU

Tương tự như ví dụ trạm soát vé, "Load Average" của CPU được định nghĩa là số lượng process cần tài nguyên tính toán của CPU tại thời điểm nhất định. Giả sử tải trung bình của máy tính bạn hiện tại là 3.2, điều đó có nghĩa là tại thời điểm đó đang có trung bình 3.2 processes cần  CPU xử lý. Tại thời điểm process cần CPU, nếu CPU đang rảnh process sẽ được OS cho chạy trên CPU rảnh. 

Mổi "cửa soát vé" trong CPU máy tính sẽ là 1 lõi CPU. Với các CPU thế hệ mới trang bị công nghệ Hyperthreading, mỗi lõi vật lý có thể hoạt động được như 2 lõi logic. Vì vậy OS sẽ nhận diện 8 lõi. Ví dụ máy tính của bạn được trang bị chip mới nhất hiện tại Corei7 MQ-- 4 cores 8 threads với công nghệ Hyperthreading thì đối với hệ điều hành máy tính của bạn có 8 cores.

Để kiểm tra máy tính của bạn có bao nhiêu lõi (cores), trên windows bạn có thể kiểm tra qua TaskManager > Performance. Bên cạnh biểu đồ tỉ lệ sử dụng CPU nói chung là tỉ lệ sử dụng CPU của từng lõi. Số lượng cửa sổ bên tay phải là số lượng lõi logic.

Trên Linux bạn có thể kiểm tra bằng nhiều cách:

	$ top
	# ấn 1
	top - 20:38:48 up 2 days,  4:50,  1 user,  load average: 11.30, 11.54, 10.17
	Tasks: 430 total,   2 running, 428 sleeping,   0 stopped,   0 zombie
	Cpu0  : 20.5%us,  2.4%sy,  0.0%ni, 76.2%id,  0.4%wa,  0.0%hi,  0.5%si,  0.0%st
	Cpu1  : 20.2%us,  1.9%sy,  0.0%ni, 77.4%id,  0.5%wa,  0.0%hi,  0.1%si,  0.0%st
	Cpu2  : 19.9%us,  1.8%sy,  0.0%ni, 77.7%id,  0.5%wa,  0.0%hi,  0.1%si,  0.0%st
	Cpu3  : 19.9%us,  2.3%sy,  0.0%ni, 77.2%id,  0.2%wa,  0.0%hi,  0.4%si,  0.0%st
	Cpu4  : 19.8%us,  2.3%sy,  0.0%ni, 77.1%id,  0.4%wa,  0.0%hi,  0.4%si,  0.0%st
	Cpu5  : 19.7%us,  2.3%sy,  0.0%ni, 77.4%id,  0.2%wa,  0.0%hi,  0.4%si,  0.0%st
	Cpu6  : 20.1%us,  1.6%sy,  0.0%ni, 78.1%id,  0.1%wa,  0.0%hi,  0.0%si,  0.0%st
	Cpu7  : 19.6%us,  2.2%sy,  0.0%ni, 77.7%id,  0.1%wa,  0.0%hi,  0.3%si,  0.0%st
	Cpu8  : 19.4%us,  2.2%sy,  0.0%ni, 78.0%id,  0.1%wa,  0.0%hi,  0.3%si,  0.0%st
	Cpu9  : 19.8%us,  2.2%sy,  0.0%ni, 77.6%id,  0.1%wa,  0.0%hi,  0.3%si,  0.0%st
	Cpu10 : 19.5%us,  1.6%sy,  0.0%ni, 78.8%id,  0.1%wa,  0.0%hi,  0.0%si,  0.0%st
	Cpu11 : 19.9%us,  2.2%sy,  0.0%ni, 77.5%id,  0.1%wa,  0.0%hi,  0.3%si,  0.0%st
	Mem:  32846220k total, 32593588k used,   252632k free,   434464k buffers
	Swap:  4194296k total,        0k used,  4194296k free, 22380012k cached

	PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
	14489 hadoop    20   0 1643m 684m  16m S 104.7  2.1  32:15.93 java
	14496 hadoop    20   0 1635m 705m  16m S 104.7  2.2  32:14.63 java
	16194 hadoop    20   0 1637m 655m  16m S 104.7  2.0  29:45.06 java
	16243 hadoop    20   0 1630m 687m  16m S 104.7  2.1  29:28.34 java

hoặc

	$ mpstat -P ALL
	Linux 2.6.32-358.11.1.el6.x86_64 (bb2-dn07)     07/20/2014      _x86_64_        (12 CPU)
	
	08:39:53 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
	08:39:53 PM  all   19.88    0.00    2.09    0.23    0.00    0.27    0.00    0.00   77.53
	08:39:53 PM    0   20.52    0.00    2.38    0.42    0.00    0.46    0.00    0.00   76.21
	08:39:53 PM    1   20.19    0.00    1.85    0.51    0.00    0.11    0.00    0.00   77.35
	08:39:53 PM    2   19.95    0.00    1.81    0.48    0.00    0.11    0.00    0.00   77.65
	08:39:53 PM    3   19.92    0.00    2.33    0.20    0.00    0.38    0.00    0.00   77.16
	08:39:53 PM    4   19.82    0.00    2.28    0.39    0.00    0.45    0.00    0.00   77.07
	08:39:53 PM    5   19.74    0.00    2.33    0.19    0.00    0.38    0.00    0.00   77.36
	08:39:53 PM    6   20.14    0.00    1.64    0.13    0.00    0.01    0.00    0.00   78.09
	08:39:53 PM    7   19.65    0.00    2.19    0.13    0.00    0.35    0.00    0.00   77.69
	08:39:53 PM    8   19.38    0.00    2.20    0.11    0.00    0.34    0.00    0.00   77.97
	08:39:53 PM    9   19.78    0.00    2.23    0.07    0.00    0.35    0.00    0.00   77.57
	08:39:53 PM   10   19.53    0.00    1.59    0.11    0.00    0.01    0.00    0.00   78.76
	08:39:53 PM   11   19.93    0.00    2.21    0.07    0.00    0.34    0.00    0.00   77.45

hoặc

	$　cat /proc/cpuinfo
	.....
	
# Hiểu và đánh giá "tải trung bình" như thế nào?

Bên cạnh chỉ số tận dụng CPU bạn có thêm 1 chỉ số nữa gọi là "tải trung bình". Bạn nên hiểu 2 giá trị này thế nào?

Tỉ lệ tận dụng CPU nói rằng một process sử dụng CPU nhiều hay ít. Giả sử bạn có một tính toán khá lớn (ví dụ sắp xếp 10GB dữ liệu), phần lớn thời gian của CPU của bạn chắc chắn sẽ bận rộn so sánh và di chuyển dữ liệu. Phần trăm sử dụng CPU sẽ cao, thời gian rảnh (idle) của CPU chắc sẽ thấp.

Tải trung bình nói rằng số lượng process đang đợi CPU là lớn hay nhỏ. Nếu số lượng process đợi CPU lớn, thời gian một process đợi sẽ dài, thời gian hoàn thành tác vụ của process đó sẽ dài. Bạn sẽ phải chờ kết quả lâu hơn. Ngược lại nếu số lượng process đợi thấp, bạn sẽ không phải đợi các process khác. Thời gian bạn đợi kết quả sẽ chỉ là thời gian tính toán.

Làm thế nào để biết được số lượng process đang đợi CPU là lớn hay nhỏ? Giống như trường hợp trạm thu phí, nếu số lượng process lớn hơn số lượng lõi CPU, chắc chắn sẽ phải có process đợi. Ngược lại nếu số lượng process nhỏ hơn số lượng lõi CPU, các process hầu như sẽ không phải xếp hàng chờ đợi mà sẽ được OS gán cho lõi đang rảnh rỗi tính toán.

Từ đây đặt ra câu hỏi: "đánh giá hiệu năng máy tính dựa vào tỉ lệ sử dụng CPU và tải trung bình như thế nào?". 

Việc đánh giá hiệu năng CPU tùy thuộc vào từng bài toán cụ thể. Ta sẽ đánh giá về hiệu năng sử dụng CPU qua các trường hợp sau (giả sử máy tính có 6 cores 12 threads - ví dụ Intel Xeon):

- Tỉ lệ sử dụng CPU thấp (1%), tải CPU thấp (3 - 3 processes / 12 cores)
- Tỉ lệ sử dụng CPU cao (80%), tải CPU thấp (3 - 3 processes / 12 cores)
- Tỉ lệ sử dụng CPU thấp (1%), tải CPU cao (18 - 18 processes / 12 cores)
- Tỉ lệ sử dụng CPU cao (80%), tải CPU cao (18 - 18 processes / 12 cores)

Trong trường hợp đầu, máy tính của bạn hầu như không dùng CPU mấy. CPU dành hầu hết thời gian cho tính toán thấp, số lượng process cũng không cao. Đứng từ góc độ chi phí, bạn đã chi tiền mua 1 CPu quá tốt so với nhu cầu thực tế :-)

Trường hợp 2, bạn đang sử dụng CPU ở mức khá. Bạn bắt CPU tính toán cật lực. Tuy vậy tải trung bình của CPU chỉ có 3, có nghĩa là năng lực CPU của bạn vẫn còn rất lớn mà bạn hoàn toàn có thể tận dụng. Bạn hoàn toán có thể bật thêm 9 processes với mức tính toán như hiện tại mới có thể tận dụng được hết hiệu năng của CPU.

Trường hợp 3 khá lý thú. CPU của bạn được dùng cho những tính toán rất nhẹ nhàng có thể xong ngay lập tức nhưng số lượng process cần CPU lại khá cao. Điều này nói lên rằng CPU của bạn đang bị quá tải process. Có nhiều lý do dẫn đến trường hợp này và mỗi trường hợp có nhiều cách giải quyết khác nhau. Một ví dụ cho trường hợp này là máy chủ web. Việc render các trang web là tính toán không hề nặng, tuy vậy với các máy chủ web chịu trafic lớn (số lượng connection lớn), các process phục vụ request sẽ phải xếp hàng dẫn đến tình trạng trang web bị phục vụ thời gian kéo dài hơn. Một ví dụ khác là máy chủ dành thời gian chủ yếu đợi thao tác vào ra (I/O) chẳng hạn nhưng truy vấn cơ sở dữ liệu. Số lượng query lớn, số lượng truy vấn cần sắp xếp lớn nhưng dữ liệu cần sắp xếp lại bé, thời gian đợi dữ liệu từ đĩa cứng lại cao. Vì vậy phần lớn CPU sẽ idle, nhưng tải CPU vẫn cao. Đối với trường hợp này, ta chỉ có cách là mua CPU với tần số thấp hơn và chia tải ra nhiều máy hơn để tối ưu hóa chi phí.

Trường hợp 4 là trường hợp bạn đang sử dụng CPU một cách hiệu quả nhất. Mỗi cores đều bận rộn tính toán và hầu hết các cores đều được cho sử dụng. Tùy bài toán tính toán mà trường hợp này có thể là tốt hay xấu. Nếu đây là máy chủ web có lẽ đã đến lúc bạn mua thêm máy tính.


# Trường hợp thực tế.

Hiểu được ý nghĩa của tải trung bình, chúng ta hiểu rằng sử dụng CPU hiệu quả có nghĩa là phải overload CPU. Một máy tính với CPU được sử dụng hết công suất suất là một máy tính được sử dụng tốt. Nắm được cách sử dụng vũ khí tải trung bình, chúng ta sẽ thử áp dụng cho 2 trường hợp thực tế. 

### Cấu hình máy chủ web 1
Bạn có máy tính chuyên trả về file static (css, image, js). Bạn sử dụng nginx và cấu hình để nginx trả về dữ liệu trong một thư mục nhất định. Bạn sẽ cấu hình nginx với bao nhiêu workers.

Trả lời: 12! Nếu bạn cấu hình ít hơn 12 workers, khả năng cao là CPU của máy tính bạn đang không được sử dụng hết công suất. Tại một thời điểm nào đó sẽ có một vì cores rong chơi.

### Cấu hình máy chủ web 2
Giả sử bạn có máy chủ web 12 cores (logic :-)) và load average hiện tại là 5. Liệu đã đến lúc bạn mua thêm máy chủ mới chưa?

Trả lời: Không biết :-). Nếu máy chủ của bạn dành phần lớn thời gian idle đợi dữ liệu từ đĩa cứng hoặc cơ sở dữ liệu, nút thắt cổ chai hệ thống của bạn không phải là CPU mà có thể là cơ sở dữ liệu hoặc là đĩa cứng (thao tác I/O). Nếu cơ sở dữ liệu của bạn chưa hết công suất (I/O chưa hết công suất), bạn hoàn toàn không cần mua thêm máy chủ web. Bạn có thể cầu hình lại nginx / gunicorn...) để load average cao hơn (không quá 12 - số lượng cores) nhằm tận dụng hết năng lực của CPU của máy tính hiện tại).

### Cầu hình hadoop
hadoop nổi tiếng trong giới BigData. Một datanode chạy các thủ tục map / reduce viết bằng java để lấy 1 block dữ liệu từ ổ cứng; chạy thao tác map để trích xuất dữ liệu; chạy thao tác reduce để tổng hợp dữ liệu. Một datanode thực hiện rất nhiều truy vấn dữ liệu từ ổ cúng cũng như sử dụng rất nhiều cpu cho thao tác sắp xếp, tổng hợp dữ liệu. Với 1 máy tính 12 cores, bạn sẽ cấu hình bao nhiêu java process cho thao tác map/reduce?

Trả lời: Không biết :-) nhưng chắc chắn là lớn hơn 12. Bạn sẽ bất ngờ vì thấy câu trả lời hơi khác máy chủ web dù rằng bài toán có vẻ giống nhau! Lý do là: mô hình map/reduce của hadoop cần rất nhiều dữ liệu do vậy truy vấn đĩa cứng sẽ rất cao, thao tác I/O lớn. Dù thao tác sắp xếp dữ liệu cũng khá tốn CPU nhưng để có dữ liệu sắp xếp, 1 map process vẫn cần thời gian để chờ dữ liệu từ ổ cúng. Trong khoảng thời gian này CPU sẽ idle. Nếu bạn chỉ cấu hình số lượng map/reduce là 12 (bằng số lượng cores), sẽ có 1 khoảng thời gian mà các cores không làm việc vì phải chờ đĩa cứng. Vì vậy CPU thực chất sẽ có những lúc rất bận và những lúc rất rảnh. Để hạn chế thời gian rảnh của CPU, "best-practice" sẽ là overload CPU bằng cách cấu hình cho số lượng process lớn hơn số cores. Tỉ lệ được khuyến cáo là 1.5 lần. Nhờ vậy trong khi có những process đợi I/O, CPU sẽ bận rộn với các process trước đó.

**Cấu hình cụ thể là bài toán tùy trường hợp. Bạn nên xem bản chất bài toán và hành vi của máy chủ trước khi cấu hình**

# Kết luận

Bài viết đã giải thích ý nghĩa của load-average, một chỉ số quan trọng cũng như giới thiệu một số trường hợp cấu hình thực tế liên quan đến load-average. Hy vọng qua bài viết này, bạn hiểu được ý nghĩa của load-average, áp dụng vào thực tiễn công việc sử dụng máy tính hiệu quả nhất với chi phí tốt nhất.

# Câu hỏi phụ :-)

Một câu hỏi phỏng vấn vị trí SRE của Google:

> Lệnh uptime trả về 3 kết quả Load Average. 3 con số này là gì? 

# Tài liệu tham khảo

1. [hadoop operations][]
2. [Computer Architecture, A Quantitative Approach][]
3. [http://nginx.org/en/docs/][]

[Computer Architecture, A Quantitative Approach]: http://www.amazon.com/Computer-Architecture-Quantitative-Approach-Edition/dp/0123704901
[hadoop operations]: http://shop.oreilly.com/product/0636920025085.do
[http://nginx.org/en/docs/]: http://nginx.org/en/docs/


