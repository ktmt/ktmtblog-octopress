---
layout: post
title: "Những lưu ý khi dùng UITableView - Phần 2"
date: 2013-08-05 10:28
comments: true
categories: iOS
---

Như đã giới thiệu ở phần trước, chúng ta có thể làm giảm load của chương trình bằng cách tính toán trước chiều cao của các table cell. Ở phần này, chúng ta sẽ cùng xem chi tiết vấn đề này thông qua 1 ví dụ nhỏ.

Hãy xét 1 tình huống chúng ta có 1 table view để hiện thị 1 danh sách tin tức (có thể lấy từ sv về). Các bản tin này bao gồm ảnh, tiêu đề và nội dung. Phần tiêu đề chỉ hiện thị trên 1 dòng, vì thế chiều cao của bản tin sẽ phụ thuộc vào phần nội dung. Để cho đơn giản, trong ví dụ này, nội dung của tin sẽ được set cứng, lưu vào và lấy ra trong NSUserDefault.

Trước hết, hãy tạo ra 1 custom TableView Cell tương tự như trong bài viết 1. Cell này có 3 thành phần: avatar, nameLabel, contentLabel tương ứng với 3 thành phần của bài viết.

{% img /images/luuYTableView/custom_cell.png %}

Chúng ta khởi tạo cell dựa vào 1 dictionary chứa thông tin của bài viết, thông qua hàm: -(void)setupCellWithDictionary:(NSDictionary *)dictionary

{% codeblock lang:objc %}
    nameLabel.text = dictionary[@"name"];
    contentLabel.text = dictionary[@"content"];
    avatarImg.image = [UIImage imageNamed:dictionary[@"avatar"]];
    
    float contentLabelWidth = 228;
    CGSize constraint = CGSizeMake(contentLabelWidth, 20000.0f);
    CGSize size = [contentLabel.text sizeWithFont:contentLabel.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    contentLabel.frame = CGRectMake(contentLabel.frame.origin.x, contentLabel.frame.origin.y, contentLabel.frame.size.width, size.height);
{% endcodeblock %}

và tính toán chiều cao của cell bằng cách tính chiều cao của contentLabel qua hàm: +(float)heightForCellWithDictionary:(NSDictionary *)dictionary

{% codeblock lang:objc %}
    NSString *content = dictionary[@"content"];
    float contentLabelWidth = 228;
    CGSize constraint = CGSizeMake(contentLabelWidth, 20000.0f);
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + 34 + 10;
{% endcodeblock %}

Vậy là xong cho table cell, tiếp đến sẽ là sử dụng các cell này cho hiệu quả. Trước hết là lấy danh sách các bản tin:

{% codeblock lang:objc %}
    listNews = [[NSUserDefaults standardUserDefaults] objectForKey:@"list_news"];
    [self calculateCellHeights];
    
    [myTableView reloadData];
{% endcodeblock %}

Sau khi lấy được listNews, chúng ta sẽ tính toán luôn height cho từng cell và lưu vào database (ở đây là NSUserDefault) qua hàm calculateCellHeights, và khi lấy ra các height này qua hàm -(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath chúng ta sẽ lấy ra từ database dựa vào Id của cell chứ không phải tính toán lại như thông thường: 

{% codeblock lang:objc %}
    NSString *key = [NSString stringWithFormat:@"cell_%@", cellId];    
    float height = [[NSUserDefaults standardUserDefaults] floatForKey:key];
    return height;
{% endcodeblock %}

Điểm đặc biệt của phương pháp này là các cell height sẽ chỉ phải tính 1 lần cho từng cell_ID, vì thế nếu lần load sau, nếu có cùng dữ liệu thì các height này sẽ không phải tính lại. Nếu bộ dữ liệu lớn, hoặc là các cell này được sử dụng lại nhiều lần, thì phương pháp này sẽ vô cùng hữu hiệu.

Hàm -(void)calculateCellHeights

{% codeblock lang:objc %}
        for (int i=0; i<listNews.count; i++) {
        NSDictionary *cellDict = listNews[i];
        NSString *cellId = cellDict[@"cellId"];
        // Chỉ tính toán cho các cell chưa tồn tại
        if (![self isCellIdExisted:cellId]) {
            NSLog(@"calculate cell height");
            float height = [CustomTableCell heightForCellWithDictionary:cellDict];
            [self saveCellHeight:height forCellId:cellId];
        }
}
{% endcodeblock %}

Lưu ý là trong ví dụ này, các cell height được lưu trong NSUserDefault, bạn hoàn toàn có thể lưu trong database như sqlite hoặc core data với nhiều tính năng hơn. Toàn bộ code của bài viết có thể được download tại đây https://github.com/toandk/NewsFeedExample



