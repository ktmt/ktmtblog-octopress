---
layout: post
title: "android ndk và openssl (phần 1)"
date: 2014-08-23 21:35
comments: true
categories: 
 - android
 - openssl
---

#1. Mở đầu
Gần đây ở công ty tôi có được giao một task khá hay. Công ty tôi có một game viết trên nền tảng android.
Game đó viết bằng anđroid, tuy nhiên lại chủ yếu dùng web view để hiển thị.
Mặc dù vậy, một số logic như là set session cho user, authenticate cho user thì lại nằm trên android.

Chắc các bạn cũng đã biết, android app được viết bằng java, dịch ra file dex, sau đó được phân phối trên google playstore dưới dạng file apk. Do đó, android app có một điểm yếu cố hữu mà mọi java app đều mắc phải, đó là bảo mật. Điểm yếu bảo mật ở đây là gì? Đó là việc mà mọi java app đều có thể được phân tích ngược (reverse engineer) rất dễ dàng. 
Việc này bắt nguồn từ bản chất java được dịch ra bytecode ở dạng khá "gần" với ngôn ngữ lập trình thông thường, và bytecode chứa đầy đủ các thông tin cần thiết để bạn có thể dịch lại nguyên vẹn lại chương trình gốc.

Vậy cái điểm yếu bảo mật này liên quan đến cái app tôi đang phụ trách thế nào? 
Như tôi vừa nói ở trên, trong cái game mà tôi đang phụ trách,  logic authenticate cho user sẽ nằm trên phía android. Điều này có nghĩa là trên android app sẽ phụ trách:

 - Mã hoá uuid của người dùng, gửi lên server
 - Server sẽ nhận uuid đó, và gửi session key về cho user để user set vào cookie.

 Chắc hẳn sẽ có bạn thắc mắc là qui trình xác thực này quá đơn giản. Đúng vậy, quy trình này quá đơn giản, dẫn đến là việc chỉ cần user A (người xấu) biết uuid của user B (người bị hại) thì A sẽ giả mạo được bất cứ hành động của B như là gửi đồ từ B cho A. 
 
 Vậy tại sao không làm một qui trình xác thực tốt hơn, như dùng thêm một token giống như onetime password mà chỉ user đó mới biết được, hay là làm cách nào để "giấu" uuid đi để cho user khác không biết. Đúng là nên như thế! Tuy nhiên vì một số lý do "lịch sử" của legacy code, mà chúng ta không thể thay đổi qui trình xác thực một cách dễ dàng như thế được.

Như vậy thì với flow code hiện tại thì với điểm yếu của android tôi đã nói ở trên thì một người có chút kiến thức lập trình có thể dễ dàng dịch ngược đoạn logic dùng để xác thực mà tôi đã nói ở trên. Mà trong đó có việc ```mã hoá uuid người dùng``` mà khi bạn nhìn được logic code thì mã hoá cũng bằng thừa. Lý do tại sao lại bằng thừa vì code hiện tại đang sử dụng "Symmetric Cryptography Algorithm". Symmetric ở đây có nghĩa là thuật toán mã hoá đối xứng, mà điển hình gồm có những thuật toán như blowfish, AES, DES. 

Nói một cách đơn giản thì các loại thuật toán symmetric thì **bên gửi và bên nhận sẽ dùng cùng một key, cùng một intitialize vector** (Các khái niệm này tôi sẽ trình bày kĩ hơn ở dưới) , do đó chỉ cần dịch ngược được code thì user A (người xấu) sẽ có được key và initialize vector để tạo ra một request hợp lệ sử dụng uuid của user B.

Vậy thì chúng ta phải giải quyết vấn đề này thế nào? Sau một hồi thảo luận với công ty thì tôi nghĩ ra một giải pháp "chữa cháy" tạm thời, đấy là chuyển logic vào native code sử dụng ndk và C, mục đích để đạt được là:

 > "Giấu" đi logic mã hoá uuid người dùng, giấu cả các tham số ban đầu như key và initialize vector. Do đó mà user A sẽ không biết làm cách nào để tạo ra một request hợp lệ với uuid của user B.

Cách giải quyết này tại sao tôi nói là tạm thời, bởi vì user A nếu có thêm một chút hiểu biết về ndk thì sẽ biết được interface cung cấp ở ndk code sẽ được public ra ngoài, do đó thì vẫn có thể tận dụng được điểm này để tạo ra một request hợp lệ. Tuy nhiên do không nghĩ ra giải pháp khác nên tạm thời dùng cách này sẽ hạn chế được các hacker "gà mờ".

Vậy để đi theo hướng đi này chúng ta cần phải tìm hiểu về 2 thứ đó là : **Android NDK** và cách để sử dụng các thuật toán mã hoá trên ndk (ở đây là sử dụng ngôn ngữ C), đó là **openssl**.
Phần giới thiệu hơi dài dòng, nhưng đến đây các bạn đã nắm được tại sao tiêu đề bài viết lại là Android NDK và open SSL.

