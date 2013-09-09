---
layout: post
title: "[iOS property:attributes]"
date: 2013-09-10 00:56
comments: true
categories: [iOS, objective c, property, attributes]
---

# Mở đầu
Nếu bạn đã từng sử dụng Objective C thì thấy rằng khi khai báo các property cho 1 class nào đấy chúng ta có 2 cách như sau:
{% codeblock %}
@interface MyClass : NSObject {
    NSString *myString;
}
{% endcodeblock %}
hoặc có thể dùng `@property (attributes) type name` để khai báo như sau:
{% codeblock %}
@interface MyClass : NSObject {
}
@property (strong, nonatomic) NSString *myString;
{% endcodeblock %}
Với cách thứ 2 thì compiler sẽ tự động sinh ra các setter/getter cho property ấy. Thế nhưng việc sinh ra setter/getter như thế nào là phụ thuộc vào tập `attributes` mà bạn đã set ở trên. Khi mới bắt đầu code iOS mình thấy việc set thuộc tính này hơi bị loạn với khá nhiều thuộc tính (retain, strong, weak, unsafe_unretained, nonatomic...). Rồi khi phiên bản thay đổi, kiểu project có dùng ARC hay không cũng dẫn đến việc sử dụng các thuộc tính này cũng khác nhau. Ngoài ra trong một số trường hợp nếu bạn không sử dụng đúng thuộc tính có thể làm app của bạn chạy bị lỗi. Trong bài viết này mình sẽ tóm tắt lại các thuộc tính của property, cũng như nói về khi nào sẽ dùng thuộc tính nào, tại sao, và thuộc tính nào là mặc định.

# Các thuộc tính của property
Nếu chia nhóm thì có lẽ bao gồm 3 nhóm thuộc tính như sau:

## Writability
Nhóm này có 2 thuộc tính là `readwrite` và `readonly`. Nhóm thuộc tính này thì khá là dễ hiểu.
Với thuộc tính `readwrite` thì compiler sẽ generate ra cả setter và getter, còn `readonly` thì compiler chỉ generate ra getter.
Mặc định là `readwrite` (không liên quan đến project dùng ARC hay không).

## Setter Semantics
Nhóm này gồm các thuộc tính để chỉ ra cách thức quản lý bộ nhớ, bao gồm các thuộc tính như sau:
`assign`, `strong`, `weak`, `unsafe_unretained`, `retain`, `copy`.
Khi chúng ta set một trong các thuộc tính này cho property thì setter (getter không liên quan) được tạo ra thay đổi tương ứng với thuộc tính đó.
Trước hết chúng ta sẽ nói qua về cách quản lý bộ nhớ trước iOS5 khi mà ARC chưa xuất hiện.
{% codeblock %}
Car *car1 = [[Car alloc] init];
//...
[car1 release]
{% endcodeblock %}
Trước khi ARC xuất hiện thì các lập trình viên iOS đều phải tự quản lý bộ nhớ.
Khi chúng ta tạo object với vùng nhớ của nó, đồng nghĩa với việc chúng ta nắm giữ ownership của object đó.
Khi không cần dùng nữa thì phải huỷ bỏ ownership đấy đi bằng cách gửi message `release`.
Một object có thể có nhiều ownership và mỗi object sẽ có 1 property tên là `retainCount` để lưu số lượng owner của nó.
Mỗi khi chúng ta tạo object, hay `retain` thì `retainCount` lại được tăng lên 1.
Khi chúng ta gửi message `release` tới object đấy thì `retainCount` lại bị giảm đi 1.
Một khi `retainCount` bằng 0 thì vùng nhớ của nó sẽ bị giải phóng.
Chúng ta có thể gửi message `retain` để tạo thêm ownership như ví dụ dưới đây. Khi đó `car1` và `car2` cùng trỏ đến 1 vùng nhớ và `retainCount` bây giờ bằng 2.
{% codeblock %}
// retain
Car *car2 = [car1 retain];  // retainCount = 2
{% endcodeblock %}
Ngoài ra để copy sang vùng nhớ mới chúng ta có thể gửi message `copy` như ví dụ dưới đây. Khi đó `retainCount` ở vùng nhớ mới có giá trị khởi tạo là 1.
{% codeblock %}
// copy
Car *car3 = [car1 copy];    // retainCount = 1
{% endcodeblock %}

Quay trở lại với thuộc tính của property. Thuộc tính đầu tiên là `retain`. Như ví dụ dưới đây khi ta set thuộc tính `retain` cho property `name` thì compiler sẽ sinh ra setter `setName` như bên dưới.
{% codeblock %}
@interface Car: NSObject

@property (nonatomic, retain) NSString *name;

@end;
{% endcodeblock %}

