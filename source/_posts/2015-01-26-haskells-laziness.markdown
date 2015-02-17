---
layout: post
title: "Haskell's laziness"
date: 2015-02-15 04:04
comments: true
categories: haskell, functional
---

Trong bài viết này, tôi sẽ trình bày về một đặc tính của Haskell khá khác biệt so với các ngôn ngữ lập trình khác, đó là laziness (dịch tiếng việt nôm na là "luời biếng", nhưng tôi xin đuợc giữ nguyên từ gốc tiếng anh). 

Chúng ta hiểu laziness như thế naò? `Lazy evaluation` nghĩa là, việc evaluate các đối số của hàm sẽ đuợc trì hoãn càng lâu càng tốt, chúng sẽ không đuợc evaluate cho đến khi biểu thức thực sự cần đến gía trị của chúng. Khi một biểu thức đuợc đưa làm đối số cho một hàm, nó chỉ đuợc đóng gọn lại thành một biểu thức chưa đuợc đánh gía (unevaluated expression), mà chưa đuợc tính toán gì cả. 

Chúng ta sẽ sử dụng Lecture 7 của course CIS 194 ([Link](http://www.cis.upenn.edu/~cis194/fall14/lectures/07-laziness.html)) để minh họa cho việc tìm hiểu Laziness. Bên cạnh đó, tôi sẽ trình bày qua những syntax cơ bản của Haskell theo bài viết. 

# Tính số Fibonacci

Trong bài tập thứ nhất, chúng ta sẽ viết một hàm `fib` để tính ra số Fibonacci thứ n

``` haskell
-- Exercise 1 
fib :: Integer -> Integer
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib (n-2)
```

Bên trên là điển hình của cách viết một hàm (function) trong Haskell. Truớc tiên, chúng ta có tên hàm nằm truớc dấu `::`, trong truờng hợp này là hàm `fib`. Tiếp theo, nằm sau dấu `::`, chúng ta có `Integer -> Integer`, đây chính là nơi khai báo đối số và giá trị trả về của Haskell. Trong truờng hợp này, hàm `fib` nhận đối số là Integer (số Fibonacci thứ mấy) và trả về Integer (số Fibonacci cần tìm). Tài liệu sau đây nói một cách khá đầy đủ về syntax viết function, bạn nên đọc thêm: [Syntax in Functions](http://learnyouahaskell.com/syntax-in-functions)

Sau dòng khai báo tên hàm và nguyên mẫu hàm là định nghĩa của một loạt pattern matching. Haskell sẽ match từ trên xuống duới, do vậy truớc tiên ta khai báo base case cho số Fibonacci thứ 0 và thứ 1. Các số Fibonacci tiếp theo, vì không match các base pattern nên sẽ sử dụng pattern thứ ba, cộng hai số Fibonacci phía truớc. 

Chúng ta thấy cách khai báo pattern matching khá gần gũi vớí định nghiã dãy Fibonacci chúng ta đã học. Tiếp theo, ta định nghiã một dãy Fibonacci vô hạn như sau: 

``` haskell 
fibs1 :: [Integer]
fibs1 = map fib [0..]
```

`map` là một function trong Haskell, nhận vaò hai đối số là một hàm f và một danh sách. Nó sẽ trả về một danh sách mới mà các phần từ là kết qủa trả về tuơng ứng khi áp dụng hàm f với từng phần tử trong danh sách cũ. `[0..]` là cách viết danh sách tất cả các số nguyên duơng. Như vậy, ta có `fibs1` là danh sách tất cả các số Fibonacci.

Hãy khởi động GHCi và check hàm mới này: 
``` bash 
$ ghci 
Prelude> :l HW07.hs
[1 of 1] Compiling HW07             ( HW07.hs, interpreted )
Ok, modules loaded: HW07.
*HW07> fibs1
[0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368,75025,121393,196418,
```
Bạn sẽ thấy một vài số Fibonacci đầu tiên hiện ra rất nhanh, nhưng đến một lúc nào đó, sẽ rất lâu để tính đuợc số Fibonacci tiếp theo. Lý do là vì mỗi số Fibonacci bị tính đi tính lại quá nhiều lần! 

Và đây là lúc chúng ta áp dụng Laziness của Haskell. 

``` haskell
-- Exercise 2 
fibs2 :: [Integer]
fibs2 = [0,1] ++ zipWith (+) fibs2 (tail fibs2)
```

Chúng ta đã biết dãy Fibonacci bắt đầu từ hai số 0, 1, nên ta khởi đầu khai baó dãy bằng 0,1.

Giả sử ta đã có một dãy Fibonacci vô hạn: 

```bash
[0, 1, 1, 2, 3, 5, 8, 13, ...]
```

`tail` là phép toán bỏ đi phần tử đầu tiên của một dãy:

```bash
[1, 1, 2, 3, 5, 8, 13, ...]
```

`zipWith` kết hợp 2 dãy trên theo từng cặp phần tử sử dụng một phép toán naò đó (ở đây là phép cộng):

``` bash
[0, 1, 1, 2, 3, 5, 8, 13, ...]
+ 
[1, 1, 2, 3, 5, 8, 13, ...]
= 
[1, 2, 3, 5, 8, 13, ...]
```

Như vậy, dãy vô hạn Fibonacci có thể đuợc tính bằng cách thêm hai phần tử đầu tiên (0, 1) vào kết quả sau khi zip dãy Fibonacci vô hạn với `tail` của nó! 

Và đây chính là sức mạnh của laziness! `fibs2` là kết quả trả về mà chúng ta lại có thể để xuất hiện ở bên vế phải! Haskell chỉ evaluate vế phải khi naò thực sự cần thiết, cho nên mỗi khi cần tính một phần tử mới cho dãy `fibs2`, nó mới quay ra tìm lại những phần tử đằng truớc (đã đuợc tính).

Bạn hãy thử chạy lại `fibs2` với GHCi và quan sát, số Fibonacci tuôn ra như thác lũ :) Hãy thử chỉ lấy 100 số Fibonacci ban đầu xem: 
``` bash
*HW07> take 100 fibs2
```
100 số Fibonacci đầu tiên xuất hiện trong chớp mắt! 

# Streams 

Trong phần này, chúng ta định nghĩa kiểu dữ liệu (data type) `Stream`, gần giống với `list` nhưng bị ràng buộc là *phải vô hạn*

``` haskell
data Stream a = Cons a (Stream a)
```

Bên trên là cách khai baó một kiểu dữ liệu, bắt đầu bằng từ khoá `data`. `Stream` là tên kiểu dữ liệu, tiếp sau đó đến truớc dấu `=` là `type variable`, tức là `a` có thể thay cho `Integer`, `String`, ... và ta có kiểu dữ liệu `Stream Integer` hoặc `Stream String` tuơng ứng. Phiá sau dấu `=` là constructor của kiểu dữ liệu này: `Cons`, với 2 đối số thuộc kiểu `a` và `Stream a`. Bạn hãy tham khaỏ về cách taọ kiểu dữ liệu tại [Link này](http://learnyouahaskell.com/making-our-own-types-and-typeclasses)


Hàm sau convert một stream thành list: 

``` haskell 
streamToList :: Stream a -> [a]
streamToList (Cons x s) = x : streamToList s
```

Trong exercise 4, chúng ta phải viết một instance của `Show` cho kiểu dữ liệu Stream. đến đây, chúng ta cần biết thêm về khái niệm `Typeclass` của Haskell. Typeclass có thể coi là một loại "giao diện", nó định nghĩa một số loại hành vi, và các kiểu dữ liệu mà có cùng hành vi đó có thể được khai báo là instance của typeclass đó. Lấy ví dụ, `Eq` typeclass định nghĩa một giao diện cho những thứ có thể so sánh được. Cụ thể các hành vi mà nó định nghĩa như sau: 

``` haskell
class Eq a where
    (==) :: a -> a -> Bool  
    (/=) :: a -> a -> Bool  
    x == y = not (x /= y)  
    x /= y = not (x == y)
```

Theo đó, bất cứ type nào muốn được là một instance của `Eq` typeclass sẽ phải khai báo các hàm `(==)`, `(/=)` (trên thực tế, chỉ cần khai báo một hàm, vì hàm còn lại được định nghĩa là phủ định của hàm kia). 

Ví dụ, ta có một type như sau: 

``` haskell 
data Coin = Head | Tail 
``` 

Chúng ta muốn `Coin` type là một instance của `Eq` typeclass thì ta làm như sau: 

``` haskell 
instance Eq Coin where 
	Head == Head = True 
	Tail == Tail = True 
	_ == _ = False 
```

Ở đây, chúng ta vẫn dùng pattern matching để định nghĩa hàm (==) với từng trường hợp của 2 đối số. 

Quay trở lại với exercise 4, chúng ta định nghĩa `Stream a` thành một instance của `Show` typeclass như sau: 

``` haskell
instance Show a => Show (Stream a) where 
    show s = show $ take 20 (streamToList s)
```

Chúng ta thấy sự xuất hiện của kí tự "lạ": `=>`. Trong khai báo instance, những gì xuất hiện trước dấu `=>` là những ràng buộc về type. Ở đây, chúng ta muốn `Stream a` là instance của `Show` thì bản thân `a`, một type variable, cũng phải là một instance của `Show`. Có như vậy, chúng ta mới định nghĩa được hàm `show` của `Show` typeclass cho `Stream a` dựa trên hàm `show` cho `a`.

Đến kí tự lạ tiếp theo: `$`. Đây chỉ đơn giản là một chỉ dẫn cho Haskell là tất cả những gì xuất hiện sau `$` có độ ưu tiên phép toán cao hơn, tức là `show $ take 20 (streamToList s)` tương đương với `show (take 20 (streamToList s))`. Nhưng chúng ta không muốn dùng quá nhiều dấu ngoặc, phải không :) 

Trong định nghĩa hàm `show` cho `Stream a`, chúng ta không muốn nó in hết ra vô hạn phần tử, mà chỉ muốn in ra 20 phần tử đầu tiên. Do đó chúng chuyển nó thành list bằng hàm `streamToList`, lấy 20 phần tử đầu tiên bằng `take 20` và áp dụng hàm `show` cho `List a` type (khi `a` là instance của `Show` rồi thì `[a]` cũng là instance của `Show` )

Chúng ta phải có một vài `Stream` để test. Hãy định nghĩa chúng: 

``` haskell
streamRepeat :: a -> Stream a 
streamRepeat x = Cons x (streamRepeat x)

streamMap :: (a->b) -> Stream a -> Stream b
streamMap f (Cons x s) = Cons (f x) (streamMap f s)

streamFromSeed :: (a->a) -> a -> Stream a 
streamFromSeed f x = Cons x (streamMap f (streamFromSeed f x))
``` 

`streamRepeat` tạo ra một stream chứa vô hạn các phần tử giống hệt nhau. `streamMap` áp dụng một hàm `(a->b)` lên tất cả các phần tử của một `Stream a` để nhận được một Stream mới: `Stream b`. Cuối cùng `streamFromSeed` là một cách khác để tạo ra một stream, bằng cách bắt đầu từ một "hạt giống" thuộc type `a`, cũng chính là phần tử đầu tiên của Stream, rồi liên tục sử dụng một hàm có kiểu `a->a` để tạo ra các phẩn tử tiếp theo. 

Tôi sẽ để dành phần này cho độc giả chiêm nghiệm xem tại sao lại viết như vậy.

Bây giờ, chúng ta hãy cùng test thử những gì chúng ta đã viết trong GHCi

``` bash 
*HW07> show $ streamFromSeed ('x':) "o"
"[\"o\",\"xo\",\"xxo\",\"xxxo\",\"xxxxo\",\"xxxxxo\",\"xxxxxxo\",\"xxxxxxxo\",\"xxxxxxxxo\",\"xxxxxxxxxo\",\"xxxxxxxxxxo
\",\"xxxxxxxxxxxo\",\"xxxxxxxxxxxxo\",\"xxxxxxxxxxxxxo\",\"xxxxxxxxxxxxxxo\",\"xxxxxxxxxxxxxxxo\",\"xxxxxxxxxxxxxxxxo\",
\"xxxxxxxxxxxxxxxxxo\",\"xxxxxxxxxxxxxxxxxxo\",\"xxxxxxxxxxxxxxxxxxxo\"]"
*HW07> show $ streamRepeat "o"
"[\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\",\"o\"]"
*HW07> show $ streamMap (+ 1) (streamRepeat 0)
"[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]"
```

Như vậy ta đã có một số hàm để làm việc với `Stream`, ta sẽ thử định nghĩa dãy số tự nhiên bằng `Stream` như sau: 

``` haskell 
nats :: Stream Integer
nats = streamFromSeed (+ 1) 0 
```

Test trong GHCi: 
``` bash
*HW07> show nats
"[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]"
```

Ví dụ tiếp theo: Tính ruler function f(n) = số mũ lớn nhất của 2 là ước số của n. Bình thuờng chúng ta sẽ nghĩ đến việc chia 2 cho đến khi lẻ thì thôi. Nhưng tôi sẽ trình bày một lời giải khác, sử dụng laziness và cấu trúc dữ liệu vô hạn của Haskell. 

Thay vì tính từng f(n) một, chúng ta sẽ xây dựng hẳn cả dãy số `ruler` f(n) với n bắt đầu từ 1: `0,1,0,2,0,1,0,3,0,1,0,2,0,1,0,4...`, trong đó phần tử thứ n trong stream là số mũ lớn nhất của 2 là ước số của n. 

Dễ thấy có thể coi dãy trên là trộn xen kẽ của hai dãy, một dãy toàn 0 (vì tuơng ưng với n lẻ nên số mũ lớn nhất của 2 chỉ là 0) và dãy còn lại tuơng ứng với n chẵn. điều kì diệu là dãy thứ hai bao gồm chính các phần tử của dãy `ruler` nhưng cộng thêm 1 (Bạn thử suy nghĩ xem tại sao). Vì thế mà ta có cách khai báo `ruler` là một `Stream Integer` rất đẹp như sau: 

``` haskell
interleaveStreams :: Stream a -> Stream a -> Stream a
interleaveStreams (Cons x1 s1) ~(Cons x2 s2) = Cons x1 (Cons x2 (interleaveStreams s1 s2))

ruler :: Stream Integer
ruler = interleaveStreams (streamRepeat 0) (streamMap (+ 1) ruler)
```

Lại thêm một kí tự lạ: tilde sign `~`! Tôi đã thêm nó vào truớc đối số thứ hai của `interleaveStreams`. Kí tự này dùng để báo hiệu compiler đừng evaluate đối số thứ hai này. Nếu không có kí tự `~`, pattern matching của hàm `interleaveStream` sẽ phải evaluate đối số thứ hai để đảm bảo nó thuộc type `Stream a`. đó không phải là điều chúng ta muốn, vì hàm `ruler` gọi hàm `interleaveStream` với đối số thứ hai chứa `ruler`, tức là gọi đệ quy vô hạn lần. Nếu đối số thứ hai của `interleaveStream` không lazy, hàm này sẽ dừng mãi ở việc evaluate để phục vụ pattern matching. 

Nói nôm na, thêm dấu `~` truớc một đối số là chúng ta đã bảo với compiler là: "đừng lo, tôi đảm bảo đối số này sẽ có kiểu Stream a, nên đừng evaluate làm gì" :) 

# Kết luận 

Bài viết này đã trình bày một số ví dụ để minh họa lazy evaluation của Haskell. Nó cho phép ta làm việc với những kiểu cấu trúc dữ liệu *vô hạn*, một pattern khá thuờng gặp trong Haskell. Việc định nghiã một cấu trúc dữ liệu vô hạn thực chất chỉ taọ ra một biểu thức chưa đuợc evaluate, mà ta sử dụng nó để chỉ ra cấu trúc dữ liệu hoàn chỉnh "có thể" phát triển đến như thế naò, và chỉ phần naò cần thiết mới đuợc tính toán. 

Tuy nhiên, chủ đề laziness là một chủ đề khá phức tạp, đặc biệt khi chúng ta muốn đánh giá time và space của program. Có khá nhiều bài viết trên mạng về vấn đề này, một trong số đó bạn có thể tham khảo thêm là: 

* [How Lazy Evaluation Works in Haskell](https://hackhands.com/lazy-evaluation-works-haskell/)
