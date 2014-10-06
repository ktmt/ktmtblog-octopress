---
layout: post
title: "Android NDK và OpenSSL(Phần 2)"
date: 2014-09-27 17:31
comments: true
categories: 
  - android
  - openssl
---

Ở [bài viết lần trước](), tôi đã nói về "hoàn cảnh" tại sao tôi lại cần sử dụng openssl trên android native, đồng thời cũng đã giới thiệu qua về cách sử dụng ndk. Ở bài viết lần này tôi sẽ nói nốt phần còn lại về cách sử dụng openssl trên android ndk. Thông qua bài viết các bạn đồng thời có thể nắm được thêm về cách sử dụng openssl nói chung, cũng như các tiện ích mà openssl mang lại.

#Giới thiệu về openssl
OpenSSL là một bộ thư viện/tiện ích dùng trong mã hoá (cryptography) viết bằng C, open source, và được sử dụng rất rộng rãi trên rất nhiều các phần mềm. OpenSSL cung cấp hầu hết các thuật toán mã hoá nổi tiếng như AES, RSA cũng như các thuật toán hash quan trọng như MD5, SHA1. 

Như cái tên của nó, OpenSSL được sinh ra chủ yếu để hỗ trợ cho việc truyên tin qua internet một cách bảo mật thông qua SSL (Secure Socket Layer) và TLS (Transport Layer Security), mà ví dụ rõ ràng nhất là việc sử dụng trên các browser hay là các web server để dành cho các kết nối https. 

Tuy nhiên OpenSSL vẫn được sử dụng rộng rãi trong nhiều hoàn cảnh khác nhau, ví dụ như khi bạn chỉ cần tính giá trị SHA1 hash, hay là muốn sử dụng một số thuật toán mã hoá đối xứng như là AES hay DES  cho các ứng dụng không quá chú trọng đến tính bảo mật.

Trong thực tế OpenSSL được sử dụng rất nhiều, ví dụ như trong git, để tính giá trị HMAC khi nhận message thông qua imap, git sẽ sử dụng openssl trong trường hợp máy client có cài đặt sẵn bộ thư viện openssl:

