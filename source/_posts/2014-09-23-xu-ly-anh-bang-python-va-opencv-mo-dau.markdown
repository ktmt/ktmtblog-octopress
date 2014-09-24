---
layout: post
title: "Xử lý ảnh bằng Python và OpenCV: Mở đầu"
date: 2014-09-23 19:04
comments: true
categories: computer vision, image processing, python, opencv
---

Do công việc, tôi đã có một thời gian tìm hiểu về OpenCV để xử lý ảnh và video. Phần lớn các tác vụ tôi thực hiện là code OpenCV trên C++ và giao tiếp với Android qua JNI.  Và rồi tôi nhận ra mình chỉ làm theo những tutorial có sẵn trên mạng và mất nhiều thời gian hơn mức cần thiết để fix bug của compiler hoặc IDE. Bản thân tôi rất có hứng thú với Computer Vision và Image Processing nói chung, nhưng cách tiếp cận như trên có vẻ như quá chậm. Sẽ tốt hơn nếu có thể tập trung nắm được những khái niệm cơ bản cùa Computer Vision trước, không bị sa đà vào việc fix bug. Bản thân việc nhanh chóng tạo ra những ứng dụng hữu ích là một động lực không nhỏ đối với việc tiếp tục học Computer Vision and Image Processing.

Đó là lý do tôi chuyển sang lập trình OpenCV với Python. Việc cài đặt, viết code, thử nghiệm đều trở nên đơn giản hơn rất nhiều.

Thêm một lý do nữa, phải nói là Computer Vision và Image Processing là những lĩnh vực khó nếu xét về khía cạnh nghiên cứu, với rất nhiều công thức toán. Tôi không nói những công thức toán đó là không cần thiết, mà là đối với người bắt đầu học, sẽ tốt hơn nếu nhanh chóng nắm được tất cả những kĩ thuật cơ bản và bắt đầu áp dụng xây dựng ứng dụng hữu ích cho mình. Sau đó, tuỳ theo nhu cầu và sở thích, có thể tiếp tục đào sâu nghiên cứu, tối ưu, chạy thời gian thực... Kể cả lúc đó, khi đã có kiến thức cơ bản rồi, việc tiếp cận sẽ càng nhanh hơn.

Xin lỗi vì phần giới thiệu hơi dài dòng :P Tôi xin bắt đầu luôn. Trong bài đầu tiên này, tôi sẽ trình bày cách cài đặt môi trường và một số tác vụ cơ bản khi làm việc với OpenCV trên Python. Bài viết này có thể sẽ khá cơ bản với một số độc giả, nhưng vì là bài đầu tiên trong loạt bài này, tôi vấn muốn trình bày để đảm bảo sự đầy đủ. Trong các bài sau, chúng ta sẽ cùng xây dựng những ứng dụng thú vị hơn.

# Cài đặt môi trường
Có những thành phần sau cần phải cài đặt để làm việc với OpenCV trên :
* Python 2.7
* NumPy và SciPy: Bằng cách sử dụng NumPy, chúng ta có thể biểu thị hình ảnh bằng mảng đa chiều. Ngoài ra, có rất nhiều thư viện xử lý ảnh và cả machine learning sử dụng cách biểu thị mảng của NumPy. NumPy cũng hỗ trợ rất nhiều hàm toán học  chúng ta có thể thực hiện nhiều phân tích có ý nghĩa hơn trên ảnh. Bên cạnh NumPy còn có SciPy đi kèm, hỗ trợ thêm về các tính toán khoa học.

