---
layout: post
title: "Inversion of Control and Dependency Injection"
date: 2013-07-15 02:02
comments: true
categories: 
  - Design pattern 
  - IoC 
  - DI
  - PHP 
---


## Preface 
Trước khi đọc bài này, tôi có 1 vài recommend cho độc giả :) 

1. Bạn nên đọc trước bài viết về [Builder Pattern trong Java](http://ktmt.github.io/blog/2013/06/14/design-pattern-ap-dung-builder-pattern-trong-test-java/) cũng trong blog ktmt, sẽ có 1 cái nhìn tổng quát và hình dung dễ dàng hơn về ứng dụng của các pattern trong programming.

2. Có hàng tá bài viết về Inversion Of Control và Dependency Injection. Try to google it first. 

3. Nếu không, nhớ google thêm sau khi đọc bài viết :D  

## Dependency Injection

Chúng ta sẽ bắt đầu với 1 ví dụ gần giống ví dụ trong bài viết về Builder Pattern ở trên. Xem đoạn code sau. Ngôn ngữ ở đây là PHP.

{% codeblock  Book.php %}
<?php
class Book ()
{
    public function __construct()
    {
        $this->title = new Title;
        $this->author = new Author;
        $this->genre = new Genre;
        $this->publishDate = new PublishDate;
        $this->ISBN = new ISBN;
    }
}
...

$book = new Book;
?>
{% endcodeblock %} 

Ở đây giả sử Title, Author, Genre, PublishDate hay ISBN đều là các class đã được định nghĩa trước. Như vậy class Book có 5 **dependency** là 5 class kể trên.

Về mặt technical, chẳng có gì là không ổn với 1 class như trên cả. 
Tuy nhiên programmer có kinh nghiệm sẽ dễ dàng nhận thấy chúng ta đã hardcoded 5 dependency trên vào trong Book. 
Nói cách khác nếu muốn Book chứa những dependency khác, chẳng có cách nào khác là sửa lại định nghĩa class.

Như vậy, để tránh những phiền phức nói trên và tạo độ linh hoạt khi sử dụng, class Book nên được viết lại như sau: 

{% codeblock  Book.php %}
<?php
class Book ()
{
    public function __construct($title, $author, $genre, $publishdate, $isbn)
    {
        $this->title = $title;
        $this->author = $author;
        $this->genre = $genre;
        $this->publishDate = $publishdate;
        $this->ISBN = $isbn;
    }
}
...

$book = new Book (new Title, new Author, new Genre, new PublishDate, new ISBN)

?>
{% endcodeblock %} 

Bạn có thể thấy, ý tưởng của Dependency Injection(DI) thực ra rất đơn giản, chỉ là bạn vẫn thường sử dụng và không để ý.
Dependency có thể được inject theo nhiều kiểu, ví dụ bên trên là constructor injection.
Chúng ta còn có setter injection như sau:

{% codeblock  Book.php %}
<?php
class Book ()
{
    public function __construct()
    {
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }

...  
// Here we have 4 more methods : setAuthor ,setGenre, setPublishDate, setISBN
}
...

$book = new Book;
$book->setTitle(new Title);
$book->setAuthor(new Author);
$book->setGenre(new Genre);
$book->setPublishDate(new PublishDate);
$book->setISBN(new ISBN);

?>
{% endcodeblock %} 

Và vấn đề mới lại nảy sinh! Có quá nhiều setter và điều đó biến Book thành 1 class phức tạp khi sử dụng. 
Việc viết lại tất cả các setter khi khởi tạo 1 Book thật là painful !

Để giải quyết vấn đề kể trên, chúng ta sẽ đến với design pattern tiếp theo: Inversion of Control (IoC)

## Inversion of Control 

> In software engineering, inversion of control (IoC) is a programming technique, expressed here in terms of object-oriented programming, in which object coupling is bound at run time by an assembler object and is typically not known at compile time using static analysis. 

Giải thích lý thuyết về IoC có lẽ sẽ tốn nhiều công sức, 
như recommend trên đầu bài, bạn có thể google 1 chút về IoC. 
Ở đây tôi sẽ đưa ra luôn 1 implement để sử dụng với class Book kể trên.


{% codeblock  IoC.php %}
<?php
class IoC {
   protected static $registry = array();

   // Register
   public static function register($name, Closure $resolve)
   {
      static::$registry[$name] = $resolve;
   }

   // Resolve
   public static function resolve($name)
   {
      if ( static::registered($name) )
      {
         $name = static::$registry[$name];
         return $name();
      }
 
      throw new Exception('Nothing registered with that name, fool.');
   }

   // Check resigtered or not
   public static function registered($name)
   {
      return array_key_exists($name, static::$registry);
   }

}
?>
{% endcodeblock %} 

WTH! Cái khỉ gì trông lằng nhằng quá phải không :D 

Đừng lo lắng, để hiểu đoạn code trên trước hết hãy để ý rằng ở đây chúng ta có rất nhiều các static function. 
Static function có thể gọi trục tiếp trên class chứ không phải trên instance thông qua cách gọi "Class::StaticMethod()".
Ngoài ra Closure là 1 anonymous function. 
Bạn sẽ hiểu ngay khi xem cách dùng dưới đây 

{% codeblock  Book.php %}
<?php
IoC::register('book', function(){
    $book = new Book;
    $book->setTitle(new Title);
    $book->setAuthor(new Author);
    $book->setGenre(new Genre);
    $book->setPublishDate(new PublishDate);
    $book->setISBN(new ISBN);

    return $book;
});
...

$book = IoC::resolve('book');

?>
{% endcodeblock %} 

Woo! Bây giở mỗi khi muốn tạo 1 instance của Book với đầy đủ các dependency, chỉ cần `IoC::resolve('book')`.
Cùng với đó, các dependency có thể inject thông qua `IoC::register('book',function(){...})`. 
Đến khi unit test, bạn có thể dùng `IoC::register` để mocking các dependency và test Book mà không khởi tạo Title,Author... 


## Singleton pattern with IoC 

Bạn thử tưởng tượng, nếu như phần register 'book' bên trên chiếm nhiều tài nguyên, có thể bạn sẽ không muốn mỗi lần resolve lại khởi tạo 1 instance mới.
Nói cách khác, bạn chỉ muốn chỉ có 1 Book với đầy đủ Title, Author, ... được khởi tạo 1 lần, và lần sau muốn sử dụng thì gọi lại chính instance đã được tạo.

Đây là đất diễn của Singleton design pattern :)
Tôi sẽ thêm static function `singleton` cho IoC như sau: 

