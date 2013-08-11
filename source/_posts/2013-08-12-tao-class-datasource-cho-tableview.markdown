---
layout: post
title: "Tạo class DataSource cho TableView"
date: 2013-08-12 00:11
comments: true
categories:
---

# Mở đầu
Để tiếp nối chuỗi bài về TableView, hôm nay mình cũng viết một bài liên quan đến TableView. Trong iOS TableView là class được dùng khá nhiều.
Khi dùng TableView chúng ta thường phải set datasource và delegate cho TableView. Thường thì datasource của TableView là một array.

Khá nhiều bạn thường set datasource cho Tableview ngay trong ViewController (`tableview.datasource = self`). Và khi đấy trong ViewController chúng ta luôn luôn phải implement delegate cho TableViewDataSource như sau:

{% codeblock  TmpViewController.m %}
#pragma mark - UITableViewDataSource delegate
- (NSInteger)tableView:(UITalbeView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *cellIdentifier = @"MyCell";
  // lấy cell có sẵn
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  // nếu không có cell có sẵn thì tạo cell mới
  if(cell == nil) {
    cell = [UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:cellIdentifier];
  }

  // lấy dữ liệu cho cell hiện tại. (Ví dụ dữ liệu là NSString)
  NSString *item = [self.dataArray objectAtIndex:indexPath.row];
  // gán dữ liệu cho cell
  [cell.textLabel setText:item];

  return cell;
}
{% endcodeblock %}

Việc viết như trên đối với những ứng dụng nhỏ thì không vấn đề gì nhưng khi ứng dụng sử dụng nhiều tableview thì trong từng ViewController chúng ta luôn phải viết đi viết lại đoạn code trên. Nếu nhìn kỹ đoạn code trên bạn sẽ thấy thực ra với mỗi TableView khác nhau chúng ta chỉ cần thay đổi phần `#gán dữ liệu cho cell` tuỳ theo cấu trúc của từng cell. Còn đâu những phần còn lại chúng ta có thể sử dụng lại code. Ngoài ra nếu chúng ta để những đoạn code này trong ViewController sẽ khiến ViewController trở nên dài hơn bởi vì bản thân ViewController đã chứa rất nhiều code như delegate, code xử lý sự kiện, gesture. Vì vậy để có một ViewController ngắn gọn hơn, dễ hiểu hơn, lại tăng tính sử dụng lại code chúng ta sẽ tạo 1 class datasource riêng tên là TVArrayDataSource.

# Tạo class TVArrayDataSource
Vậy chúng ta sẽ chuyển hết code ở trên sang class TVArrayDataSource và trong các ViewController chúng ta chỉ cần viết phần `#gán dữ liệu cho cell` tuỳ theo cấu trúc của cell. Vậy trong TVArrayDataSource cần những property gì?

Đầu tiên là `NSArray *items` trỏ đến array data của chúng ta trong ViewController để chúng ta có thể lấy data tương ứng cho từng cell và cell identifier `NSString *cellIdentifier` là string dùng để định danh cell.

{% codeblock TVArrayDatasource.m %}
@interface TVArrayDataSource()

@property (strong, nonatomic) NSArray *items;
@property (copy, nonatomic) NSString *cellIdentifier;

@end

@implementation TVArrayDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.items count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // tìm cell có sẵn
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    // tạo cell mới nếu không tìm thấy
    if (cell == nil) {
      ...
    }

    // lấy data cho cell
    id item = [self.items objectAtIndex:indexPath.row];

    // gán dữ liệu cho cell
    ...

    return cell;
}

@end
{% endcodeblock %}

Đầu tiên chúng ta sẽ nói về đoạn `...` tại phần gán dữ liệu cho cell. Tại vì tuỳ từng trường hợp của tableview mà cell của chúng ta có cấu trúc khác nhau, data source có cấu trúc khác nhau nên phần gán dữ liệu này là khác nhau. Do đó tại đây chúng ta có thể gọi đến các hàm callback trong ViewController để gán dữ liệu cho cell theo cách mà chúng ta muốn. Có nhiều cách như dùng block, selector hay delegate. Mình thì thấy tiện nhất và ngắn nhất là block và selector nên mình sẽ tạo class TVArrayDataSource có thể dùng block hoặc selector.

Với block thì chúng ta cần tạo 1 property để lưu block và execute block tại đoạn gán dữ liệu. Chúng ta sẽ thêm block property vào TVArrayDataSource.m và tạo 1 method khởi tạo dataSource với block như sau:

{% codeblock TVArrayDataSource.m %}
typedef void (^TVCellConfigureBlock)(id, id);

@interface TVArrayDataSource : NSObject <UITableViewDataSource>

/* khởi tạo datasource với block */
- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
 cellConfigureBlock:(TVCellConfigureBlock) configureBlock;

{% endcodeblock %}

{% codeblock TVArrayDataSource.m %}
...
// thêm block property vào
@property (copy, nonatomic) TVCellConfigureBlock configureBlock;

// và method khởi tạo chỉ đơn giản như sau
- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
 cellConfigureBlock:(TVCellConfigureBlock)configureBlock
{
    self = [super init];
    if(self) {
        self.items = items;
        self.cellIdentifier = cellIdentifier;
        self.configureBlock = configureBlock;
    }
    return self;
}