Trên Windows, cách dễ nhất để có cả Python, NumPy và SciPy là cài đặt Enthought Canopy tại [https://www.enthought.com/products/canopy/](https://www.enthought.com/products/canopy/)

Trên Mac từ 10.7 trở lên, NumPy và SciPy đã được cài đặt sẵn.
* Matplotlib: là thư viện để plot. Khi xử lý ảnh, chúng ta sẽ sử dụng thư viện này để xem histogram của ảnh hoặc xem chính ảnh đó.
* OpenCV: Về hướng dẫn cài đặt chi tiết, bạn có thể xem tại [đây](http://docs.opencv.org/doc/tutorials/introduction/table_of_content_introduction/table_of_content_introduction.html)

# Mở và lưu file ảnh
Hãy bắt đầu bằng tác vụ đơn giản nhất: mở một file ảnh thành một mảng NumPy, đọc các thông tin về kích cỡ, sau đó lưu mảng NumPy thành một file ảnh mới.

{% codeblock getinfo.py %}
import argparse
import cv2

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required = True,
                help = "Path to the image")
args = vars(ap.parse_args())

image = cv2.imread(args["image"])
print "width: %d pixels" % (image.shape[1])
print "height: %d pixels" % (image.shape[0])
print "channels: %d channels" % (image.shape[2])

cv2.imshow("Image", image)
cv2.imwrite("new.jpg", image)
cv2.waitKey(0)
{% endcodeblock %}

Đầu tiên, chúng ta import hai package cần thiết là `argparse` và `cv2`. `argparse` dùng để khai báo những parameter cần thiết cho chương trình của chúng ta, ở đây, chúng ta khai báo parameter là đường dẫn đến file ảnh ban đầu.
Để đọc file ảnh thành một mảng NumPy, chúng ta sử dụng hàm `cv2.imread()` với parameter là tên file ảnh (đã được nhập vào từ command line). Sau bước này, ta nhận được một mảng NumPy là `image`. Tiếp theo ta in ra các thông số về file ảnh, gồm có chiều dài, chiều rộng và số channel. Ở đây, chúng ta có những điểm lưu ý về cách NumPy lưu các thông số về bức ảnh:
* Một bưc ảnh có 2 chiều X và Y, gốc toạ độ tại pixel trên cùng bên trái của bức ảnh. Chiều X từ trái sang phải và chiều Y từ trên xuống dưới. NumPy lưu số pixel hơi ngược: `image.shape[0]` là số pixel theo chiều Y và `image.shape[1]` là số pixel theo chiều X.
* Mỗi pixel trên bức ảnh được biểu thị dưới một trong 2 dạng: grayscale hoặc color. `image.shape[2]` lưu số channel biểu thị mỗi pixel. Với ảnh màu hiển thị trên RGB, số channel là 3, còn với ảnh đen trắng (grayscale), chúng ta chỉ có 1 channel duy nhất

Để hiển thị bức ảnh trên một window mới, ta sử dụng hàm `cv2.imshow()`, với 2 đối số là tên của window và tên của mảng NumPy muốn hiển thị.

Để lưu mảng NumPy thành một file ảnh mới, ta sử dụng hàm `cv2.imwrite()`, với 2 đối số là tên của file muốn lưu và tên của mảng NumPy. Trong ví dụ này, chúng ta lưu file mới giống hệt file cũ mà không có chỉnh sửa gì.

Chạy đoạn code trên như sau:
```
% python getinfo.py -i obama_fun.jpg
```

Ảnh gốc:

 {% img /images/pythonopencv/original.gif %}
Kết quả trả về
```
width: 475 pixels
height: 356 pixels
channels: 3 channels
```

## Tạo ảnh avatar bằng kĩ thuật mask
Trong phần này, chúng ta sẽ tạo ra ảnh avatar từ một bức hình chân dung ban đầu, theo dạng như avatar picture của Google+: hình tròn bao quanh khuôn mặt. Đoạn code như sau:

{% codeblock create_avatar_circle.py %}
import numpy as np
import argparse
import cv2

ap = argparse.ArgumentParser()
ap.add_argument("-i", "--image", required = True,
                help = "Path to the image")
args = vars(ap.parse_args())

image = cv2.imread(args["image"])
cv2.imshow("Original", image)

(cX, cY) = (image.shape[1] / 2 , image.shape[0]/2)
radius = 120
mask = np.zeros(image.shape[:2], dtype = "uint8")
cv2.circle(mask, (cX, cY), radius, 255, -1)
masked = cv2.bitwise_and(image, image, mask = mask)
avatar = masked[ cY - radius : cY + radius, cX - radius : cX + radius]
cv2.imshow("Mask", mask)
cv2.imshow("Avatar", avatar)
cv2.imwrite("avatar.jpg", avatar)
cv2.waitKey(0)

{% endcodeblock %}
Đoạn code bắt đầu với các thủ tục như import packages cần thiết, khai báo các parameters đầu vào cho script, đọc file ảnh vào mảng NumPy như phần trên.

Để crop một phần bức ảnh, chúng ta cần tạo ra một mặt nạ `mask`, là một mảng có kích thước như bức ảnh với tất cả giá trị pixel được khởi tạo bằng 0. Tiếp đó, ta vẽ một hình tròn trắng trên mảng 'mask' . Sau đó, sử dụng `bitwise_and()` hai mảng `image` với nhau, có thêm tham số mặt nạ `mask`, ta được một bức ảnh `masked` chỉ có phần khuôn mặt. Tiếp tục crop bằng cách slice mảng NumPy, chúng ta được kết quả cuối cùng là bức ảnh `avatar`.

Chạy đoạn code trên như sau:
```
% python create_avatar_circle.py -i obama_fun.jpg
```
Kết quả:

- Bức ảnh ban đầu

 {% img /images/pythonopencv/original.gif %}

- `mask`

{% img /images/pythonopencv/mask.gif %}

- `avatar`

{% img /images/pythonopencv/avatar.gif %}

Tất nhiên, tôi đã sử dụng file ảnh có mặt tổng thống Obama ở ngay giữa tấm ảnh và mask được đặt ở chính giữa tâm bức ảnh. Không phải mọi tấm ảnh đều như vậy; trong trường hợp đó chúng ta sẽ sử dụng kĩ thuật face detection. Nhưng đó là chủ đề của một bài viết sau.

## Kết luận
Qua bài viết này, tôi đã giới thiệu những bước bắt đầu để làm việc với OpenCV qua Python. Bài viết khá cơ bản, nhưng đã trình bày một số khái niệm cơ bản để chuẩn bị cho những ứng dụng lần sau. Hẹn gặp lại các bạn trong các phần tiếp theo.

# Tài liệu tham khảo
1. [OpenCV-Python Tutorials](http://opencv-python-tutroals.readthedocs.org/en/latest/index.html)

