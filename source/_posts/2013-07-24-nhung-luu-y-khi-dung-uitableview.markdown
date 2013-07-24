---
layout: post
title: "Những lưu ý khi dùng UITableView"
date: 2013-07-24 09:13
comments: true
categories: iOS
---

Ở bài viết trước, tôi đã đề cập đến việc custom 1 UITableViewCell. Tuy nhiên, việc sử dụng UITableView cũng còn khá nhiều điều cần phải quan tâm khác. Trong bài viết này, tôi sẽ đề cập đến những vấn đề ấy:

# Tại sao khi khởi tạo 1 Table View Cell lại phải sử dụng static cho định danh?

Trong quá trình tạo hiển thị, UITableView sẽ lưu lại các cell bị che khỏi màn hình hiển thị (ko phải render) trong 1 stack. Các Cell này sẽ được sử dụng lại khi mà 1 cell mới xuất hiện trên màn hình. Điều này giúp cải thiện tốc độ load table cell và ko làm tăng thêm bộ nhớ cho chương trình. Khi lấy cell trong stack ra, UITableView sẽ sử dụng định danh đã nói ở trên để lấy được các cell cùng kiểu. Có thể hiểu là nó sẽ so sánh bằng định danh này (chứ không phải so sánh string). Vì thế cần phải đặt kiểu biến định danh là static để mỗi lần so sánh sẽ dùng lại biến này chứ ko so sánh với instance mới. Có thể test điều này bằng cách bỏ từ khoá static và đặt debug vào trong phần tạo cell mới. Nếu break luôn luôn vào nghĩa là các cell ko được sử dụng lại => không đúng.

{% img /images/luuYTableView/break_point.png %}

# Cải thiện tốc load của UITableView.

 Không nên sử dụng các hàm vẽ mà phải tính toán nhiều, đặc biệt là các hàm của QuartzCore framework, bởi vì các hàm này thường rất chậm, sẽ làm giảm tốc độ load của các cell.

 Khi sử dụng TableView với các cell phức tạp, mà độ cao của cell phụ thuộc vào các content bên trong nó (VD như các news feeds của Facebook app), để cải thiện tốc độ load các cell này, hãy cùng học tập cách làm của Facebook: Trước hết, khi lấy được danh sách các feed, FB sẽ tính toán sẵn height cho từng cell một và lưu các giá trị này vào database (core data). Sau đó, khi load các cell, height của từng cell sẽ được lấy ra từ database. Điều này làm giảm hiện tượng thắt cổ chai khi mà nếu không tính toán height trước, table view sẽ vừa phải khởi tạo các component vừa phải tính toán chiều cao cho các cell. Đặc biệt là trong trường hợp danh sách các feed được lưu lại trên máy, và lần chạy app tiếp theo sẽ sử dụng lại các feed này => height cho các cell đã được tính toán từ trước.

 Sử dụng multiple thread để giúp app chạy mượt mà hơn, tránh tình trạng bị treo. VD: main thread chỉ điều chỉnh UI và điều khiển các event tương tác với user. Các tác vụ tính toán nên để ở 1 thread khác, vd như các tác vụ network, JSON parsing, tạo và lưu database.

