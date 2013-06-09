---
layout: post
title: "WeakHashMap và Weak reference trong Java"
date: 2013-06-02 08:06
comments: true
categories: 
- programming
- java
- garbage collector
---

#Giới thiệu 

Trong thư viện Collection của Java, có một lớp đặc biệt: **WeakHashMap**. Về hoạt động nói chung nó rất giống với **HashMap**, đều có chức năng quản lý key, value như thêm, bớt, truy xuất value theo key... Vậy khác biệt của **WeakHashMap** so với **HashMap** là gì? Đó chính là khả năng phối hợp của **WeakHashMap** với garbage collector nhằm loại bỏ khả năng leak memory có thể xảy ra với **HashMap**. Trong bài viết này, chúng ta sẽ tìm hiểu **WeakHashMap** là gì, cách hoạt động của nó như thế nào, và cách nó xóa bỏ những entry không dùng đến ra sao. 

#Mở đầu

Thử tưởng tượng một tình huống như thế này: bạn muốn sử dụng một class nào đó, nhưng không thể extend được nó (ví dụ trường hợp đơn giản nhất là class đó được chỉ định là **final**). Vậy bạn làm gì khi muốn thêm property cho object thuộc class đó? 

Ví dụ, bạn muốn sử dụng một class **Product** mà không thể extend được. Bây giờ muốn thêm **serialNumber** cho product đó, ứng cử viên hàng đầu là HashMap, bạn có thể tạo một cặp **key** là Product object, **value** là serialNumber:

{%codeblock product.java %}
import java.util.HashMap;
...
Map<Product, String> productMap = new HashMap<Product,String>();
...
productMap.put(product, serialNo);
...
{%endcodeblock %} 

Đoạn code trên có vẻ đã hoàn thành mục tiêu thêm thuộc tính cho Product object, nhưng có vấn đề gì ở đây không? Cách giải quyết này gặp phải vấn đề liên quan đến việc giải phóng bộ nhớ. Vì **HashMap** sử dụng **strong reference** để trỏ đến Product object, nên khi trong chương trình không còn reference nào đến Product object nữa, **garbage collector** nhận thấy vẫn còn strong reference ở trong **HashMap**, nên nó không giải phóng object này nữa. Lâu dần, sẽ xuất hiện hiện tượng **Leak Memory**: ta không thể giải phóng được cặp key, value nằm trong **HashMap**, khi mà **HashMap** còn được sử dụng (để hiểu rõ hơn, bạn có thể xem ví dụ demo ở cuối bài). 
 
Nhân đây, xin giải thích thêm về **Strong reference**. Đây là Java reference bình thường mà ta thường sử dụng. Như ví dụ sau: 
{%codeblock strong.java %}
String serialNo = new String();
{%endcodeblock %}

sẽ tạo một object String và lưu một strong reference đến nó vào biến serialNo. Ta cần phải để ý mới quan hệ giữa strong reference và garbage collector như sau: Nếu một object được trỏ đến qua một số strong references, object đó sẽ không được garbage collector để ý đến.  

#WeakHashMap

Trái ngược lại với **strong reference** là **weak reference**. *Weak reference** sẽ không thể cản trở garbage collector giải phóng object khỏi memory. Khai báo như sau: 

{%codeblock weak.java %}
WeakReference<Product> weakProduct = new WeakReference<Product>(product);
{%endcodeblock %} 

Sau đó, ta có thể truy cập đến Product object thông qua việc gọi method weakProduct.get(). Tuy nhiên, ta cần phải chú ý khi gọi method này. Vì weak reference không đủ khả năng chặn quá trình garbage collection, nên đến một cycle nào đó, garbage collector sẽ giải phóng Product object (khi không còn strong reference nào đến nó) , và bạn sẽ thấy weakProduct.get() đột nhiên trả về null. 

Quay trở lại với ví dụ Product ở trên, ta giải quyết vấn đề đã nêu bằng cách sử dụng **WeakHashMap** class.  **WeakHashMap** hoạt động y hệt như **HashMap**, chỉ khác là key được refer đến bằng **weak reference**. Lúc này, khi một object chỉ reachable bởi **WeakReference**, garbage collector sẽ giải phóng object, đồng thời sẽ đặt **weak reference** trỏ đến object kia vào một queue. WeakHashMap sẽ định kì kiểm tra queue này xem có weak reference nào mới đến không. Nếu thấy một weak reference trong queue, nghĩa là key đã không được ai sử dụng nữa và nó đã bị garbage collector "tịch thu". Lúc đó, WeakHashMap sẽ bỏ entry liên quan đi. No more memory leak ! :) 

#Demo

Lý thuyết là vậy. Để dễ hiểu hơn, quan sát đoạn demo WeakHashMap sau: 
{%codeblock WeakHashMapDemo.java %}
package corejava.collection;

import java.util.Map;
import java.util.WeakHashMap;

public class WeakHashMapTest {

	public static void main(String[] args) {
		
		//add one element to the map...
		Map<Data, String> map  = new WeakHashMap<Data, String>();
		Data someDataObject = new Data("test");
		map.put(someDataObject, someDataObject.value);
		System.out.println("map contains someDataObject ? " + map.containsKey(someDataObject));
		
		//now make someDataObject eligible for garbage collection...
		someDataObject = null;
		
		for (int i = 0; i < 1000000; i++){
			if(map.size()!=0)
			{
				System.out.println("At iteration " + i + " the map still holds the reference on someDataObject");
			}
			else
			{
				System.out.println("someDataObject has finally been garbage collected at iteration " + i + ", so the map is now empty");
				break;
			}
			
		}
	}

	static class Data{
		String value;
		Data(String value){
			this.value = value;
		}
	}
}

{%endcodeblock %}

Chạy đoạn code trên: kết quả như sau: 

{%codeblock output %}
map contains someDataObject ? true
At iteration 0 the map still holds the reference on someDataObject
At iteration 1 the map still holds the reference on someDataObject
...
At iteration 29574 the map still holds the reference on someDataObject
someDataObject has finally been garbage collected at iteration 29575, hence the map is now empty
{%endcodeblock %}
 thay **WeakHashMap** bằng **HashMap**, kết quả sẽ như thế nào? 

{%codeblock output %}
map contains someDataObject ? true
At iteration 0 the map still holds the reference on someDataObject
At iteration 1 the map still holds the reference on someDataObject
...
At iteration 999997 the map still holds the reference on someDataObject
At iteration 999998 the map still holds the reference on someDataObject
At iteration 999999 the map still holds the reference on someDataObject 
{%endcodeblock %}

Bạn đã thấy điểm khác biệt? Sau một khoảng thời gian, **WeakHashMap** sẽ bỏ đi entry tương ứng với weak reference. Còn **HashMap**, vì là strong reference, trong map sẽ luôn chứa cặp phần tử (someDataObject, value) mặc dù bên ngoài someDataObject đã set là null. 

#Kết luận 
Bài viết này đã trình bày tác dụng của một lớp trong Collection của Java: **WeakHashSet**. Đồng thời, bài viết cũng giới thiệu **weak reference** và **strong reference** và mối quan hệ của chúng với Java garbage collector. 

#Tham khảo
1. Core Java Volume I--Fundamentals
2. [http://docs.oracle.com/javase/6/docs/api/java/util/WeakHashMap.html](http://docs.oracle.com/javase/6/docs/api/java/util/WeakHashMap.html)

