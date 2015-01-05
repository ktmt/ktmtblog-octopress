---
layout: post
title: "Mở đầu về Haskell"
date: 2015-01-03 14:09
comments: true
categories: haskell, functional programming
---

Chúc mừng năm mới 2015 tới tất cả bạn đọc ktmt blog :) Chúc các bạn một năm mới coding thật productive! ^^ 

Năm mới chắc hẳn hầu hết mọi người đều có resolution của riêng mình. Một trong những resolution của tôi năm nay là học một ngôn ngữ lập trình mới, đến level có thể viết một chương trình không đơn giản với nó. (Bạn có thể tham khảo một danh sách các resolutions cho programmer ở [đây](http://matt.might.net/articles/programmers-resolutions/)). Ngôn ngữ mà tôi chọn là Haskell, một functional programming language, vì những ý tưởng trong ngôn ngữ lập trình này khác hẳn những ngôn ngữ lập trình tôi đã tiếp cận, như C/C++, Java, Python. 

Tôi mới bắt đầu với Haskell được một vài tháng, và cảm thấy khá thích thú về những ý tưởng mới mẻ của nó. Tôi sẽ bắt đầu viết chia sẻ những kiến thức tôi thu thập được trong quá trình tìm hiểu ngôn ngữ này trên ktmt. Tuy nhiên, tôi phải nói trước là Haskell khá trừu tượng, và với một beginner như tôi, việc cố diễn giải các khái niệm khó của Haskell có thể sẽ không chính xác và dễ gây hiểu lầm. Vì thế, tôi sẽ tập trung vào viết những đoạn code để giải quyết một vấn đề to hoặc nhỏ nào đó và cố giải thích chúng làm được như thế bằng cách nào. Những khái niệm khó, tôi sẽ dẫn về những bài viết nổi tiếng để bạn đọc có thể tìm hiểu thêm. 

Trong bài viết đầu tiên này, tôi sẽ hướng dẫn cách cài đặt những thành phần cơ bản để chúng ta có thể bắt đầu lập trình với Haskell. Cuối bài, sẽ có một chương trình Hello World rất đơn giản để chúng ta test xem môi trường của chúng ta đã hoàn thiện chưa.

Chú ý: Hiện tại tôi test trên máy tính của tôi (Windows 7). Tôi đã từng cài đặt môi trường trên Mac OS X và Ubuntu Linux, nhưng chưa có thời gian kiểm tra lại. Tôi sẽ thêm thông tin nếu cần thiết. 

# The Haskell Platform
Đây là cách đơn giản nhất để chúng ta có thể bắt đầu với Haskell. Trên [Homepage](https://www.haskell.org/platform/), Haskell Platform được gọi là "Haskell: batteries included". Trên homepage này, bạn có thể tải về cả package để cài đặt cho cả ba môi trường: Windows, Linux, Mac OS X. Sau khi cài đặt, bạn sẽ có rất nhiều thành phần tiêu chuẩn để bắt đầu lập trình với Haskell ([List](https://www.haskell.org/platform/contents.html)). Trong số đó, có những thành phần tiêu biểu sau:

## GHC (Glassgow Haskell Compiler)
Đây là compiler cho Haskell. 

## GHCi
Đây là GHC interactive interpreter. Nếu bạn đã từng lập trình với Python hoặc Ruby, bạn có thể coi GHCi giống như khi bạn gõ `python` (với Python) hoặc `irb` (với Ruby) trên command line. GHCi cực kì hữu dụng trong quá trình bạn viết code Haskell.

Bạn sẽ dành khá nhiều thời gian trong GHCi, nên chúng ta sẽ dành chút thời gian để config GHCi sao cho thuận tiện nhất. File config của GHCi là `.ghci`, vị trí của file này tùy thuộc vào hệ thống bạn đang sử dụng, bạn tham khảo ở đây: [GHCi dot files](https://downloads.haskell.org/~ghc/7.4.2/docs/html/users_guide/ghci-dot-files.html). Tôi tạo mới một file `.ghci` trong Home folder với nội dung: 

``` bash
:set prompt "h> "
```

Làm vậy, mỗi lần mở GHCi, prompt của bạn chỉ đơn giản là `h> ` chứ không phải là tên tất cả các module đã load (bạn hãy thử xem khác nhau như thế nào nếu không có dòng setting trên)

## Cabal  
Cabal là viết tắt của `Common Architecture for Building Applications and Libraries`. Về chức năng, nó tương tự như `pip` của Python hay `gem` của Ruby, dùng để cài đặt những package chuẩn từ `Hackage` (Haskell Central package archive). Những người viết package sử dụng `Hackage` để publish các libraries hay programs của họ, và những Haskell programmer khác sử dụng các tool như `cabal-install` để download và cài đặt các package này. 

Trên Windows 7, mỗi khi sử dụng cabal, các package sẽ được install vào `$HOME$\AppData\Roaming\cabal`. Trên Unix-based system, chúng được install vào `~/.cabal/`.

Sau đây là những thao tác đầu tiên bạn nên làm với `cabal`:

``` bash
$ cabal update
```

Dùng để update list các package phiên bản mới nhất trên `hackage.haskell.org`. 

``` bash
$ cabal install cabal-install
```

Dùng để update phiên bản `cabal-install` mới nhất

# Code Editor: Sublime Text 
Bạn có thể dùng bất cứ một text editor nào để viết code Haskell. Nếu bạn sử dụng Sublime Text, bạn nên cài plugin SublimeHaskell. Đây là plugin hỗ trợ Cabal build, error and warning highlighting, smart completion và tích hợp ghc-mod. Bạn có thể tham khảo thêm thông tin tại [GitHub repo](https://github.com/SublimeHaskell/SublimeHaskell)

# Cabal sandbox
Với Haskell, `sandbox` cho phép chúng ta build các package một cách độc lập với package environment của hệ thống, bằng cách tạo ra một package environment riêng cho project hiện tại. Nếu bạn đã quen thuộc với Python's `virtualenv` hoặc Ruby's `RVM`, `sandbox` là một khái niệm tương tự.

[Bài viết này](http://coldwa.st/e/blog/2013-08-20-Cabal-sandbox.html) trình bày khá dễ hiểu về tại sao nên sử dụng `sandbox` để tránh dependency hell, bạn có thể tham khảo thêm. Một số thao tác cơ bản với cabal sandbox gồm có: 

``` bash 
$ cd /path/to/my/haskell/project
$ cabal sandbox init                    # Init the sandbox
$ cabal install --only-dependencies     # Install dependencies into the sandbox
$ cabal build                           # Build your package inside the sandbox
```

Chú ý ở đây, cabal sandbox là một feature của cabal từ version 1.18 trở đi, cho nên sau khi init một sandbox hoàn toàn mới, các command tiếp theo (như `build` hay `install`) đều sẽ sử dụng sandbox chứ không phải package environment của hệ thống. 

# Ví dụ đầu tiên: Hello World 
Chúng ta sẽ bắt đầu với ví dụ muôn thuở khi bắt đầu ngôn ngữ lập trình mới: In ra màn hình consle dòng chữ `Hello World`. 

``` bash
$ mkdir haskell-hello-world
$ cd haskell-hello-world
$ cabal init
```

`cabal init` sẽ giúp chúng ta thêm thông tin cho project của mình, như: tên project, version, người phát triển, license,...

Tiếp theo, chúng ta edit file Cabal. Ví dụ sau khi edit, file `haskell-hello-world.cabal` của tôi có nội dung như sau: 

``` haskell

name:                haskell-hello-world
version:             0.1.0.0
synopsis:            Hello World!  
description:         Print 'Hello World' to console screen  
license:             BSD3
license-file:        LICENSE
author:              Viet Nguyen, 2015
maintainer:          viet.nguyen182@gmail.com
copyright:           Viet Nguyen 
category:            Text
build-type:          Simple
cabal-version:       >=1.10

executable haskell-hello-world
  ghc-options:         -Wall
  hs-source-dirs:      src
  main-is:             Main.hs 
  build-depends:       base >=4.7 && <4.8
  default-language:    Haskell2010

```
Một số điểm lưu ý từ file cabal trên: 

- Đặt `hs-source-dirs` là thư mục `src` để Cabal biết nơi lưu các file modules 
- Đặt `main-is` thành `Main.hs` để compiler biết đầu là main function của file binary build ra 
- `ghc-options` đặt thành `-Wall` để chúng ta có thể thấy các Warning từ GHC 
- `build-depends` là nơi khai báo các library cần sử dụng, có thể kèm theo các option về yêu cầu version. 

File code của chúng ta nằm ở `src/Main.hs` có nội dung như sau:

``` haskell
module Main where 

main = putStrLn "Hello World!"
```

Đây là một module rất đơn giản, và vì nó được dùng làm target cho `main-is`, nó phải có một function tên `main` và tên của module cũng phải tên là `Main`. Hiện tại, bạn chưa cần để ý vội đến cú pháp mà chỉ cần biết rằng chương trình in ra màn hình dòng chữ "Hello World!". (Chú ý: Có thể bạn sẽ nghĩ `putStrLn` tương tự như `printf` hay `cout` ở C/C++, nhưng với Haskell, nguyên lý sẽ khác hơn so với bạn nghĩ, nhưng đó là câu chuyện ở những bài viết sau này.)

Tiếp theo, chúng ta tạo một Cabal sandbox để chứa toàn bộ các dependencies (ví dụ Hello World này của tôi hơi trivial, vì không dùng library nào cả, nhưng vì tính đầy đủ, tôi vẫn xin trình bày về sandbox ở đây):

``` bash 
$ cabal sandbox init
```

Sau bước này, chúng ta sẽ có file `cabal.sandbox.config` chứa thông tin về package environment, và sandbox nằm ở thư mục `.cabal-sandbox`

``` bash 
$ cabal install --only-dependencies
$ cabal install
```

Nếu build thành công, bạn sẽ có file binary `haskell-hello-world` ở `dist/build/haskell-hello-world`. Thử chạy nó xem sao: 

``` bash
$ ./dist/build/haskell-hello-world/haskell-hello-world
Hello World!

```
Và chúng ta đã build thành công program đầu tiên! 

# Kết luận 
Bài viết này là bài viết đầu tiên của tôi về Haskell. Chưa có gì nhiều về syntax, idea, concept, mà chỉ là những setup ban đầu để dễ dàng bắt đầu với Haskell. Trong những bài viết tiếp theo, tôi sẽ cố gắng từng bước một trình bày các ý tưởng của Haskell một cách dễ hiểu. 

Hẹn gặp lại!
