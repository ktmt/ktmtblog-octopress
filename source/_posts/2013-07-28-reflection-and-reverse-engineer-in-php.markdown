---
layout: post
title: "Reflection and reverse engineer in PHP"
date: 2013-07-28 23:45
comments: true
categories: 
  - Reflection 
  - PHP 
---

## Giới thiệu Reflection class trong PHP

Kể từ PHP 5 trở đi, Programmer PHP đã có bộ API Reflection rất hữu dụng để reverse-engineer các class, interfaces, function hay các extension.
Bài viết này sẽ giới thiệu tính năng, ý nghĩa và ứng dụng của Reflection trong PHP.

## Thế nào là dynamically-typed language ?

Cũng giống như Python hay Ruby, PHP là 1 dynamically-typed language.

Chúng ta hãy cùng xem xét 2 class sau:

{% codeblock  Author.php %}
<?php
class Author 
{
	private $name;
	private $birth;

	public function __construct($name, $birth)
	{
		$this->name = $name;
		$this->birth = $birth;
	}

	public function getName()
	{
		return $this->name;
	}

	public function getBirth()
	{
		return $this->birth;
	}

}
?>
{% endcodeblock %} 

{% codeblock  Book.php %}
<?php
class Book 
{
	private $author;
    public function setAuthor($author)
    {
		$this->author = $author; 
    }
    public function getAuthor()
    {
    	return $this->author;
    }
}

?>
{% endcodeblock %} 


2 class rất đơn giản phải không :) Book hoàn toàn có thể được setAuthor() là 1 string hay là 1 instance của class Author.

Không khó để hình dung ra kết quả của đoạn code dưới đây.

{% codeblock  sample.php %}
<?php
$book1 = new Book;
$book1->setAuthor("Nam Cao");
var_dump($book1->getAuthor());

$book2 = new Book;
$book2->setAuthor(new Author("Nam Cao","29-10-1915"));
var_dump($book1->getAuthor());
?>
{% endcodeblock %} 


Nếu chỉ dừng ở đây thì tôi với bạn chẳng có gì để nói với nhau :D 
Nhưng bạn hãy thử để ý, 1 instance của 1 class Book khi gọi đến hàm `setAuthor` hoàn toàn không có 1 khái niệm nào về `$author` cả.
Nói cách khác, $author có thể là bất cứ 1 object nào. 
Điều gì sẽ xảy ra khi tôi modify class Book 1 chút như sau:


{% codeblock  Book.php %}
<?php
class Book 
{
	private $author;
    public function setAuthor($author)
    {
		$this->author = $author; 
		var_dump($author->getName()); // Attention here! Now we try to call getName() of variable $author
    }
    public function getAuthor()
    {
    	return $this->author;
    }
}

?>
{% endcodeblock %} 

Bạn thử chạy lại đoạn code sample.php bên trên, bạn sẽ thấy $book1 trả về Fatal Error nhưng $book2 sẽ chạy qua bình thường! 

Vào thời điểm runtime $book2, PHP sẽ "inspect" object $author truyền vào cho `setAuthor` và tự hiểu $author là 1 instance của class Author và có 1 method là `getName()`.

## Reverse engineer example

Vậy PHP nói riêng và các dynamically-typed language nói chung làm thế nào để nhận biết được type của object truyền vào function hay class ?

Câu trả lời là reflection class! Bạn đã nhận ra PHP dùng reflection như thế nào qua ví dụ bên trên, bạn thậm chí có thể tự sử dụng reflection class.

{% codeblock  Book.php %}
<?php
class Book 
{
	private $author;
    public function setAuthor($author)
    {
		$this->author = $author; 
		var_dump($author->getName()); // original name
		$reflector = new ReflectionClass($author); // Here we start to inspect $author
		$authorName = $reflector->getProperty('name'); // Get local variable 'name'
		$authorName->setAccessible(true); // since 'name' is a private local variable of class Author, we need access here to modify 
		$authorName->setValue($author,'Ngo Tat To'); // now hack the 'name' of $author :))
		var_dump($author->getName()); // Guess what will be output here :D 
    }
    public function getAuthor()
    {
    	return $this->author;
    }
}


?>
{% endcodeblock %} 

Bạn thử đoán xem đoạn var_dump sau sẽ ra kết quả gì :D 

{% codeblock  Book.php %}
<?php
$book2 = new Book;
$book2->setAuthor(new Author("Nam Cao","29-10-1915"));
var_dump($book1->getAuthor()); // Suprisingly, 'Ngo Tat To' and not 'Nam Cao' here 
?>
{% endcodeblock %} 

## Reflection class dùng để làm gì ?

Đến đây có lẽ bạn đọc đã hình dung ra phần nào cách thức hoạt động của reflection class, các ngôn ngữ dynamically-typed "hiểu" các object như thế nào.
Reflection thực tế tồn tại trong PHPUnit hay các mocking framework, các code analysis framwworks hay metaprogramming.

Reflection class trong PHP là 1 tool mạnh mẽ cung cấp cho programmer chính những sức mạnh mà ngôn ngữ sở hữu.
Tuy nhiên reflection class không hề được khuyến khích dùng rộng rãi, vì với bản chất là tool của quá trình reverse engineering, nó hoàn toàn có thể làm design của hệ thống trở nên mess up và khó kiểm soát.

Reflection chỉ nên dùng khi nào thực sự cần thiết, ứng dụng nhìn thấy rõ nhất là khi bạn phải "đối đầu" với 1 project mà document ko đầy đủ hay không được upadte thường xuyên. [Cake Api Generator](https://github.com/cakephp/api_generator) là ví dụ điển hình nhất.


## Summary
* **Dynamically-typed language**: Là ngôn ngữ có thể tự hiểu được object tại thời điểm runtime, không cần tại compile time. PHP, Ruby, Python là dynamically-typed language. Ngược lại C hay Java là statically typed language.
* **Reflection Class** Là 1 bộ API được PHP cung cấp để sử dụng kỹ thuật reverse engineer, hữu dụng khi tạo document tự động.

