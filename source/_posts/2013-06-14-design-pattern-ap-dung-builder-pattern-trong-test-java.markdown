---
layout: post
title: "Design Pattern: Áp dụng Builder Pattern trong test (Java)"
date: 2013-06-14 22:31
comments: true
categories: java, programming, design pattern 
---

#Giới thiệu 
Builder Pattern là một pattern trong cuốn Design Pattern của "Gang of Four". Mục đích của Builder Pattern như sau: Separate the construction of a complex object from its representation so that the same construction process can
create different representations (tạm dịch: tách rời quá trình tạo object với nội dung và cấu trúc bên trong của nó, nhờ vậy tương ứng với một quá trình tạo object có thể có nhiều cách tạo nhiều thể hiện khác nhau.) 

Bên cạnh đó, Builder pattern còn được dùng để giải quyết một vấn đề thường gặp trong quá trình test: cách nào tốt nhất để tạo những object có quá nhiều optional parameters, trong khi tạm thời một số parameter ta muốn để giá trị default, giá trị của parameter này không ảnh hưởng gì lắm đến algorithm hay flow của chương trình. Bài viết này sẽ trình bày phương pháp sử dụng Builder pattern này.   

#Ví dụ 
Ta lấy ví dụ ta có một class quản lý sách, với các trường như sau: tiêu đề, tên tác giả, thể loại, năm xuất bản, ISBN. Để phục vụ việc tạo một object thuộc class này, ta nghĩ đến việc tạo một constructor như sau: 
{%codeblock constructor.java %}
	public Book(String title, String author, Genre genre, GregorianCalendar publishDate, String ISBN)
	{
		this.title = title;
		this.author = author;
		this.genre = genre;
		this.publishDate = publishDate;
		this.ISBN = ISBN;
	}
{%endcodeblock %}

Và trong chương trình, để tạo một object Book, ta gọi: 
{%codeblock constructor.java %}
Book book2 = new Book("Core Java", "Cay Horstman", Genre.TECHNOLOGY, new GregorianCalendar(2012,12,7), "0137081898");
{%endcodeblock %}

Ta thấy, với cách tạo object như trên, có một số nhược điểm như sau: 

- Ta bắt buộc phải khai báo tất cả các parameters, không có giá trị default. Ta sẽ bị buộc phải set cả những parameters mà ta không quan tâm khi thực hiện test object. 

- Đoạn code khá khó hiểu khi ta chỉ khai báo giá trị của parameter và truyền vào constructor. Người đọc sẽ phải đếm vị trí của parameters, soi vào trong khai báo constructor của Book.java để biết giá trị này là gán cho parameter nào. Với ví dụ trên, chỉ có 5 parameter, nhưng với những class phức tạp có nhiều parameters hơn nữa, việc khai báo như trên rõ ràng không tốt về mặt code visibility. 

- Xuất hiện nhu cầu tạo object với các constructor với bộ tham số đầu vào khác nhau. Như ví dụ ở trên, ta muốn tạo object nhưng không muốn nhập thể loại, hoặc không muốn nhập năm xuất bản, ... dẫn đến rất nhiều phiên bản constructor khác nhau. 

Hoặc bạn có thể khai báo theo một cách thứ hai, theo kiểu JavaBean như sau: tạo một constructor default, không đối số, ví dụ như Book(), sau đó thì tạo một loạt các setter để nhập các tham số cho parameter. Lúc đó thì code cho từng đối tượng sẽ như sau: 

{%codeblock bean.java %}
Book book = new Book();
book.setTitle("Core Java");
book.setAuthor("Cay Horstman");
book.setGenre(Genre.Technology);
book.setPublishDate(new GregorianCalendar(2012,7,1));
book.setISBN("0137081898"); 
{%endcodeblock %}

Nhưng cách này lại có nhược điểm là: vì việc tạo object bị kéo dài qua nhiều câu lệnh, có thể object sẽ bị rơi vào trạng thái unstable (ví dụ như ta quên mất set publishDate, như thế book sẽ không có giá trị cho publishDate !). 
 
Để khắc phục những nhược điểm trên, có một phương pháp sử dụng Builder pattern như sau: Thay vì tạo object mong muốn trực tiếp, ta gọi một static factory với các tham số bắt buộc, nhận về một *builder object*. Sau đó gọi các setter method dể đặt các tham số tùy chọn. Cuối cùng gọi build method, tạo ra object. Để dễ hiểu hơn, ta quan sát ví dụ sau:  

{%codeblock builder.java %}
public class Book {
	public enum Genre {FICTION, NONFICTION, TECHNOLOGY, SELFHELP, BUSINESS, SPORT};
	
	private String title;
	private String author;
	private Genre genre;
	private GregorianCalendar publishDate;
	private String ISBN;
	
	public static class Builder
	{
		//required params
		private String title;
		private String author;
		
		//optional params
		private Genre genre = Genre.FICTION;
		private GregorianCalendar publishDate = new GregorianCalendar(1900,1,1);
		private String ISBN = "000000000";
		
		public Builder(String title, String author)
		{
			this.title = title;
			this.author = author;
		}
		
		public Builder genre (Genre val)
		{
			this.genre = val;
			return this;
		}
		
		public Builder publishDate(GregorianCalendar val)
		{
			this.publishDate = val;
			return this;
		}
		
		public Builder ISBN(String val)
		{
			this.ISBN = val;
			return this;
		}
		
		public Book build()
		{
			return new Book(this);
		}
	}
	
	public Book(Builder builder)
	{
		title = builder.title;
		author = builder.author;
		genre = builder.genre;
		publishDate = builder.publishDate;
		ISBN = builder.ISBN;
	}
	
	@Override
	public String toString()
	{
		return "Title: " + title + ", author: " + author + ", genre: " + genre.toString() + ", publish year: " 
					+ publishDate.get(Calendar.YEAR) + ", ISBN: " + ISBN;
	}
	
}
{%endcodeblock %}

Lúc đó ta có thể tạo Book object bằng cách sau: 
{%codeblock builder.java %}
		Book book = new Book.Builder("Effective Java", "Joshua Bloch")
						.publishDate(new GregorianCalendar(2008,05, 28))
						.build();
{%endcodeblock %}

Ta thấy, cách tạo object này có ưu điểm hơn so với cách dùng constructor thông thường: 

- Không cần phải khai báo những parameter nào mà ta tạm thời chưa quan tâm. Những parameters đó sẽ nhận giá trị default. Trong ví dụ trên, ta đã bỏ qua khai báo cho genre và ISBN. Chúng sẽ nhận giá trị default: genre = FICTION, ISBN = "0000000000". 

- Ta thấy rõ là giá trị nào là gán cho parameter nào. Ví dụ: publishDate(new GregorianCalendar(2008,05, 28)) là gán giá trị cho parameter ngày xuất bản. 
- Thứ tự của các method là không quan trọng. Ta có thể gọi các method để update thêm các giá trị cho các parameter theo thứ tự tùy ý. Object sẽ chưa được tạo cho đến khi gọi build(). Do vậy, builder rất dễ sử dụng và giúp ta tránh khỏi những sai lầm không mong muốn đối với thứ tự parameter. 

#Kết luận 
Bài viết đã giới thiệu cách sử dụng Builder Pattern để việc tạo object trong quá trinh test được dễ dàng hơn, đồng thời khiến đoạn code được sáng sủa hơn về mặt trình bày.  

#Tham khảo 

- Effective Java - Joshua Bloch 

- Design Patterns - Elements of Reusable
