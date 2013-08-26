---
layout: post
title: "Những mẹo lập trình với Objective-C"
date: 2013-08-26 09:30
comments: true
categories: iOS
---

# Mở đầu
Đối với những lập trình viên khi mới tiếp xúc với Objective-C, chắc hẳn sẽ gặp phải 1 số bỡ ngỡ với các cú pháp của nó. Tuy được kế thừa từ C nhưng Objective-C lại có cách gọi hàm, sử dụng biến khác hẳn. Vì thế, bài viết này sẽ giới thiệu cho mọi người 1 số mẹo để lập trình hiệu quả với Objective-C, đặc biệt là đối với những ai chưa có thời gian dài tiếp xúc với nó.

# Objective-C Literals
- Thứ nhất là đối với NSNumber, thay vì phải khởi tạo dài dòng như `[NSNumber numberWithInt:x]`… chúng ta có thể thay thế bằng các cách dưới đây:
{% codeblock lang:objc %}

// character literals.
  NSNumber *theLetterZ = @'Z';          // tương đương với [NSNumber numberWithChar:'Z']

  // integral literals.
  NSNumber *fortyTwo = @42;             // tương đương với [NSNumber numberWithInt:42]
  NSNumber *fortyTwoUnsigned = @42U;    // tương đương với [NSNumber numberWithUnsignedInt:42U]
  NSNumber *fortyTwoLong = @42L;        // tương đương với [NSNumber numberWithLong:42L]
  NSNumber *fortyTwoLongLong = @42LL;   // tương đương với [NSNumber numberWithLongLong:42LL]

  // floating point literals.
  NSNumber *piFloat = @3.141592654F;    // tương đương với [NSNumber numberWithFloat:3.141592654F]
  NSNumber *piDouble = @3.1415926535;   // tương đương với [NSNumber numberWithDouble:3.1415926535]

  // BOOL literals.
  NSNumber *yesNumber = @YES;           // tương đương với [NSNumber numberWithBool:YES]
  NSNumber *noNumber = @NO;             // tương đương với [NSNumber numberWithBool:NO]

#ifdef __cplusplus
  NSNumber *trueNumber = @true;         // tương đương với [NSNumber numberWithBool:(BOOL)true]
  NSNumber *falseNumber = @false;       // tương đương với [NSNumber numberWithBool:(BOOL)false]
#endif

{% endcodeblock %}


- Tạo mảng nhanh: Thay vì dùng khởi tạo `[NSArray arrayWithObjects:…]` chúng ta có thể dùng:

{% codeblock lang:objc %}
NSArray *array = @[ @"Hello", NSApp, [NSNumber numberWithInt:42] ];
{% endcodeblock %}

Và tạo NSDictionary:
{% codeblock lang:objc %}
NSDictionary *dictionary = @{
    @"name" : name1,
    @"date" : [NSDate date],
    @"processInfo" : [ProcessInfo processInfo]
};
{% endcodeblock %}

Cách gọi trên kia sẽ tạo ra 1 NSDictionary với 3 key: name, date, processInfo và các value tương ứng. Các value phải là đối tượng của ObjectiveC và phải khác nil (nếu không sẽ crash).
Tiện thể với dictionary, khi khởi tạo 1 NSDictionary:
{% codeblock lang:objc %}
[NSDictionary dictionaryWithObjectsAndKeys:
                value_1, @"key1",
                value_2, @"key2",
                value_3, @"key3",
                ...
                value_n, @"keyn", nil]
{% endcodeblock %}

Nếu có 1 trong các value từ `value_1` đến `value_n` bằng nil, vd là `value_i`, thì NSDictionary được tạo ra sẽ chỉ nhận được các key và value trong khoảng từ `value_1` đến `value_(i-1)` chứ không làm crash chương trình. Vì vậy, trong lúc lập trình, nên chú ý điều này để tránh việc tìm không ra lỗi.

- Sử dụng toán tử chỉ số cho array và dictionary giống C:
{% codeblock lang:objc %}
NSMutableArray *array = ...;
NSUInteger idx = ...;
id newObject = ...;
id oldObject = array[idx];	// tương đương với oldObject = [array objectAtIndex:idx]
array[idx] = newObject;         // tương đương với [array replaceObjectAtIndex:idx withObject:newObject]

NSMutableDictionary *dictionary = ...;
NSString *key = ...;
oldObject = dictionary[key];	// tương đương với oldObject = [dictionary objectForKey:key]
dictionary[key] = newObject;    // tương đương với [dictionary setObject:newObject forKey:key]
{% endcodeblock %}

Chú ý là replace object chỉ dùng được cho NSMutableArray và NSMutableDictionary, không dùng được cho NSArray và NSDictionary.


# Mẹo debug với XCode

Khi debug code Objective C, chương trình sẽ nhảy ra hàm main `int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");` mỗi khi có crash. Màn hình log thì có quá ít thông tin để giúp cho việc debug lỗi crash này. Vậy thì làm thế nào để khắc phục điều này, giúp cho XCode stop lại ở đúng nơi nó bị crash?
Đầu tiên là mở panel Breakpoint Navigator và click vào button + ở góc trái dưới màn hình, chọn Add Exception Breakpoint:

{% img /images/meo_objective_c/addex.png %}

Sau đó ấn Done button để tạo 1 exception breakpoint mới:

{% img /images/meo_objective_c/doneex.png %}

Chuột phải vào breakpoint mới tạo ra, chọn Move breakpoint to > User để áp dụng cho tất cả các workspaces khác:

{% img /images/meo_objective_c/senduser.png %}

Vậy là xong, kể từ bây giờ bạn sẽ được nhìn thấy nơi chôn rau cắt rốn của đống crash :)

# Tổng kết
Những tips trong bài viết này tuy nhỏ nhưng có thể sẽ rất hữu ích trong quá trình code của bạn, giúp code ngắn gọn và sáng sủa hơn. Tất nhiên vẫn còn rất nhiều kỹ thuật đặc biệt khác trong Objective-C mà trong khuôn khổ bài viết này chưa thể đề cập hết được. Vì thế, hãy đợi bài viết sau nhé :)