{% codeblock  IoC.php %}
<?php
class IoC {
  protected static $registry = array();
  protected static $shared = array();

  // Register, here save the Closure to static::$registry
  public static function register($name, Closure $resolve)
  {
     static::$registry[$name] = $resolve;
  }

  // Singleton, Note that here we save the result of Closure, not the Closure
  public static function singleton($name, Closure $resolve)
  {
    static::$shared[$name] = $resolve();
  }

  // Resolve, consider register or singleton here
  public static function resolve($name)
  {
    if ( static::registered($name) )
    {
      $name = static::$registry[$name];
      return $name();
    }

    if ( static::singletoned($name) )
    {
      $instance = static::$shared[$name];
      return $instance;
    } 
 
    throw new Exception('Nothing registered with that name, fool.');
  }

  // Check resigtered or not
  public static function registered($name)
  {
     return array_key_exists($name, static::$registry);
  }


  // Check singleton object or not
  public static function singletoned($name)
  {
    return array_key_exists($name, static::$shared);
  }

}
?>
{% endcodeblock %} 


Và bây giờ 
{% codeblock  Book.php %}
<?php
IoC::singleton('book', function(){
    $book = new Book;
    $book->setTitle(new Title);
    $book->setAuthor(new Author);
    $book->setGenre(new Genre);
    $book->setPublishDate(new PublishDate);
    $book->setISBN(new ISBN);

    return $book;
});
...

$book1 = IoC::resolve('book');
$book2 = IoC::resolve('book'); // exactly same instance with $book1

?>
{% endcodeblock %} 

Bạn có thể lấy [đoạn code sample trên Gist](https://gist.github.com/DTVD/5997723) về chạy thử.
Have fun with IoC :)

## Summary
* **Dependency Injection**: Đưa các dependency vào class thông qua constructor hoặc setter, không khỏi tạo trực tiếp bên trong class
* **Inversion of Control**: bind object vào thời điểm run time, không phải vào thời điểm complile time.
* **Singleton**: Design pattern, cho phép trong 1 hệ thống chỉ có 1 instance duy nhất của class được tồn tại. 


