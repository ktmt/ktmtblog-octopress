---
layout: post
title: "#include, #import, @import (clang modules)"
date: 2014-01-06 04:14
comments: true
categories: [iOS, Objective-C, Modules, Clang, Compiler]
---

# Mở đầu

Happy New Year! Chúc mọi người năm mới vui vẻ, hạnh phúc.
Sau 1 tuần nghỉ tết ăn chơi và giành được cúp vô địch giải bi-a danh giá, 
tối hôm nay mình lại gấp rút ngồi viết bài blog đầu năm (do thế lực ngầm đang thúc giục). 

Như các bạn cũng biết gần đây XCode5 cùng iOS7 đã được giới thiệu. 
Đi cùng XCode5 là feature mới “modules” của Clang, một giải pháp nhằm giải quyết một số vấn đề như tăng tốc độ compile source code của ứng dụng.
Hôm nay mình sẽ giới thiệu qua về tính năng modules này. 
Hiện tại thì modules đã có thể sử dụng trong C và Objective-C trên môi trường iOS7 hoặc MacOSX 10.9. 
Các đoạn code dưới đây tuy mình viết bằng Objective-C nhưng cũng gần như tương tự với C.
Để hiểu về modules thì trước tiên mình sẽ giải thích lần lượt về `#include`, `#import`, và pre-compiled headers (PCH), sau đó là về modules.

## #include
Khi chúng ta include 1 file header thì tại giai đoạn preprocessing của quá trình compile, 
compiler sẽ copy nội dung của file header này và paste vào dòng #include.
Và tất nhiên quá trình copy/paste này là đệ quy cho đến khi copy xong tất cả file header mà nó include và các file header khác được include tại các file nó include. (hơi xoắn)

Ví dụ với chương trình helloworld quen thuộc như dưới đây:

{% codeblock lang:objc helloworld.m %}
#include <Foundation/Foundation.h>

int main(int argc, const char *argv[])
{
     NSLog(@“Hello world”);
     
     return 0;
} 
{% endcodeblock %}

Chúng ta có thể chạy preprocessor để xem file sinh ra sau giai đoạn này bằng lệnh `clang -E helloworld.m | less`.

Nhìn vào kết quả output chúng ta có thể thấy tới hơn 92000 dòng là của Foundation.h (và của các file header mà Foundation.h include), chỉ 8 dòng cuối là code của chúng ta.

Với việc sử dụng `#include` tồn tại vấn đề gọi là recursive include. Ví dụ :

{% codeblock lang:objc FirstFile.h %}
#include "SecondFile.h"
 
/* Some code */
{% endcodeblock %}

{% codeblock lang:objc SecondFile.h %} 
#include "FirstFile.h"
  
/* Some other code */
{% endcodeblock %}

Khi đấy preprocessor sẽ duyệt file FirstFile.h và copy nội dung của SecondFile.h vào FirstFile.h. 
Khi duyệt file SecondFile.h lại copy/paste nội dung của file FirstFile.h. 
Vấn đề này được gọi là recursive include. 

## #import

Trong Objective-C để tránh vấn đề recursive include như trên thì chúng ta thường dùng `#import`.
Khi dùng `#import` thì trước khi include 1 file header, preprocessor sẽ kiểm tra xem file đấy đã được include chưa, 
nếu đã include rồi thì sẽ không include nữa. 
Tương tự trong C chúng ta cũng tránh recursive include bằng việc kiểm tra file header đã được  include chưa như sau:

{% codeblock %}
#ifndef MYFILE_H
#define MYFILE_H
 
// Some code
  
#endif
{% endcodeblock %}

## @import
Tuy nhiên việc sử dụng `#import` cũng như `#include` khiến cho preprocessor đối mặt với 1 số vấn đề khác như Fragility và Performance. 
Để hiểu về vấn đề Header Fragility chúng ta xem qua một ví dụ đơn giản sau:

{% codeblock lang:objc MyFile.h %}
#define NSURL @“my url"
 
#import <Foundation/Foundation.h>
 
@interface MyClass :NSObject
   
@end 
{% endcodeblock %}

Khi đó sau quá trình preprocessing thì file header của chúng ta sẽ như sau:


{% codeblock lang:objc %}
#define NSURL @“my url"
 
// đoạn code được copy từ Foundation.h
// và tất cả những đoạn có chứa NSURL của Foundation.h đều bị thay bằng “my url”

@interface MyClass :NSObject

@end
{% endcodeblock %}

Tất cả những đoạn NSURL của Foundation.h đều bị preprocessor thay thế bằng “my url” do có `#define NSURL @“my url”` bên trên. 
Từ đó ta thấy với việc dùng `#include` hay `#import` thông thường thì các header của các file khác, 
hay của thư viện mà chúng ta dùng đều có thể bị ảnh hưởng như việc dùng `#define` ở trên. 

Về vấn đề performance thì như ở trên ta đã thấy `#include` và `#import` sẽ copy toàn bộ file header mà nó include vào (đệ quy). 
Như ở ví dụ đầu tiên chúng ta chỉ include mình Foundation.h nhưng sau khi preprocessing thì có tới hơn 92000 dòng là của 
Foundation.h (và các file header mà nó include), chỉ 8 dòng cuối là code của chúng ta.
Thế nên thời gian compile sẽ trở nên nhiều hơn rất nhiều. 

### Pre-compiled headers

