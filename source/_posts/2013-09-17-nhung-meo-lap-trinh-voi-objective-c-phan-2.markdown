---
layout: post
title: "Những mẹo lập trình với Objective-C phần 2"
date: 2013-09-17 10:29
comments: true
categories: iOS
---

Tiếp theo phần trước, trong bài viết này sẽ giới thiệu 1 kỹ thuật khác trong Objective C: Swizzling method.

#Swizzling

Thông thường, khi muốn thêm vào 1 class có sẵn 1 vài hàm mới, chúng ta có thể dùng `Categories`, đặc biệt là các class của thư viện (ko có source code) như NSArray, NSDictionary…
Tuy nhiên, cách dùng `Categories` có 1 hạn chế là bạn không thể override các hàm có sẵn. Vậy đây chính là lý do chúng ta cần sử dụng đến Swizzling method.

Trong Objective C, khi bạn viết 1 đoạn code
{% codeblock lang:objc %}
[self presentViewController:mailController animated:YES completion:nil];
{% endcodeblock %}

bạn không thực sự gọi đến hàm `presentViewController:animated:completion:` mà thay vào đó là gửi đi 1 message `presentViewController:animated:completion:`. Trong quá trình chạy, object sẽ tìm kiếm method tương ứng dựa vào id của message này. Chúng ta có thể dựa vào swizzling để thay đổi cách object tìm kiếm method tương ứng này:

{% codeblock lang:objc %}
SEL firstMethodSelector = @selector(firstMethod);
SEL secondMethodSelector = @selector(secondMethod);
Method firstMethod = class_getInstanceMethod(self, firstMethodSelector);
Method secondMethod = class_getInstanceMethod(self, secondMethodSelector);
 
BOOL methodAdded = class_addMethod([self class],
                                   firstMethodSelector,
                                   method_getImplementation(secondMethod),
                                   method_getTypeEncoding(secondMethod));
  
if (methodAdded) {
class_replaceMethod([self class], 
                      secondMethodSelector, 
                      method_getImplementation(firstMethod),
                      method_getTypeEncoding(firstMethod));
} else {
  method_exchangeImplementations(firstMethod, secondMethod);
}
{% endcodeblock %}

Đi từng bước cho đoạn code ở trên:

1. Trước hết chúng ta tạo ra các selectors (SEL): `firstMethodSelector` và `secondMethodSelector`

2. Lấy ra các hàm tương ứng với selectors gán vào `firstMethod` và `secondMethod` Method

3. Thêm vào class định nghĩa của method thứ 2 dưới cách gọi của method thứ nhất. Trường hợp này xảy ra khi method thứ nhất không thực sự tồn tại (trong 1 khả năng nào đó)

4. Nếu điều này xảy ra, chúng ta cần 1 định nghĩa cho selector của method thứ 2, vì vậy thay thế nó bằng implementation của method thứ nhất (rỗng)

5. Nếu không xảy ra, nghĩa là method thứ nhất có tồn tại, chúng ta thay đổi implementation của 2 method. 

# Ví dụ 1
Khi sử dụng Google Analystics, chúng ta muốn track page view cho tất cả các UIViewController trong project, tuy nhiên, nếu ở class nào cũng gọi hàm `trackView:<class_name>` thì tương đối nhiều, mà có thể còn bỏ sót. Vậy cách đơn giản nhất là override lại hàm `viewDidLoad` của `UIViewController`, trong đó chúng ta thực hiện `trackView` hoặc gọi 1 hàm khác bất kỳ, tuỳ theo mục đích của mình.

Chúng ta viết phần code trên trong `Categories` của `NSObject`, từ đó có thể gọi nó từ bất kỳ class nào:

{% codeblock lang:objc %}
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>
 
@implementation NSObject (Swizzle)
 