{% codeblock %}
- (void)setName:(NSString *)newName {
    [newName retain];
    [_name release];
    _name = newName;
}
{% endcodeblock %}
Nhìn vào setter ta thấy đầu tiên là tạo ownership (hay tăng `retainCount` thêm 1) của `newName` bằng cách gọi `[newNmane retain]`.
Tiếp theo là việc gửi message `release` tới `_name` ban đầu để xoá ownership ban đầu đi. Sau đó mới gán contrỏ trỏ đến object mới.
Vậy nên thuộc tính `retain` giúp tạo ra setter trong đó tạo ownership mới và trỏ đến vùng nhớ mới.
Chú ý rằng thuộc tính `retain` chỉ dùng cho những project không dùng ARC.


Và từ iOS5 trở đi Apple giới thiệu ARC giúp cho việc quản lý bộ nhớ đơn giản hơn. ARC không hoạt động như các `Garbage Collection` khác mà thực ra chỉ là phần front-end của compiler nhằm mục đich tự động chèn thêm các đoạn code gọi message như `retain` hay `release`. Từ đấy lập trình viên không phải gọi các message này nữa. Ví dụ như 1 object được tạo trong 1 method thì sẽ chèn thêm đoạn gửi message `release` tới object đó ở gần cuối method. Hay trong trường hợp là property của 1 class `Car` ở trên thì tự động chèn `[_name release]` trong method `dealloc` của class `Car` chẳng hạn.
Khi project của bạn dùng ARC thì chúng ta sẽ dùng thuộc tính `strong` thay cho thuộc tính `retain`.
`strong` cũng tương tự như `retain` sẽ giúp tạo ra setter, mà trong setter đó tạo ra ownership mới (tăng retainCount thêm 1). Và ngoài ra ARC sẽ thêm các đoạn gửi message `release` tới các property này trong method `dealloc` của class.


Thế nhưng xuất hiện vấn đề có tên là `Strong Reference Cycles`. Mình sẽ lấy 1 ví dụ để thấy rõ hơn về vấn đề này.
Một object A nào đấy có ownership của 1 object B. Object B lại có ownership của 1 object C. Object C lại có ownership của object B.
Một khi object A ko cần thiết nữa thì trong method `dealloc` của A sẽ gửi message `release` tới object B. retainCount của object B giảm đi 1 nhưng vẫn còn 1 ( do object C retain ) thế nên method `dealloc` của object B không bao giờ được gọi, kéo theo message `release` cũng không bao giờ được gửi tới object C. Từ đó dẫn đến vùng nhớ của object B và object C không được giải phóng => xuất hiện hiện tượng Leak Memory.
Vì vậy để tránh hiện tượng này ta sẽ dùng thuộc tính `weak` thay vì dùng thuộc tính `strong` trong class của object C.
Với thuộc tính `weak` thì trong setter được sinh ra sẽ không `retain` (không tăng retainCount thêm 1) mà chỉ đơn thuần gán con trỏ trỏ đến vùng nhớ mới.
Thuộc tính `weak` cũng chỉ dùng trong trường hợp bạn đang dùng ARC. Và một cái hay của `weak` nữa là khi vùng nhớ bị giải phóng thì con trỏ được set bằng `nil`. Mà trong Objective C thì gửi message đến `nil` sẽ không vấn đề gì, app của bạn không bị crash. Điển hình nhất của việc dùng thuộc tính `weak` đó là cho các `delegate`, `datasource`.


Tuy nhiên vẫn còn một vài class như NSTextView, NSFont, NSColorSpace chưa hỗ trợ khai báo thuộc tính `weak` nên với những class này bạn có thể dùng thuộc tính `unsafe_unretained` thay cho `weak`. Thế nhưng chú ý 1 điều rằng sau khi vùng nhớ nó trỏ tới bị xoá thì con trỏ không được set la nil.

Tiếp theo là thuộc tính `copy`. Với việc thiết lập thuộc tính này compiller sẽ tạo ra setter như sau:
{% codeblock %}
@interface Car: NSObject

@property (nonatomic, copy) NSString *name;

@end;
{% endcodeblock %}

{% codeblock %}
- (void)setName:(NSString *)newName {
    [_name release];
    _name = [newName copy];     // retainCount = 1
}
{% endcodeblock %}