Dưới đây chúng ta sẽ đi lần lượt về 2 vấn đề cần giải quyết : Android NDK và OpenSSL

#2. Android NDK
Android NDK là một kit phát triển giúp bạn có thể phát triển các phần mềm android mà dựa một phần trên các đoạn code viết trên C hoặc C++. Bạn sẽ cần đến NDK trong các sản phầm cần đến hiệu năng cao, mà khi đó các đoạn code được build ra binary sẽ phát huy hiệu năng tối đa. Các logic code được thực hiện trên ndk ở dứoi đây tôi sẽ gọi chung là native code.

Về cơ chế hoạt động của ndk, bạn có thể hiểu một cách đơn giản như trong hình vẽ dưới đây, app của bạn sẽ tiến hành giao tiếp với native code thông qua một interface gọi là JNI. 

Một cách đơn giản, JNI là một bộ giao thức giao tiếp chuẩn của java, giúp cho java code có thể **nói chuyện** được với C/C++ code, có thể **truyền** dữ liệu giữa 2 bên. 

{% img /images/ndk-1.png %}

Để tham khảo thêm về android ndk, các bạn có thể vào trang chủ của android tại [Trang chủ của android](https://developer.android.com/tools/sdk/ndk/index.html). Dưới đây tôi sẽ tóm tắt các bước cần thiết để sử dụng được ndk.

## Cài đặt
Cách cài đặt android ndk khá giống với sdk, tức là chỉ đơn thuần là bạn tải bộ ndk về, đặt vào đâu đó. Trong bộ NDK đó sẽ chứa đầy đủ các tool để có thể build được ndk native code từ C/C++ source (bao gồm build script và các file header cần thiết). 
Quá trình cài đặt có thể hiểu tóm gọn qua đoạn script dưới đây (chạy trên môi trường unix):

```
wget http://dl.google.com/android/ndk/android-ndk64-r10-darwin-x86.tar.bz2
tar yxvf android-ndk64-r10-darwin-x86.tar.bz2
mv android-ndk64-r10-darwin-x86 ~/
echo "export PATH=$PATH:/~/android-ndk64-r10-darwin-x86" >> ~/.bash_profile
echo "export ANDROID_NDK_ROOT=/Users/huydo/android-ndk64-r10-darwin-x86" >> ~/.bash_profile
source ~/.bash_profile
```

Sau khi chạy đoạn script trên thì android ndk đã được thêm vào path của hệ thống, giúp chúng ta có thể gõ các lệnh như `ndk-build` từ bất kì đâu

##Sử dụng
Trong bộ ndk bạn down về có chứa sẵn khá nhiều ví dụ về cách sử dụng ndk, từ đơn giản (như hello world) cho đến các ví dụ phức tạp hơn như xử lý ảnh (mà phải thao tác gửi dữ liệu giữa android app và ndk app khá phức tạp). Các bạn có thể tham khảo các ví dụ đó để có cái nhìn thực tế về ndk program. Dưới đây tôi sẽ trình bày ngắn gọn về quá trình sử dụng của tôi.

Như ở hình ở trên thì các bạn thấy là android app và native code sẽ "nói chuyện" với nhau thông qua một "ngôn ngữ" chung gọi là jni. Như vậy sẽ có 2 khả năng xảy ra, dẫn đến 2 ngữ cảnh để sử dụng ndk:

- 1. Viết một số logic code quan trọng ở phía native code, và các logic còn lại để ở phía android app như bình thường. Các giao tiếp sẽ được gọi từ phía java thông qua jni. Cách tiếp cận này thuận lợi ở chỗ là chúng ta tận dùng được mọi điểm mạnh của android frame work, và chỉ các logic nào thật cần thiết mới đưa vào native code.
- 2. Viết "native activity", tức là logic của activity như hiển thị, life cycle, gọi các activity khác.. sẽ được code toàn bộ ở trên phía native. Cách này thực tế khá ít sử dụng, thường sử dụng trong trường hợp mà dữ liệu quá khó để truyền đi truyền lại giữa bên java và native, thì việc code luôn cả activity trên native cũng là một lựa chọn cần thiết.

Ở bài viết này tôi sẽ đi theo hướng tiếp cận 1, để giải quyết bài toán theo hướng:

> Đưa logic mã hoá uuid người dùng vào một file C, build ra binary và gọi logic đó trên phía java thông qua JNI.

##Coding và build
Để đi theo hướng tiếp cận 1 như đã nói ở trên, chúng ta có thể dễ dàng hình dung công việc phải làm:

- Step 1: Viết logic code mã hoá trên C, nhận đầu vào là 1 chuỗi mô tả uuid của người dùng, đầu ra là chuỗi đó dã được mã hoá.
- Step 2: Build đoạn code đó thành một file thư viện động (.so file) và "Nhúng" file thư viện động đó vào trong android project
- Step 3: Viết logic code gọi native code trên java.

###Step 1: Cấu trúc của một file native code viết trên C
Thông thường, chúng ta sẽ tạo một folder tên là jni và đặt toàn bộ các đoạn code, header, các thư viện liên quan vào trong đó.

{% img /images/jni-2.png %}

File native code viết trên C khá đơn giản, chỉ cần tóm gọn lại trong 2 bước:

- include thư viện <jni.h>
- Viết các hàm dựa trên convention của jni để tạo ra các "interface", và phía java sẽ gọi được các "interface" này một cách khá dễ dàng

Một ví dụ hết sức về native code như dưới đây:

{% codeblock hello_jni.c %}
#innclude <string.h>
#include <jni.h>

jstring
Java_com_example_hellojni_HelloJni_stringFromJNI( JNIEnv* env,
                                                  jobject thiz )
{
   return (*env)->NewStringUTF(env, "Hello from JNI ! ");
}
{% endcodeblock %}

Các bạn để ý tên hàm của native code sẽ dễ dàng nhận thấy convention như trong hình dưới đây:

{% img /images/jni-1.png %}

Nhờ có convention đó mà các bạn sẽ thấy việc gọi logic của hàm đó trên phía java sẽ dễ dàng hơn bao giờ hết.

Ngoài ra các bạn có thể để ý một số điểm đặc biệt ở một đoạn native code như dưới đấy:

- Giá trị trả về ở đây là jstring, đó là một kiểu dữ liệu đặc biệt của jni, mà khi phía java gọi, thư viện jni sẽ thực hiện chuyển đổi (marshalling) giá trị này về kiểu String của java.
- Biến JNIEvn* env, bạn có thể hình dung đây là một con trỏ trỏ đến VirtualMachine (Dalvik) của android, nhờ có env này mà chúng ta có thể thao tác ngược từ phía native, để có thể sử dụng được các logic phía android. Như trong đoạn code trên thì chúng ta có thể thấy nhờ có env mà chúng ta có thể tạo được một unicode string từ trong C code. 

###Step 2: Build đoạn code đó thành .so file
Để build được file native C mà chúng ta vừa viết ở trên, chúng ta cần làm 2 việc:

- Tạo 2 file Android.mk và Application.mk trong thư mục jni mà chúng ta đã nhắc đến ở trên
  - Android.mk có nhiệm vụ "miêu tả" module với hệ thống build. Trong file này chúng ta sẽ viết là module chúng ta có những file gì, path ở đâu, sử dụng những thư viện khác nào (dependency). Trong một app có thể có nhiều file Android.mk khi mà chúng ta có nhiều module.
  - Application.mk sẽ có nhiệm vụ "miêu tả" app của chúng ta với hệ thống build. Thông thường trong file này chúng ta sẽ mô tả những modules mà app sẽ dùng, cũng như là mô tả về CPU architecture mà app sẽ hỗ trợ (mà điển hình gồm có ARM, x86 và MIPS)
- Build sử dụng ndk-build hết sức đơn giản chỉ bằng việc gõ lệnh `ndk-build` ở trong folder hiện tại. 

{% img /images/ndk-2.png %}

Sau khi sử dụng lệnh ndk-build để build thì kết quả build là các file .so sẽ được copy vào thư mục **libs** ở root folder theo như hình trên đây. Các bạn có thể thấy là tương ứng với mỗi kiến trúc CPU sẽ có một folder được tạo ra, trong mỗi folder đó lại có các file .so khác nhau chỉ dùng với duy nhất một kiến trúc nhất định.

###Step 3: Viết logic code gọi native code trên java
Đã build xong thư viện tĩnh, chúng ta chỉ còn một công đoạn cuối cùng là sử dụng đoạn logic ở trên trong android code. 
Theo như ở trên đã nói, interface của jni code sẽ được sử dụng dựa theo convention mà gồm có: package name, class name và cfunction name. Điều đó có nghĩa là: đoạn code java trong android của bạn sẽ phải có package name, class name và function name y hệt như interface của jni, thì bạn mới sử dụng được logic đó.

Vậy thì theo như ví dụ của chúng ta ở đây thì chúng ta cần phải làm 3 việc:
 
- package name của đoạn code phải là com/example/hellojni
- Class name phải là HelloJni
- Bạn phải định nghĩa một hàm tên là stringFromJNI để gọi được logic từ native code.

{% codeblock HelloJni.java %}
package com.example.hellojni;

import android.app.Activity;
import android.widget.TextView;
import android.os.Bundle;

public class HelloJni extends Activity
{
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        TextView  tv = new TextView(this);
        tv.setText( stringFromJNI() );
        setContentView(tv);
    }

    public native String  stringFromJNI();

    static {
        System.loadLibrary("hello-jni");
    }
}
{% endcodeblock %}

Từ đoạn code trên chắc các bạn đã hình dung ra cách để gọi native code thế nào dựa vào hàm `System.loadLibrary("hello-jni")` và việc định nghĩa hàm thông qua directive `native`

Như vậy chúng ta đã tìm hiểu rất sơ qua về ndk. Trong phần tiếp theo, tôi sẽ đi vào phần chính mà tôi muốn nói đến, đó là giới thiệu về openssl và sử dụng openssl trên android ndk.