+ (void) swizzleInstanceSelector:(SEL)originalSelector 
                 withNewSelector:(SEL)newSelector
{
  Method originalMethod = class_getInstanceMethod(self, originalSelector);
  Method newMethod = class_getInstanceMethod(self, newSelector);
 
  BOOL methodAdded = class_addMethod([self class],
                                     originalSelector,
                                     method_getImplementation(newMethod),
                                     method_getTypeEncoding(newMethod));
  
  if (methodAdded) {
    class_replaceMethod([self class], 
                        newSelector, 
                        method_getImplementation(originalMethod),
                        method_getTypeEncoding(originalMethod));
  } else {
    method_exchangeImplementations(originalMethod, newMethod);
  }
}
 
@end
{% endcodeblock %}

Bây giờ tạo tiếp `Categories` cho UIViewController:
{% codeblock lang:objc %}

#import "UIViewController+ Swizzling.h"
#import "NSObject+Swizzle.h"

@implementation UIViewController (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceSelector:@selector(viewDidLoad)
                      withNewSelector:@selector(myViewDidLoad)];
    });
}

- (void) myViewDidLoad {
    NSLog(@"This is my view did load");
    
    // Track Google Analystic here
    
    [self myViewDidLoad];
    
}
{% endcodeblock %}

Khi Objective-C run-time load 1 category, nó sẽ gọi đến hàm `load`. Chúng ta sử dụng dispatch_once để chắc chắn rằng hàm swizzle chỉ được gọi 1 lần. Sau khi import category này, (tốt nhất là trong file prefix - pch) tất cả các hàm `viewDidLoad` của `UIViewController` sẽ được thay thế bằng hàm `myViewDidLoad`.

# Ví dụ 2
1 ứng dụng khác của swizzling method là khi debug lỗi `index out of range` của NSArray. Nhiều khi gặp phải lỗi này nhưng chương trình không dừng lại ở đúng đoạn code bị lỗi (nhảy ra hàm main). 1 cách đơn giản để xử lý trường hợp này là override hàm `objectAtIndex:` của NSArray và bắt exception trong đó. Tuy nhiên, cách sử dụng swizzling method ở đây có hơi khác 1 chút.

Trước hết là tạo `Category` cho `NSArray`:

{% codeblock lang:objc %}
@implementation NSArray (OutOfRange)

-(void)safeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        NSLog(@"%s self = %@, pointer = %p, index = %lu", __FUNCTION__, self, self, (unsigned long)index);
    }
    [self safeObjectAtIndex:index];
}

@end
{% endcodeblock %}

Đặt 1 breakpoint vào trong điều kiện `if (index >= self.count)` để có thể biết được lỗi đến từ đâu.
Sau đó, trong hàm `main` của `main.m`, thực hiện exchange method:
{% codeblock lang:objc %}
#import <objc/runtime.h>
#import "NSArray+OutOfRange.h"

int main(int argc, char *argv[])
{
    Class arrayClass = NSClassFromString(@"__NSArrayM");
    Method originalMethod = class_getInstanceMethod(arrayClass, @selector(objectAtIndex:));
    Method categoryMethod = class_getInstanceMethod([NSArray class], @selector(safeObjectAtIndex:));
    method_exchangeImplementations(originalMethod, categoryMethod);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
{% endcodeblock %}

Lưu ý ở đây chúng ta gọi Class `arrayClass = NSClassFromString(@"__NSArrayM");` là bởi vì hàm `objectAtIndex:` không đến từ `NSArray` class mà đến từ `__NSArrayM` (xem trên console debug). Chính vì thế chúng ta không thể sử dụng cách swizzle thông thường như trong ví dụ 1. 

Để test đoạn code này, trong 1 đoạn chương trình bất kỳ, tạo ra 1 bug:
{% codeblock lang:objc %}
NSMutableArray *list = [NSMutableArray arrayWithObjects:@"1", @"2", nil];
NSLog(@"Test: %@", [list objectAtIndex:3]);
{% endcodeblock %}

Bây giờ, chạy chương trình và tận hưởng thành quả :)