Để giải quyết 1 phần vấn đề performance chúng ta có thể dùng precompiled headers (.pch).
Nếu các bạn chú ý thì tất cả iOS project khi được XCode tạo ra đều có file PROJECTNAME-Prefix.pch như sau:

{% codeblock lang:objc PROJECTNAME-Prefix.pch %}
#import <Availability.h>

#ifndef __IPHONE_3_0
#warning "This project uses features only available in iOS SDK 3.0 and later."
#endif

#ifdef __OBJC__
    #import <UIKit/UIKit.h>
    #import <Foundation/Foundation.h>Foundation;
#endif
{% endcodeblock %}


Trong file .pch này chúng ta sẽ include những header mà có khả năng được include tại nhiều nơi trong source code 
của ứng dụng như Foundation.h, UIKit.h… Khi source code của ứng dụng được compile thì file .pch này sẽ được compile đầu tiên, 
đồng nghĩa với việc tất cả file header được include trong file .pch này sẽ được compile trước và được include vào tất cả source code. 

Bằng viêc caching những file header đã được biên dịch này thì những file này chỉ cần compile 1 lần, 
những lần sau chỉ cần sử dụng lại nên thời gian compile sẽ được rút gọn. 

Thế nhưng các developer thường không hay quản lý file .pch này, và không phải file header nào cũng được dùng tại nhiều nơi trong source code
nên hiệu quả của .pch chưa được cao.


## Modules
Vào tháng 11 năm 2012, Doug Gregor ( một kỹ sư của Apple ) đã giới thiệu tính năng modules nhằm giải quyết vấn đề trên của proprocessor thay cho .pch. 
Vậy module là gì? Module chính là một package mô tả một library, framework.

Ví dụ chạy 2 lệnh dưới đây ta sẽ có thể xem được các module trong SDK của iOS7.

{% codeblock %}
% cd `xcrun --sdk iphoneos --show-sdk-path`
% find . -name module.map   

 ./Developer/Library/Frameworks/XCTest.framework/module.map   
 ./System/Library/Frameworks/AudioToolbox.framework/module.map   
 ./System/Library/Frameworks/AudioUnit.framework/module.map   
 ./System/Library/Frameworks/CoreAudio.framework/module.map     
    :     
    :   
 ./usr/include/dispatch/module.map   
 ./usr/include/mach-o/module.map   
 ./usr/include/module.map   
 ./usr/include/objc/module.map
{% endcodeblock %}

Với mỗi framework ta thấy có 1 file module.map để mô tả framework đấy. 
Và để sử dụng framework chúng ta có thể thay `#import <Frameworkname.h>` bằng `@import Frameworkname;`
Ví dụ khi sử dụng framework Foundation ta sẽ dùng `@import Foundation;` 
Vậy khi trong một file header gặp đoạn import module thì compiler đã xử lý gì và tại sao lại giải quyết được vấn đề Fragility và 
Performance của preprocessor?

Ví dụ khi trong một file header, preprocessor gặp `@import Foundation` thì sẽ xử lý các bước như sau:

- Tìm file module.map của framework có tên là Foundation
- Dựa vào mô tả về framework trong file module.map này compiler sẽ parse các file headers và 
sinh ra file module (lưu dưới dạng AST - biểu diễn dưới dạng tree trước khi chuyển sang mã máy)
- Load file module này tại đoạn khai báo import
- Cache file module này để sử dụng lại cho những lần sau

Thứ nhất thay vì copy nội dung các file header được include rồi mới compile, mà import trưc tiếp file module đã được 
lưu dưới dạng AST nên các header của framework ko bị ảnh hưởng bởi các đoạn code trước khi import (như #define) ->
 tránh được vấn đề Fragility. 

Thứ hai là nhờ việc cache những file module này mà compiler không phải biên dịch lần 2 nên sẽ rút gọn thời gian biên dịch.

Ngoài ra một điều thú vị nữa mà tính năng module mang lại cho lập trình viên đó là chúng ta không phải tự tay link các framework mà chúng ta import. 
Ví dụ như trước đây nếu trong file tmp.m có `#include <Foundation/Foundation.h>` thì khi biên dịch chúng ta phải tự link tới Foundation bằng lệnh : 
`clang tmp.m -o tmp -framework Foundation`


Thế nhưng khi sử dụng `@import` thì chúng ta không cần phải tự link tới framework nữa mà chỉ cần:
`clang tmp.m -o tmp -fmodules`


Với XCode chúng ta sẽ không phải add thêm các framework mà mình muốn dùng trong `Link Binary With Libraries` như hình dưới đây.

{% img /images/clang_modules/link_framework.png %}

Đối với những project được tạo từ XCode5 thì tính năng module tự động được enable. 
Nhưng những project được tạo trước đây các bạn phải tự enable trong phần `Build Settings`.

{% img /images/clang_modules/enable_module.png %}


#Kết luận

Bài viết này mình đã giới thiệu qua tính năng module của Clang trong được giới thiệu từ XCode5. 
Và đồng thời cũng giải thích qua về `#include`, `#import`, pch. 
Mặc dù tính năng module vẫn đang trong quá trình hoàn thiện nhưng hiện tại chúng ta đã có thể sử dụng với XCode5.

Các bạn có thể tìm hiểu thêm tại: 

-  [clang_modules](http://clang.llvm.org/docs/Modules.html)
-  [Bài phát biểu của Gregor](http://llvm.org/devmtg/2012-11/Gregor-Modules.pdf)