[https://github.com/git/git/blob/97b8860c071898d9e162678ea1035a8ced2f8b1f/imap-send.c#L861](https://github.com/git/git/blob/97b8860c071898d9e162678ea1035a8ced2f8b1f/imap-send.c#L861)

Như vậy chúng ta có thể hình dung openssl là bộ thư viện (có thể gọi là qui chuẩn) dành để làm các công việc liên quan đến mã hoá.

#Cài đặt và sử dụng openssl trên android native
OpenSSL là một bộ thư viện viết bằng C, còn android bản chất là hệ điều hành linux. Do đó việc cài đặt OpenSSL trên Android các bạn có thể hình dung tương tự như cài đặt một thư viện trên linux, cũng có make, có build, có copy file thư viện vào các đường dẫn cần thiết.

OpenSSL là một thư viện đồ sộ và khá phức tạp để build. Tuy nhiên rất may mắn là những người phát triển OpenSSL đã bỏ thời gian ra làm cho chúng ta một bản hướng dẫn cực kì đầy đủ để build từ source code và sử dụng trên android. Các bạn có thể tham khảo ở đường dẫn dưới đây:

[http://wiki.openssl.org/index.php/Android](http://wiki.openssl.org/index.php/Android)

Làm theo hướng dẫn trên sẽ giúp các bạn tạo ra được 2 file (libcrypto.so libssl.so) hoặc (libcrypto.a libssl.a) tuỳ theo setting lúc build.
File .so và file .a là các file thư viện động và tĩnh, mà các hàm trong các thư viện đó có thể được gọi trực tiếp từ C code.
Cả .so và .a file đều có thể được gọi dễ dàng chỉ bằng việc thay đổi ndk make file.
Do bản chất của ndk như đã trình bày ở [phần 1](http://ktmt.github.io/blog/2014/08/23/android-ndk-va-openssl/), từ android OS muốn gọi được logic từ C code phải thông qua JNI interface, chúng ta có thể hình dung được qui trình để sử dụng openssl trên ndk theo từng bước như sau:

- 1. Code Logic sử dụng openssl trên C, sử dụng JNI để "public" các hàm cần thiết sử dụng openssl ra ngoài.
- 2. Sử dụng file code ở trên, build ra các file thư viện native để có thể gọi được từ java code.
- 3. Gọi logic sử dụng openssl từ java code.

Ở dưới đây chúng ta sẽ lần lượt đi từng bước ở trên. Đầu tiên sẽ là việc quan trọng nhất là sử dụng openssl trên C ra sao.

#Sử dụng openssl
OpenSSL thường được sử dụng dưới dạng "utility" trên unix system, tức là bạn sẽ gọi thông qua command line, ví dụ như sau:

```bash
openssl sha1 -out digest.txt file.txt
```

Dòng lệnh trên ở trên console sẽ được sử dụng để tính hash của nội dung file digest.txt theo thuật toán SHA1, và ghi nội dung của hash vào file file.txt.

Tuy nhiên bài toán của chúng ta ở đây là cần sử dụng openssl trong "code" chứ không phải thông qua command line.
Việc sử dụng openssl trong code phức tạp hơn khá nhiều so với command line.
Lý do là các thuật toán mã hoá đều khá phức tạp, và để sử dụng trong code thì đòi hỏi hiểu biết về thuật toán mã hoá đang sử dụng sâu hơn.
Trong bài toán như tôi đã trình bày trong phần 1, chúng ta sẽ implement một thuật toán mã hoá đối xứng thông qua openssl.
Do đó trước khi bắt tay vào coding, chúng ta hãy tìm hiểu sơ qua về thuật toán mã hoá đối xứng.

##Sơ qua về thuật toán mã hoá đối xứng
Ở phần 1 đã nói sơ qua về thế nào là mã hoá đối xứng. Một cách đơn giản, thuật toán mã hoá đối xứng là khi **bên gửi và bên nhân sẽ dùng cùng một key, cùng một initialize vector**

{% img /images/symmetric_crypto.png %}

Thuật toán mã hoá đối xứng chia làm 2 loại chính: **block cipher** và **stream cipher**.

- **Block cipher** là chia dữ liệu ra thành nhiều block nhỏ, mỗi block có độ dài cố định (128bit, 256bit..) N, sau đó từng block sẽ được mã hoá riêng biệt. Nếu dữ liệu có độ dài không chia hết cho N, thì đoạn dữ liệu thừa ra sẽ được thêm vào một chuỗi ngẫu nhiên để cho bằng độ dài của N rồi cũng được tiến hành mã hoá.
- **Stream cipher** thì đơn giản hơn, đầu tiên một khoá (keystream)sẽ được tạo ra ngẫu nhiên. Sau đó dữ liệu sẽ đơn giản là được XOR với khoá đó để cho ra chuỗi mã hoá.

Stream cipher thì sẽ có tốc độ nhanh hơn rất nhiều so với Block cipher, tuy nhiên vì chỉ đơn giản thực hiện phép XOR sẽ làm Stream cipher có một số thuộc tính làm nó trở nên kém an toàn hơn so với Block cipher. Do đó trong bài toán lần này chúng ta sẽ sử dụng Block cipher.

Block cipher có khá nhiều "mode". Mỗi "mode" có thể hiểu là các cách thức tiến hành mã hoá khác nhau. Cơ bản thì sẽ có 4 loại mode dưới đây:

- ***ECB (Electronic Code Book)***: Ở mode này, 1 block của dữ liệu ban đầu (plaintext) sẽ được mã hoá thành 1 block của dữ liệu sau mã hoá (ciphertext). Mode này không tốt ở điểm dễ bị tấn công bởi dictionary attack, và là mode kém an toàn nhất
- ***CBC (Cipher Block Chaining)*** Mode này giải quyết điểm yếu dictionary attack của mode ECB thông qua việc tiến hành XOR ciphertext của block phía trước với plaintext của block tiếp theo. Việc này được tiến hành liên tiếp cho đến khi ra kết quả cuối cùng. Từ đặc điểm là việc mã hoá được tiến hành liên tiếp, chúng ta có thể thấy cần một chuỗi ngẫu nhiên để tiến hành XOR với *block đầu tiên*. Chuỗi đó được gọi là *initialization vector (IV)*. 
- CFB (Cipher Feedback) và OFB (Output Feedback) : 2 mode này dùng để biến từ block cipher thành stream cipher, do đó thường ít được sử dụng trong thực tế.

Ở bài toán của chúng ta, có thể thấy rằng CBC mode là lựa chọn tốt nhất. Việc tiếp theo là lựa chọn thuật toán mã hoá. 

Có thể kể ra một vài thuật toán mã hoá đối xứng, sử dụng BlockCipher tiêu biểu gồm có : ***AES, BlowFish, DES, TripleDES***. Trong đó AES (Advanced Encryption Standard) là thuật toán được tạo ra gần đây, có thể sử dụng key và độ dài block lên tới 256 bit. OpenSSL không hỗ trợ để sử dụng AES trên CFB và OFB.

Vậy chúng ta đã hình dung được vấn đề cần giải quyết: thông qua openssl chúng ta cần sử dụng thuật toán **AES** đễ mã hoá, thông qua **CBC mode**.


##Openssl thông qua EVP interface
Như chúng ta đã thấy ở trên, mỗi loại thuật toán mã hoá, mỗi mode đều có những con đường (routines) khác nhau để thực hiện. Do đó nếu mỗi con đường đó được thực hiện với những interface khác nhau sẽ rất khó nhớ và khó để thực hiện. Rât may mắn, OpenSSL cung cấp sẵn cho chúng ta một interface **thống nhất** cho một loạt các thuật toán mã hoá khác nhau, gọi là EVP. Thông qua EVP thì qui trình mã hoá trở nên rất đơn giản thông qua việc gọi lần lượt các hàm của EVP. Để tiến hành mã hoá

```c
EVP_CIPHER_CTX_new  //tạo EVP context
EVP_EncryptInit_ex  //Khởi tạo việc mã hoá
EVP_EncryptUpdate   //Tiến hành mã hoá
EVP_EncryptFinal_ex //Trong trường hợp có sử dụng padding, tức là thêm dữ liệu vào cuối plaintext cho đủ chiều dài chia hết cho độ dài block, thì bước này dùng để mã hoá "nốt" đoạn dữ liệu được padding đó. Bước này được dùng để kết thúc quá trình mã hoá

```

Để tiến hành giải mã chúng ta cũng dùng các hàm gần tương tự, chỉ thay Encrypt bằng Decrypt

```c
EVP_CIPHER_CTX_new
EVP_DecryptInit_ex
EVP_DecryptUpdate
EVP_DecryptFinal_ex 

```

##Coding
Sử dụng những kiến thức đã được nói ở phần trên, chúng ta đã có thể tiến hành coding. Một đoạn sample code sử dụng openssl để mã hoá đối xứng theo AES 256bit được mô tả như dưới đây. Chúng ta sẽ đặt tên file dưới đây là security.c:

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <openssl/des.h>
#include <openssl/rand.h>
#include <openssl/evp.h>
#include <openssl/aes.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <openssl/buffer.h>
#include <openssl/sha.h>
#include <jni.h>
#include <android/log.h>

#define BUFSIZE 64
void handleErrors() {
  return;
}

int encrypt(unsigned char *plaintext, int plaintext_len, unsigned char *key,
  unsigned char *iv, unsigned char *ciphertext)
{
  EVP_CIPHER_CTX *ctx;

  int len;

  int ciphertext_len;

  if(!(ctx = EVP_CIPHER_CTX_new())) handleErrors();
  if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
    handleErrors();

  if(1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len))
    handleErrors();
  ciphertext_len = len;

  if(1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len)) handleErrors();
  ciphertext_len += len;

  /* Clean up */
  EVP_CIPHER_CTX_free(ctx);

  return ciphertext_len;
}

int decrypt(unsigned char *ciphertext, int ciphertext_len, unsigned char *key,
  unsigned char *iv, unsigned char *plaintext)
{
  EVP_CIPHER_CTX *ctx;

  int len;

  int plaintext_len;

  if(!(ctx = EVP_CIPHER_CTX_new())) handleErrors();

  if(1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
    handleErrors();

  if(1 != EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len))
    handleErrors();
  plaintext_len = len;

  if(1 != EVP_DecryptFinal_ex(ctx, plaintext + len, &len)) handleErrors();
  plaintext_len += len;

  /* Clean up */
  EVP_CIPHER_CTX_free(ctx);

  return plaintext_len;
}

char *base64(const unsigned char *input, int length)
{
  BIO *bmem, *b64;
  BUF_MEM *bptr;

  b64 = BIO_new(BIO_f_base64());
  bmem = BIO_new(BIO_s_mem());
  b64 = BIO_push(b64, bmem);
  BIO_write(b64, input, length);
  BIO_flush(b64);
  BIO_get_mem_ptr(b64, &bptr);

  char *buff = (char *)malloc(bptr->length);
  memcpy(buff, bptr->data, bptr->length-1);
  buff[bptr->length-1] = 0;

  BIO_free_all(b64);

  return buff;
}

jstring Java_jp_co_common_android_libs_CryptUtils_stringFromJNI(JNIEnv* env, jobject thiz, jstring uuid) {
    char *plaintext = (*env)->GetStringUTFChars(env, uuid, 0);

    unsigned char ciphertext[1024];
    unsigned char *key = "11111111111111111111111111111111";
    unsigned char *iv = "2222222222222222";

    int ciphertext_len = encrypt(plaintext, strlen(plaintext), key, iv, ciphertext);
    __android_log_print(ANDROID_LOG_INFO, "kimisaki", "ndk: %s", base64(ciphertext, ciphertext_len));
    (*env)->ReleaseStringUTFChars(env, uuid, plaintext);
    return (*env)->NewStringUTF(env, base64(ciphertext, ciphertext_len));
}
```

Ngoài việc sử dụng các kiến thức đã nói ở trên, chúng ta có thể chú ý thấy một số điểm đặc biệt ở đoạn code trên:

- Chúng ta phải include đầy đủ các file header cần thiết của openssl như <openssl/evp.h>..
- Có thể để ý thấy việc sử dụng Base64 để encode dữ liệu trả về phía android. Lý do là sau khi mã hoá thì plaintext ban đầu sẽ trở thành 1 chuỗi bit vô nghĩa, và việc encode thành Base64 sẽ giúp dữ liệu dễ để truyền qua lại hơn, và cũng dễ debug hơn. Cách sử dụng base64 qua BIO interface các bạn có thể tìm hiểu thông qua trang chủ của openssl.
- Việc chọn **độ dài cho key và IV là vô cùng quan trọng**. Chọn sai độ dài cho key và IV sẽ dẫn đến các kết quả mã hoá không lường trước được và sẽ gây ra việc giải mã ra kết quả sai. Với AES 256 thì key sẽ có độ dài là 32 bytes, còn  iv phải có độ dài là 16 bytes.


#Kết hợp với android
Như vậy là chúng ta đã tiến hành xong công đoạn coding.
Công đoạn tiếp theo không kém phần quan trọng là việc phải build được đoạn code đó thành thư viện native để sử dụng trên android OS.
Để làm được việc đó chúng ta cần làm:

- Tổ chức cấu trúc folder sao cho hợp lý.
- Viết make file
- Build

Cấu trúc folder theo như bài viết lần đầu, chúng ta sẽ tạo 1 folder jni ở project$ROOT. Trong đó sẽ được sắp xếp như sau

{% img /images/openssl_folder_structure.png %}

Chúng ta có thể thấy điểm đặc biêt ở đây là thư mục libprebuilt sẽ chứa các file .so của openssl được build **cho từng platform** khác nhau. Hiện tại android có thể chạy trên ARM(armeabi), Intel(x86) và MIPS. Do việc build ra thư viện .so từng platform khác nhau có thể gặp khá nhiều khó khăn nên chúng ta có thể làm theo 1 cách đơn giản hơn, đó là kiếm các file .so "có sẵn" của từng platform và copy vào đây, thay vì phải build tử source. Các file này có thể kiếm được dễ dàng từ bản phân phối của các image của android OS. 

Một điểm nữa cần lưu ý là chúng ta cần copy các file header cần sử dụng của openssl vào trong thư mục dự án thì mới include được.

2 file make để build native source sẽ có nội dung như sau

- Android.mk
```
AL_PATH := $(call my-dir)

# Prebuilt libssl
include $(CLEAR_VARS)
LOCAL_MODULE := ssl
LOCAL_SRC_FILES := libprebuilt/$(TARGET_ARCH_ABI)/libssl.so
include $(PREBUILT_SHARED_LIBRARY)

# Prebuilt libcrypto
include $(CLEAR_VARS)
LOCAL_MODULE := crypto
LOCAL_SRC_FILES := libprebuilt/$(TARGET_ARCH_ABI)/libcrypto.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
```

- Application.mk
```
APP_ABI := all
```

Chúng ta có thể chú ý thấy điểm đặc biệt ở Android.mk.
Trong make file này chúng ta sẽ thấy việc chỉ định các biến build PREBUILT_SHARED_LIBRARY, LOCAL_SRC_FILE, LOCAL_MODULE để hệ thống build của ndk có thể nhận đưọc sự tồn tại của các file .so và copy vào các folder cần thiết để gọi được sau trên java code.

Để tiến hành build thì chúng ta chỉ cần vào thư mục dự án và gõ

```
ndk-build
```

Sau khi tiến hành build thì trong thư mục /libs sẽ có các thư mục tương ứng với các platform được tạo ra, và các file .so cần thiết sẽ được copy vào trong đó. File security.c ở trên sẽ được build thành các file security.so tương ứng.

Tiếp theo chỉ còn là vấn đè sử dụng các file .so trên java code:

```java
public class Foo {
   public native static String stringFromJNI(String input);

   static {
       System.loadLibrary("ssl");
       System.loadLibrary("crypto");
       System.loadLibrary("security");
   }
}

```

Chỉ với các chỉ định như trên thì chúng ta đã có thể sử dụng được hàm stringFromJNI được code trong security.c.
Khi truyền  vào 1 chuỗi bất kỳ, thì chúng ta sẽ nhận được kết quả mã hoá của chuỗi đó theo AES 256bit, với key và iv được qui định trong security.c.
Vậy là bài toán của chúng ta đã được giải quyết :D.

#Kết luận
Qua hai bài viết tương đối đầy đủ, hy vong các bạn đã nắm được:

- Cách cài đặt, sử dụng và bản chất của android ndk
- Sơ qua về mã hoá đối xứng
- Sơ qua về OpenSSL, cách sử dụng trực tiếp trên C code và cách để intergrate với android ndk

Tham khảo:

- [http://www.amazon.com/Network-Security-OpenSSL-Cryptography-Communications-ebook/dp/B0028N4W3I/ref=sr_1_2?ie=UTF8&qid=1412616205&sr=8-2&keywords=openssl](http://www.amazon.com/Network-Security-OpenSSL-Cryptography-Communications-ebook/dp/B0028N4W3I/ref=sr_1_2?ie=UTF8&qid=1412616205&sr=8-2&keywords=openssl)