// và chúng ta thêm phần execute block tại đoạn gán dữ liệu cho cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // tìm cell có sẵn
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    // tạo cell mới nếu không tìm thấy
    if (cell == nil) {
      ...
    }

    // lấy data cho cell
    id item = [self.items objectAtIndex:indexPath.row];

    // execute block để gán dữ liệu cho cell
    self.configureBlock(cell, item);

    return cell;
}

{% endcodeblock %}

Khi đó bên ViewController chúng ta chỉ cần tạo 1 block để thực hiện việc gán dữ liệu cho cell. Và block này sẽ được execute bằng `self.configureBlock(cell, item)` với tham số là cell hiện tại và data tương ứng của cell. Bởi vì tham số của block là cell hiện tại và data cho cell đấy nênchúng ta hoàn toàn có thể tự do tuỳ chỉnh cell theo ý muốn. Và code bên ViewController sẽ rất ngắn và đẹp như sau:

{% codeblock ViewController1.m %}
// configure block. Kiểu tham số có thể tuỳ chỉnh theo kiểu data bất kỳ của bạn.
TVCellConfigureBlock configureCell = ^(CellClassName *cell, DataType *name) {
  // gán dữ liệu cho cell. ví dụ như sau:
  [cell.title setText:name];
};
// tạo instance dataSource của TVArrayDataSource và khởi tạo với block ở trên
dataSource = [[TVArrayDataSource alloc] initWithItems:items
                                       cellIdentifier:@"MYCELL"
                                   cellConfigureBlock:configureCell];
tableView.datasource = dataSource;
{% endcodeblock %}

Bạn thấy đấy giờ trong ViewController thì phần code cho dataSource của tableView khá là đẹp.
Đôi khi bạn muốn viết đoạn gán dữ liệu cho cell vào một method khác trong class ViewController thay vì dùng block. Để cho những trường hợp đó như đã nói ở trên chúng ta có thể dùng selector. Tương tự như block chúng ta cũng sẽ tạo một `@property (assign, nonatomic) SEL configureSelector;` và đối tượng để execute method của selector này `@property (weak, nonatomic) id target;` (Đối tượng này chính là ViewController). Chúng ta cũng cần tạo một hàm khởi tạo datasource khác với selector. Cuối cùng trong phần gán dữ liệu cho cell chúng ta execute method của selector với `objc_msgSend(self.target, self.configureSelector, cell, item);`. Do phần này tương tự như đối với block  nên mình không giải thích thêm mà các bạn có thể xem code trên github.

Tiếp theo còn một đoạn `...` tại phần tạo cell mới khi mà không tìm thấy cell có thể dùng lại. Như bạn thấy đấy để tạo cell mới chúng ta cần biết Class của cell. Với Objective-C chúng ta có thể tạo 1 instance từ tên class. Khi đó chúng ta có thể tạo 1 cell như sau:

`
cell = [[NSClassFromString(CELL_CLASS_NAME) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
`

Như vậy class TVArrayDataSource chỉ cần có thêm thông tin là tên class của cell là mọi việc có thể hoàn tất. Ngoài ra nhiều khi chúng ta muốn tạo cell từ file Xib. Để tạo cell từ file xib chúng ta cũng chỉ cần biết thêm tên file xib. Thế nên mình tạo thêm một property `cellName` để lưu tên class của cell hoặc tên file Xib tuỳ theo trường hợp cell tạo từ file xib hay từ code.
Như vậy việc tạo class TVArrayDatasource đã hoàn thành. Và bây giờ trong ViewController chúng ta chỉ implement đoạn code ngắn như sau:
Khi sử dụng với block
{% codeblock ViewController.m %}
// tạo block
TVCellConfigureBlock configureCell = ^(CELL_CLASS_NAME *cell, DATATYPE *name) {
  [cell.title setText:name];
};

dataSource = [[TVArrayDataSource alloc] initWithItems:items
                                       cellIdentifier:@"MYCELL"
                                   cellConfigureBlock:configureCell];
[dataSource setXibFileName:@"XibFileName"];
tableview.datasource = dataSource;
{% endcodeblock %}

Hoặc khi sử dụng với selector.
{% codeblock ViewController.m %}
dataSource = [[TVArrayDataSource alloc] initWithItems:items
                                       cellIdentifier:@"MYCELL"
                                               target:self
                                     cellConfigureSel:@selector(configureCell:andItem:)];
[dataSource setCellClassName:@"CELL_CLASS_NAME"];
tableView.dataSource = dataSource;


// selector
- (void)configureCell:(CELL_CLASS_NAME *)cell andItem:(DATA_TYPE *)item
{
    [cell.title setText:item];
}
{% endcodeblock %}

# Tổng kết
Bài viết trình bày về cách tạo class datasource riêng cho tableView thay vì implement trực tiếp trong ViewController. Điều này sẽ giúp ViewController ngắn gọn hơn và code trông đẹp hơn, cũng như tăng khả năng sử dụng lại code. Chúng ta có thể dùng lại class TVArrayDataSource tại nhiều ViewController mà không cần phải implement lại các hàm delegate của TableViewDataSource. Thế nhưng hiện tại class này chỉ dùng cho những tableview có 1 section.
Toàn bộ code của class này cũng như sample bạn có thể tham khảo tại: [https://github.com/ktmt/TVDataSource](https://github.com/ktmt/TVDataSource)

Hoặc để sử dụng class này bạn có thể cài qua coccoapod bằng cách thêm `pod 'TVArrayDataSource'` vào Podfile.

