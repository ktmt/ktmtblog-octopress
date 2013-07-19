--- 
layout: post 
title: "Apache Avro: An Introduction" 
date: 2013-07-17 22:38 
comments: true 
categories: 
---

## 1. Serialization

Trước khi tìm hiểu về Avro, chúng ta cần nắm được serialization là gì. Theo [wiki](http://en.wikipedia.org/wiki/Serialization), Serialization là quá trình chuyển các cấu trúc dữ liệu và các đối tượng thành một định dạng có thể lưu trữ được (vào file, in-memory buffer, hoặc truyền qua network), sau đó có thể phục hồi lại các cấu trúc dữ liệu và đối tượng như ban đầu, trên cùng hoặc khác môi trường.

Tác dụng của Serialization gồm có: 
- đồng nhất hóa các đối tượng, để có thể lưu các thuộc tính của nó vào ổ cứng, hoặc cơ sở dữ liệu
- dùng cho Remote procedure call (RPC)

Trong một số ngôn ngữ lập trình như Java, Ruby, Python, PHP, các ngôn ngữ .NET,..., Serialization được hỗ trợ trực tiếp. Bên cạnh đó, còn có những framework riêng cho Serialization, có thể kể đến: [Google's Protocol Buffers](https://developers.google.com/protocol-buffers/), [Apache Thrift](http://thrift.apache.org/), và Apache Avro.

## 2. Tại sao dùng Apache Avro?

Nếu sử dụng các phương pháp serialization của từng ngôn ngữ (ví dụ như với Java, ta cần định nghĩa một class implement *Serializable class*), ta gặp phải vấn đề mất language portability: dữ liệu được serialize ra sẽ chỉ đọc được bởi ngôn ngữ tạo ra nó mà thôi! Apache Avro đã khắc phục nhược điểm này, vì đây là một hệ thống data serialization không phụ thuộc ngôn ngữ (language-neutral). Bằng cách xây dựng một định dạng dữ liệu có thể được nhiều ngôn ngữ xử lý, Avro đã giúp chia sẻ dataset với nhiều đối tượng sử dụng ngôn ngữ khác nhau hơn.

Nếu nói về language-neutral, thì Google's Protocol Buffers và Apache Thrift cũng làm được như vậy. Vậy tại sao lại có thêm Apache Avro?

Những hệ thống này có đặc điểm chung là data được mô tả bằng *schema*, không phụ thuộc ngôn ngữ lập trình. Tuy nhiên, Protocol Buffers và Thrift cần phải có C++ compiler để tạo ra các implementation tương ứng với từng ngôn ngữ lập trình. Quá trình này gọi là code generation. Còn đối với Avro, quá trình code generation chỉ là option, nghĩa là ta có thể đọc và ghi dữ liệu luôn theo một *schema* cho trước, kể cả code của ta chưa từng thấy schema đó bao giờ. Để làm được điều này, schema luôn xuất hiện kèm với data đã được serialized, ở cả lúc đọc và ghi. Cách mã hóa này rất gọn nhẹ, vì giá trị đã encode không cần phải tag cùng với các field identifier như Protocol Buffer.

## 3. Avro Data Types và Schemas

Lý thuyết tổng quan về Avro là như vậy, giờ ta hãy chuyển sang thực hành cho dễ hiểu. Chúng ta cùng bắt đầu bằng một ví dụ đơn giản. Định nghĩa một schema trong file *Person.avsc* như sau:

{%codeblock Person.json %}

{ "namespace": "edu.rutgers.vietnguyen", 
"type": "record", 
"name": "Person", 
"fields": [ 
	{"name": "name", "type": "string"},
	{"name": "age", "type": "int"}, 
	{"name": "address", "type": "string"} 
] }

{%endcodeblock %}

Ta thấy, schema này được định nghĩa bằng JSON:

- namespace, cùng với thuộc tính name, tạo ra full name của schema này. - type: ở đây là thuộc loại record. 

- name: tên của schema này. 

- fields: chỉ ra các trường trong record này (gồm có 3 trường name, age, address).

Avro cung cấp một số primitive types như sau: null, boolean, int, long, float, double, byte, và string. Ngoài ra còn có các complex types: record, enum, array, map, union, fixed.

Ở ví dụ này, để đơn giản, ta chỉ sử dụng 2 type là string và int.

Có file định nghĩa schema rồi, trong Java, chuyển thành đối tượng Schema như sau:

{%codeblock schema.java %} 
	public static Schema makeSchema() throws IOException
	{	
		Schema.Parser parser = new Schema.Parser();
		Schema schema = parser.parse(new File("Person.avsc"));
		return schema;
	}
{%endcodeblock %}

## 4. Đọc và ghi dữ liệu Avro

Trước tiên, ta xem xét cách đọc và ghi dữ liệu với Java trước:

{%codeblock readwriteavro.java %}
public static GenericData.Record makeObject(Schema schema, String name, int age, String address)
	{
		GenericData.Record record = new GenericData.Record(schema);
		record.put("name", name);
		record.put("age", age);
		record.put("address", address);
		return(record);
	}
	
	public static void testWrite(File file, Schema schema) throws IOException
	{
		GenericDatumWriter<GenericData.Record> datum = new GenericDatumWriter<GenericData.Record> (schema);
		DataFileWriter<GenericData.Record> writer = new DataFileWriter<GenericData.Record>(datum);
		
		writer.create(schema, file);
		writer.append(makeObject(schema, "Alex", 24, "MI"));
		writer.append(makeObject(schema, "Betty", 25, "NJ"));
		writer.append(makeObject(schema, "Carol", 26, "WA"));
		writer.close();
	}
	
	public static void testRead(File file) throws IOException
	{
		GenericDatumReader<GenericData.Record> datum = new GenericDatumReader<GenericData.Record>();
		DataFileReader<GenericData.Record> reader = new DataFileReader<GenericData.Record>(file, datum);
		
		GenericData.Record record = new GenericData.Record(reader.getSchema());
		while(reader.hasNext())
		{
			reader.next(record);
			System.out.println("Name: " + record.get("name") + ". Age: " + record.get("age") + ". Address: " + record.get("address") );
			
		}
		reader.close();
	}
 
	public static void main(String[] args) {
		try
		{
			Schema schema = makeSchema();
			File file = new File("test-person.avro");
			testWrite(file,schema);
			testRead(file);
		}
		catch(IOException e)
		{
			e.printStackTrace();
		}

	}
{%endcodeblock %}

Output:

{%codeblock output  %} 
Name: Alex. Age: 24. Address: MI
Name: Betty. Age: 25. Address: NJ
Name: Carol. Age: 26. Address: WA
{%endcodeblock %}

Có vài lưu ý trong đoạn code trên:

- Ghi dữ liệu: *DatumWriter* dùng để chuyển đối tượng Java thành định dạng in-memory serialized. Ta cần có schema truyền vào đối tượng GenericDatumWriter, để biết ghi dữ liệu theo schema nào. Schema này ta có thể đọc ra từ file avsc, như trên đã trình bày. Sau đó, ghi đối tượng đã serialized cùng với schema vào datafile bằng cách sử dụng *DatumFileWriter*.

- Đọc dữ liệu: vì đặc điểm của Avro Datafile là nó chứa luôn schema trong metadata của nó, do vậy khi đọc file, không cần chỉ ra schema mà lấy trực tiếp từ file cần đọc: *reader.getSchema()*

Định dạng của Avro Datafile: gồm phần header chứa metada, bao gồm Avro schema và sync marker, tiếp theo là một dãy block chứa các Avro object đã serialize. Các block này được ngăn cách bởi sync marker.

## 5. Đa ngôn ngữ

Như trên đã trình bày, Avro datafile là language-neutral, nghĩa là có thể chia sẻ giữa nhiều ngôn ngữ lập trình khác nhau. Ở đây, xin trình bày ví dụ đọc file *test-person.avsc* ở trên bằng Python:

(Chú ý: phải install Avro implementation của Python theo hướng dẫn tại
[...](http://avro.apache.org/docs/current/gettingstartedpython.html))

{%codeblock avroReader.py %} 
import avro.schema
from avro.datafile import DataFileReader, DataFileWriter
from avro.io import DatumReader, DatumWriter

reader = DataFileReader(open("test-person.avro", "r"), DatumReader())
for user in reader:
    print user
reader.close()

{%endcodeblock %}

Chạy file *avroReader.py*, ta có output: 
{%codeblock output %} 

{u'age': 24, u'name': u'Alex', u'address': u'MI'} 
{u'age': 25, u'name': u'Betty', u'address': u'NJ'} 
{u'age': 26, u'name': u'Carol', u'address': u'WA'} 

{%endcodeblock %}

Tương tự, đối với các ngôn ngữ khác (Ruby, PHP, các ngôn ngữ .NET...) , bằng cách sử dụng các Avro implementation tương ứng, việc đọc/ghi Avro datafile cũng dễ dàng tương tự như vậy.

## 6. Tóm tắt

Bài viết đã trình bày những bước căn bản để làm quen với Apache Avro. Trong bài viết tiếp theo, tôi sẽ trình bày cách sử dụng Avro trong hệ thống RPC (Remote Procedure Call) như thế nào.

## 7. Tham khảo

1. [Hadoop: The Definitive Guide](http://www.amazon.com/Hadoop-Definitive-Guide-Tom-White/dp/1449311520/ref=sr_1_1?ie=UTF8&qid=1374205297&sr=8-1&keywords=hadoop+guide)
2. [Avro homepage](http://avro.apache.org/) 
3. [Schema evolution in Avro, Protocol Buffers and Thrift](http://martin.kleppmann.com/2012/12/05/schema-evolution-in-avro-protocol-buffers-thrift.html)