Như ở trên ta thấy 1 vùng nhớ mới được copy ra và `_name` giờ chiếm giữ 1 ownership của vùng nhớ đó.
Tại sao chúng ta không dùng `strong` ở đây mà lại dùng `copy`. Giả sử ở trên chúng ta dùng thuộc tính `strong` và xem qua 2 ví dụ dưới đây.
{% codeblock %}
NSString *name1 = @"Toyota";
car1.name = name1;
name1 = @"Honda";
{% endcodeblock %}
Trong trường hợp này `car1.name` vẫn có giá trị là "Toyota" và `name1` giờ chuyển thành "Honda". Hoàn toàn không có vấn đề gì.
Thế nhưng trong ví dụ thứ 2 dưới đây thay vì dùng NSString mà dùng subclass của nó là NSMutableString.
{% codeblock %}
NSMutableString *name1 = @"Toyota";
car1.name = name1;
[name1 appendString:"2"];
{% endcodeblock %}
Trong trường hợp này giá trị của `car1.name` là "Toyota2" mặc dù ban đầu chúng ta set là "Toyota".
Vì vậy mặc dù property `name` trong class `Car` với kiểu NSString nhưng nếu dùng `strong` giá trị của `name` vẫn có thể bị append như trên.
Để tránh những trường hợp như thế ta dùng `copy` để mỗi lần gán sẽ copy 1 vùng nhớ mới tránh được những trường hợp như trên.
Đối với những class có subclass là `Mutable...` thì chúng ta nên chú ý dùng thuộc tính `copy`. Ngoài ra `block` cũng phải dùng `copy`.

Thuộc tính cuối cùng trong nhóm này là `assign` thì dùng cho các property kiểu không phải là object. Tức là các kiểu dữ liệu như `int`, `NSInteger`, `float`,...



Với nhóm thuộc tính này thì `strong` là thuộc tính mặc định trong trường hợp dùng ARC, còn `retain` là thuộc tính mặc định trong trường hợp không dùng ARC.

## Atomicity
Nhóm thuộc tính này bao gồm 2 thuộc tính là `atomic` và `nonatomic`. Thuộc tính mặc định là `atomic`.
Nhóm thuộc tính này liên quan đến vấn đề multithread. Chưa bàn đến atomic hay nonatomic, mà chúng ta cùng xem ví dụ sau:
{% codeblock %}
@interface MyView {
}

@property CGPoint center;

@end
{% endcodeblock %}

khi đấy chúng ta có setter/getter như sau:

{% codeblock %}
- (CGPoint) center {
  return _center;
}

- (void)setCenter:(CGPoint)newCenter {
  _center = newCenter;
}
{% endcodeblock %}
và bởi vì struct CGPoint có 2 thành phần `CGFloat x, CGFloat y` nên thực ra setter sẽ thực hiện các bước như sau:
{% codeblock %}
- (void)setCenter:(CGPoint)newCenter {
  _center.x = newCenter.x;
  _center.y = newCenter.y;
}
{% endcodeblock %}

Trong trường hợp chúng ta chạy multithread thì có thể xảy ra khả năng như sau:
{% codeblock %}
// giả sủ ban đầu center của myView là (-5.f, -8.f)

// thread 1 gọi setter
[myView setCenter:CGPointMake(1.f, 2.f)];

// tiep theo bên trong setCenter sẽ chạy
_center.x = newCenter.x; // _center.x giờ có giá trị là 1.f và _center.y vẫn giữ giá trị là -8.f

// chưa kịp chạy lệnh tiếp theo để set _center.y thì ở thread 2 gọi getter
CGPoint point = [myView center];
// và getter chạy trả về (1.f, -8.f)

// thread 1 tiếp tục giá trị cho y
_center.y = newCenter.y // _center.y giờ là  2.f
{% endcodeblock %}

Như trường hợp ở trên ta thấy giá trị center là (1.f, 2.f) nhưng tại thread 2 giá trị lấy được lại là (1.f, -8.f)
dẫn đến kết quả không được như mong muốn.
Vì vậy trong trường hợp multithread để tránh những tình huống như trên ta set thuộc tính `atomic` cho property. Khi đấy compiler sẽ sinh ra các setter/getter như sau:
{% codeblock %}
- (CGPoint) center {
  CGPoint curCenter;
  @synchronized(self) {
    curCenter = _center;
  }
  return curCenter;
}

- (void)setCenter:(CGPoint)newCenter {
  @synchronized(self) {
    _center = newCenter;
  }
}
{% endcodeblock %}
Bên trong setter/getter sử dụng lock để tránh việc nhiều thread truy cập đồng thời. Thế nhưng việc dùng lock sẽ mất chi phí cũng như cản trở tốc độ của chương trình. Vì vậy nên trong trường hợp bạn không dùng multithread hoặc không thể xảy ra những vấn đề như trên thì bạn nên dùng thuộc tính `nonatomic` để tăng tốc độ cho chương trình.

# Tổng kết
Bài viết này mình đã trình bày về các thuộc tính cho property, giải thích qua về các thuộc tính cũng như khi nào nên dùng thuộc tính nào.
Mặc dù mình vẫn thấy còn những lập trình viên không dùng ARC nhưng có lẽ đa số mọi người đã chuyển qua dùng ARC.
Thế nên thuộc tính `retain` có thể không cần dùng nữa.
Để tìm hiểu kĩ hơn các bạn có thể đọc tại [Programming With Objective C](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/ProgrammingWithObjectiveC.pdf)
