---
layout: post
title: "Tự tạo UITableViewCell"
date: 2013-07-06 16:44
comments: true
categories: [iOS, iPhone]
---

UITableView là 1 trong những control được sử dụng nhiều nhất trong các ứng dụng iOS. Tuy nhiên, các kiểu cơ bản của UITableViewCell có rất nhiều hạn chế cho người sử dụng bởi vì sự đơn giản của nó. Trong bài viết này, tôi sẽ hướng dẫn các bạn tạo ra tuỳ chỉnh 1 UITableViewCell của riêng mình.

Trong bài viết này, chúng ta sẽ tạo ra 1 Table View Cell đơn giản chứa 1 tiêu đề, 1 button và 1 switcher. Bạn hoàn toàn có thể thay thế các thành phần này theo mục đích riêng của mình.

Trước hết, hãy tạo 1 class mới kế thừa từ UITableViewCell, tạm gọi là CustomTableCell. Tiếp theo, tạo 1 file xib mới đặt tên trùng với 2 file class đã tạo: New -> File -> User Interface -> View

{% img /images/CustomCell/new_xib.png %}

Trên file xib, hãy xoá đi View hiện tại và kéo vào 1 UITableViewCell từ panel bên phải vào:

{% img /images/CustomCell/pull_xib.png %}

Sau đó, hãy kéo các thành phần bạn muốn vào trong view này, trong ví dụ này là 1 UILabel, 1 UIButton, 1 Switch.

Tiếp theo chúng ta phải khai báo class cho file xib này. Bấm vào View và chuyển sang tab Identity inspector của panel bên phải, mục Custom Class đặt tên là CustomTableCell (tên của class chúng ta vừa kế thừa từ UITableViewCell):

{% img /images/CustomCell/class_name.png %}

Mỗi UITableViewCell đều có 1 định danh để có thể sử dụng lại trong 1 TableView. Chúng ta có thể set trường này trong tab Attributes inspector của panel bên phải trong mục Identifier. Đặt 1 id bất kỳ cho trường này, trong ví dụ là "CustomIdentifier":

{% img /images/CustomCell/name_iden.png %}

Vẫn ở tab Identity Inspector này, bấm vào File's Owner ở panel bên trái, mục custom class đặt tên là UIViewController. Điều này có thể hiểu nôm na là chúng ta sẽ khởi tạo CustomTableCell từ 1 UIViewController:

{% img /images/CustomCell/owner_name.png %}

Bước tiếp theo là kéo Outlet cho các thành phần của View. Bấm vào File's Owner rồi chuyển sang tab Connections inspector của pannel bên phải, kéo Outlet View vào Custom Table Cell ở panel bên trái. Điều này giúp kết nối file xib của bạn với class định nghĩa trong file h, m

{% img /images/CustomCell/outlet_view.png %}
Để sử dụng được label, button và switch trên table cell, chúng ta phải khai báo Outlet trong file .h bằng đoạn code:
{% codeblock lang:objc %}
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *nameLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UISwitch *switcher;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *aButton;
{% endcodeblock %}

Sau đó, chuyển sang file xib, bấm vào Custom Table Cell ở panel bên trái, bấm vào Connections Inspector tab ở panel bên phải rồi kéo outlet vào các thành phần của view:

{% img /images/CustomCell/outlet_component.png %}

Vậy là đã xong các bước cài đặt cho Custom Table Cell. Tiếp đến là sử dụng TableCell này như thế nào. Hãy cùng so sánh 2 đoạn code của hàm -(UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath:

{% codeblock lang:objc %}
static NSString *identifier = @"NormalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
{% endcodeblock %}

{% codeblock lang:objc %}
static NSString *identifier = @"CustomIdentifier";
    
    CustomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        UIViewController *tempVC = [[UIViewController alloc] initWithNibName:@"CustomTableCell" bundle:nil];
        cell = (CustomTableCell *)tempVC.view;
    }
return cell;
{% endcodeblock %}

Đoạn code đầu tiên là cách khởi tạo UITableViewCell bình thường. Cách thứ 2 là khởi tạo CustomTableCell. Hãy chú ý là identifier được sử dụng chính là identifier chúng ta đã đặt trong file xib, và biến này phải được để là static. Tại vì sao lại để là static thì tôi sẽ đề cập trong 1 bài viết khác.

Sau khi khởi tạo Cell xong, chúng ta có thể tuỳ chỉnh nó, như trong ví dụ:

{% codeblock lang:objc %}
// Set up cell
    cell.nameLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
    cell.switcher.on = indexPath.row % 2;
{% endcodeblock %}

Vậy là xong. Hãy viết nốt đoạn code cho TableView và đây là kết quả cuối cùng:

{% img /images/CustomCell/final.png 320 480 %}

Toàn bộ code của ví dụ bạn có thể download ở đây https://github.com/toandk/Custom-UITableViewCell
