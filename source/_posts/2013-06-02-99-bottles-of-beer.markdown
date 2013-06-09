---
layout: post
title: "99-bottles-of-beer"
date: 2013-06-02 19:47
comments: true
categories: 
  - Web programming 
  - PHP 
  - Code golf 
---


## The song, and the home page ##

Đầu tiên có thể độc giả sẽ tự hỏi ý nghĩa của tiêu đề bài viết là gì ? Vậy trước hết mời bạn ghé qua [home page][] và enjoy the [song][] 

99-bottles-of-beer cũng từng là đề bài của code golf và phpgolf. Mission của chúng ta là code 1 đoạn PHP snippet print [lyric][] của bài hát mà dung lượng đoạn code là nhỏ nhất.
Logic thật đơn giản phải không :D

{% codeblock lyric%}
99 bottles of beer on the wall, 99 bottles of beer.
Take one down and pass it around, 98 bottles of beer on the wall.

98 bottles of beer on the wall, 98 bottles of beer.
Take one down and pass it around, 97 bottles of beer on the wall.

97 bottles of beer on the wall, 97 bottles of beer.
Take one down and pass it around, 96 bottles of beer on the wall.

...

1 bottle of beer on the wall, 1 bottle of beer.
Go to the store and buy some more, 99 bottles of beer on the wall.
{% endcodeblock %}

Với mục tiêu dùng ít code nhất có thể, tôi sẽ không dùng cấu trúc rẽ nhánh if-else, thay vào đó là ternary operator của PHP 
( có nghĩa là bạn có thể viết "(condition)?true-action:false-action" thay vì "if (condition) {true-action} else {false-action}"  ) 

Đoạn code đầu tiên tôi nghĩ ra trong đầu như sau:

{% codeblock sol1.php %}
<?php
  $a="beer on the wall";
  for($i=99;$i>=1;$i--){
    $x=($i==1)?"bottle":"bottles";
    $b="<p>$i $x of $a, $i $x of beer.<br>";
    $b.=($i==1)?"Go to the store and buy some more, 99 bottles of $a.":"Take one down and pass it around, ".($i-1)." $x of $a.</p>";
  print $b;
}
?>
{% endcodeblock %}

## Optimize ##

Bạn thử ls -l sẽ thấy đoạn code trên có dung lượng 288 bytes! 

Để rút ngắn đoạn code trên, đầu tiên tôi nhớ lại những kiến thức cơ bản về PHP: dấu space hoàn toàn không cần thiết, và ký tự "?>" ở cuối cũng có thể bỏ đi
PHP long tag ở đầu có thể thay = PHP short tag 


{% codeblock sol2.php %}
<?
$a="beer on the wall";
for($i=99;$i>=1;$i--){
$x=($i==1)?"bottle":"bottles";
$b="<p>$i $x of $a, $i $x of beer.<br>";
$b.=($i==1)?"Go to the store and buy some more, 99 bottles of $a.":"Take one down and pass it around, ".($i-1)." $x of $a.</p>";
print $b;
}
{% endcodeblock %}


263 bytes! 

Làm thế nào để rút ngắn hơn nữa ? Nếu để ý vào những chi tiết nhỏ hơn, bạn sẽ thấy:

* trong điều kiện vòng lặp, thay "$i>=1" bằng "$i>0"
* "($i==1)?" là quá dài. Ta có thể bỏ đi 2 dấu ngoặc "$i==1?"
* print có thể thay bằng echo. ( Thực tế trong PHP bạn còn có thể thay rtrim -> chop, explode -> split, implode -> join, preg_split -> split (trong 1 vài trường hợp) và preg_replace -> preg_filter trong hầu hết các TH  )
*  "$x=($i==1)?"bottle":"bottles";" có thể được viết lại : "$x='bottle';$i==1?:$x.='s';"
* Mỗi lần sử dụng biến $a ta đều có "of" ở đăng trước. Vậy có thể đơn giản cho word "of" vào trong biến a
* "99 bottles of $a" có thể rewrite tiếp lại thành "99{$x}s of $a"
* Chúng ta có thể xoá "$i--" trong vòng lặp for, vì thế thêm -- vào trước "$i==1" ở dòng gần cuối thành "$i--==1" và vì thế bỏ luôn đoạn ($i-1) ở sau đó 



Như vậy solution tiếp theo của chúng ta sẽ là 
{% codeblock sol2.php %}
<?
$a=" of beer on the wall";
for($i=99;$i>=1;){
$x='bottle';$i==1?:$x.='s';
$b="<p>$i $x$a, $i $x of beer.<br>";
$b.=$i--==1?"Go to the store and buy some more, 99 {$x}s$a.":"Take one down and pass it around, ".$i." $x$a.</p>";
echo $b;
}
{% endcodeblock %}

241 bytes! 

## The trick ##

Bạn có nghĩ đã hết cách để rút gọn đoạn code ?

Bạn có quên điều gì không ? Bỏ đi tất cả các ký tự line-feed (line break), cho code thành 1 dòng, chúng ra sẽ có kết quả tốt hơn.

{% codeblock sol4.php %}
<?$a=" of beer on the wall";for($i=99;$i>0;){$x='bottle';$i^1?$x.='s':0;$b="<p>$i $x$a, $i $x of beer.<br>";$b.=$
i--==1?"Go to the store and buy some more, 99 {$x}s$a.":"Take one down and pass it around, ".$i." $x$a.</p>";echo
 $b;}
{% endcodeblock %}


233 bytes! 

Bạn có tin có 1 đoạn code sẽ cho kết quả tương tự với ... 30 bytes ???

!!

{% codeblock trick.php %}
<?include('http://bit.ly/xxxx'); ?>
{% endcodeblock %}

PHP là 1 ngôn ngữ web! Với allow_url_fopen và allow_url_include turn on có thể dễ dàng load 1 link kết quả có sẵn đi kèm 1 dịch vụ như bitly ! 

Stay hungry, stay foolish :D 
 

## Tham khảo 

1. [phpgolf tips and tricks][]
2. [Question on StackOverFlow][]


[lyric]: http://99-bottles-of-beer.net/lyrics.html
[home page]: http://99-bottles-of-beer.net
[song]: http://www.youtube.com/watch?v=qVjCag8XoHQ
[phpgolf tips and tricks]: http://www.phpgolf.org/tips
[Question on StackOverFlow]: http://stackoverflow.com/questions/3801097/solve-this-php-puzzle-in-as-few-bytes-as-possible
