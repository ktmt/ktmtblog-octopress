---
layout: post
title: "Các lỗi bảo mật khi xây dựng server login bằng Facebook cho mobile app"
date: 2013-08-02 23:30
comments: true
categories: sercurity, server
---

# Mở đầu
Facebook là mạng xã hội phổ biến nhất hiện nay. Nếu bạn đọc blog này mà không có tài khoản
Facebook, tôi nghi ngờ bạn đến từ Vegeta. Chức năng "Login bằng tài khoản Facebook" là môt trong
những chức năng giúp cho người dùng đăng ký vào hệ thống ứng dụng của bạn một cách nhanh chóng.
Phần lớn các app mobile đếu support chức năng này.

Việc cài đặt hỗ trợ chức năng login bằng Facebook trên server tuy khá đơn giản, nhưng rất dễ xảy
ra lỗi bảo mật, nếu bạn không chú ý. Bài viết này trình bày một vài lỗi cơ bản hay gặp khi
cài đặt trên server cho ứng dụng trên mobile


# Luồng thực hiện để login bằng facebook trên mobile

Các bước được thực hiện khi người dùng bấm vào nút "login bằng facebook" trên một ứng dụng mobile.
Để phần trình bày bên dưới rõ ràng, tôi sẽ gọi ứng dụng mobile là A, và server của ứng dụng này
là server A, ứng dụng trên FB cho app A là FBA

+ Ứng dụng mobile A sẽ chuyển sang gọi ứng dụng Facebook để yêu cầu người dùng các quyền để truy
cập vào tải khoản của người dùng trên FB
+ Sau khi người dùng cho phép ứng dụng mobile A truy cập vào FB, ứng dụng mobile A sẽ gửi request
lên FB server để lấy access token
+ Server FB trả về access token cho ứng dụng mobile A

Sau khi có được access token, ứng dụng mobile có thể làm theo 2 cách

+ **Cách 1**: ứng dụng mobile A sử dụng access token để truy cập vào FB API, lấy thông tin của user
từ FB như user id, username, email. Và gửi những thông tin này lên cho server A. Dựa vào trường
user id hoặc email, server A sẽ tạo mới tài khoản cho user, hoặc merge với một tài khoản có sẵn
ở trong server, rồi trả về thông tin tài khoản cho user.

+ **Cách 2**: ứng dụng mobile A gửi ngay access token nhận được từ FB lên cho server A. Server A
sử dụng access token truy cập vào FB API và check user trình bày ở cách 1.

Cách 1 có ưu điểm hơn so với cách 2 ở chỗ, việc request vào FB API được thực hiện ở phía client
do đó server sẽ giảm được tải đi một phần. Cả server và client đều có khả năng lấy được thông
tin user trên FB bằng access token, vậy thì sử dụng client để lấy thông tin, server có
thể sử dụng tài nguyên để làm việc khác. Hơn nữa nếu để server lấy thông tin user, thời gian để
lấy thông tin sẽ phụ thuộc vào tốc độ mạng giữa server A và FB server.

Mọi lý do đều dẫn đến cách 1 là tốt hơn so với cách 2 về mặt hiệu năng.

Tuy nhiên, nếu xét về khía cạnh bảo mât, cách 1 lại cưc kỳ nguy hiểm. Vì sao vậy

Hãy xét một trường hợp thế này:

+ User B sử dụng app A và dùng chức năng login bằng FB để đăng nhập. App A cài đặt theo cách 1.
Sau khi có access token, app A lấy được FB user id của B là id_B, và email là email_B. App A
gửi những thông tin này lên cho server A. Server A nhận thấy hệ thống chưa có user nào có FB ID
là id_B, nên tạo mới một account cho B, và trả về thông tin của B.
+ Lần tiếp theo user B sử dụng app A để đăng nhập bằng FB, server A sẽ không tạo mới account,
    mà trả về luôn thông tin của account đã tạo ra ở trên
+ Hacker C, bằng cách nào đó biết được URL endpoint của server A phục vụ cho việc đăng nhập bằng FB.
Hacker C, truyền lên một thông tin giả với trường FB ID là id_B. Lúc này server B, chỉ kiểm tra FB
ID của request là id_B, nên sẽ vẫn coi đây là request của user B và trả về thông tin của tài khoản user B.

Vậy là C có thể chiếm bất cứ tài khoản FB nào mà C biết FB id (có tới 1 tỉ tải khoản FB đó, nên C hẳn sẽ có rất nhiều thứ để chiếm đây)

Với cách implement bằng cách 1, server sẽ không thể phân biệt được request nào là request thật của user.
Để chắc chắn server khi nhận được access token, phải request tới FB API để kiểm tra xem access token
truyền lên có phải là của user mà app A truyền lên hay không. Nói cách khác server vẫn cần request tới FB API.
Như vậy việc client gửi request tới FB API để lấy thông tin là cũng không cần thiết.

# Liệu server sử dụng access token để lấy thông tin của user trên FB đã là đủ?
Hãy nói tiếp về cách implement thứ 2. Khi server A nhận access token từ app A.
Server gửi request tới FB API để lấy thông tin của user như FB ID và email. Sau đó tạo mới hoặc merge
với một tài khoản đã có trong hệ thống (trùng FB ID hoặc là trùng email).

Nhưng như thế đã là đủ?

Ta lại xét tiếp một tình huống như sau:

+ Hacker C tạo ra một FB app mới là FBA' và bằng cách nào đó lấy được access token của user B khi B sử dụng FBA'.
+ Hacker C gửi request tới server A sử dụng access token FBA'.
+ Server A dùng FBA' để lấy thông tin, và nhận thấy thông tin đó là của user B, nên server A trả
về thông tin của tài khoản B

Như vây, hacker C lại chiếm được tài khoản của user B trên hệ thống A bằng cách dùng một access token
trên một FB app khác của user B

Để bảo mật, cách duy nhất là khi server A nhận được access token, server A cần gửi request tới FB API
để check xem access token này là từ FB Application nào.

# Tổng kết

Bài viết trình bày 2 lỗi bảo mật hay gặp khi cài đặt hệ thống login bằng facebook trên server cho
ứng dụng mobile. Lỗi thứ nhất là sử dụng client để lấy access token, mà không kiểm tra độ chính xác
của access token. Lỗi thứ hai là chỉ kiểm tra độ chính xác của access token bằng cách thông tin
user, mà không kiểm tra thông tin của app từ access token.

Nếu bạn đã có một hệ thống login bằng FB, hãy check lại nó. Nếu bạn chưa từng cài đặt hệ thống này
thì chúc mừng bạn, bạn đã được cảnh báo !!!
