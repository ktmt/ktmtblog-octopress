---
layout: post
title: "Tutorial: Duplicate file finder (Java)"
date: 2013-06-30 09:07
comments: true
categories: java, programming, thread, hash 
---

#Mở đầu

Trong quá trình dọn dẹp máy tính cá nhân, tôi gặp phải vấn đề là quá nhiều file trùng lặp trong máy tính. Việc có quá nhiều file như vậy gây lãng phí ổ cứng, cộng thêm đôi lúc tôi không còn nhớ là file này đặt ở thư mục này có ý nghĩa gì nữa. Giá mà có công cụ nào đó để tìm tự động các file này cho tôi thì tốt quá nhỉ?? 

Không cần phải giá mà nữa, không gì bằng làm ra cho mình một công cụ như vậy. Bài viết này sẽ trình bày những bước đầu tiên tôi prototype công cụ tìm kiếm các file trùng lặp. Thông qua bài viêt này, tôi cũng sẽ giới thiệu về những chủ đề sau trong Java: tính hash, thread pooling.  

#MD5 checksum

MD5 là một thuật toán mã hóa thông điệp (message-digest), về bản chất là một hàm băm (hash) xuất ra một giá trị 128-bit (16-byte). MD5 được sử dụng rất nhiều trong các ứng dụng bảo mật, và cũng được sử dụng để kiểm tra tính toàn vẹn dữ liệu (ví dụ như bạn down một file từ Internet về, thường có một MD5 key đi kèm, để bạn kiểm tra xem file bạn down có chính xác giống nguồn down không.)

Tôi không có ý định đi sâu vào cách tính MD5, bạn có thể tham khảo trên google. Lưu ý là thuật toán MD5 vẫn có thể sinh ra cùng một giá trị hash với 2 file có nội dung khác nhau (tuy nhiên trường hợp này rất hiếm). Để chắc chắn tìm được 2 file có nội dung giống hệt nhau, ta sẽ so sánh theo thứ tự: so sánh giá trị hash, so sánh độ lớn của file, và cuối cùng là so sánh từng byte của hai file để chắc chắn chúng trùng nhau. 

Trong Java, hàm băm đã được đưa vào thư viện *java.security*, thông qua class *MessageDigest*. Bạn chỉ cần khai báo đối tượng *MessageDigest*, sau đó chọn phương thức mã hóa MD5, hoặc SHA. Việc bạn phải làm đối với từng file là chuyển file thành byte stream, và update dòng input này vào đối tượng *MessageDigest* trên, và bạn sẽ nhận được một dòng byte kết quả. 
 
Chi tiết về class *MessageDigest*, bạn có thể tham khảo tại đây: [http://docs.oracle.com/javase/6/docs/api/java/security/MessageDigest.html](http://docs.oracle.com/javase/6/docs/api/java/security/MessageDigest.html)

{%codeblock MD5.java %}
	public static String getMD5(File file) 
	{
		if(!file.exists())
			return "";
		try
		{
			MessageDigest  md =  MessageDigest.getInstance("MD5");

			//read the file into a byte array
			byte[] input = new byte[(int) file.length()];
			InputStream in = new FileInputStream(file);
			in.read(input);
			in.close();
			
			//update the MessageDigest and process
			md.update(input);
			byte[] fileDigest = md.digest();
			
			return ByteArrayToString(fileDigest);
		}
		catch(IOException e )
		{
			e.printStackTrace();
			return "";
		}
		catch(NoSuchAlgorithmException e)
		{
			return "";
		}
	}
	
	private static String ByteArrayToString(byte[] ba)
	{
	   StringBuilder sb = new StringBuilder();
	   for(byte b: ba)
	      sb.append(String.format("%02x", b&0xff));
	   return sb.toString();
	}
{%endcodeblock %}
  
#Theading

Threading, hay concurrency, trong Java là một chủ đề khá phức tạp và tôi cũng chưa đủ khả năng nắm rõ được tất cả. Do vậy, trong bài viết này, tôi xin chỉ đề cập đến kĩ thuật thread pooling để phân bài toán ra thành nhiều tác vụ, chạy trên nhiều luồng khác nhau. 

Thread pool là gì? Bạn có thể hiểu nôm na là thay vì cứ gọi một luồng mới cho từng tác vụ khi cần thiết (phương pháp này gặp nhược điểm vì việc tạo thread mới sẽ gặp overhead), ta tạo sẵn một cái "bể" (pool) trong đó khởi động sẵn một loạt các luồng (thread). Các luồng này ngoi ngoi lên để đợi ta ném tác vụ vào để chúng thực hiện. Sau khi thực hiện xong, nó sẽ báo cáo lại kết quả, kết thúc tác vụ, và quay trở lại "bể" để tiếp tục ngoi ngoi chờ tác vụ mới. Chỉ khi nào đóng "bể", thì các luồng mới bị mất đi. 

Trong bài toán tìm file trùng lặp này, tôi sẽ áp dụng thread pooling như sau:

- Tạo một class DuppFind, implement Runnable class (đây là class ta có thể truyền vào cho pool), đại diện cho tác vụ tìm kiếm. Với mỗi object DuppFind, nó sẽ được truyền vào các tham số gồm có:

-- Thư mục bắt đầu tìm kiếm

-- Map<String, List<String>>: là một map chứa key là md5 và value là một List chứa đường dẫn đến các file có md5 value như vậy 

-- pool, thuộc class ExcutorService.

- Mỗi tác vụ sau khi được luồng chọn để thực thi, nó sẽ làm gì? Nhiệm vụ của tác vụ là quét tất cả các file, thư mục có trong thư mục được chỉ định tìm kiếm. Nếu gặp file, nó sẽ tính MD5 cho file đó, và thêm vào Map. Nếu gặp thư mục, tác vụ này sẽ tạo ra một tác vụ DuppFind mới, chỉ định thư mục mới này cho tác vụ DuppFind mới, và ném vào pool (bây giờ bạn đã hiểu tại sao object DuppFind luôn được truyền pool vào rồi đấy:) ) 

Một vài điểm lưu ý: 

- Mỗi tác vụ phải có trách nhiệm đợi tất cả các tác vụ con nó tạo ra hoàn thành thì mới được chấm dứt. Tôi thực hiện điều này bằng cách sử dụng đối tượng Future được trả lại mỗi lần ném tác vụ mới vào pool. Sau đó chỉ cần gọi polling kết quả từ tác vụ con là được. 

- Với những Collection dùng chung giữa các thread, cần phải dùng những Concurrecy Collection mà Java cung cấp. Cụ thể ở đây, tôi dùng ConcurrentHashMap cho Map và CopyOnWriteArrayList cho List. 

Dưới đây là đoạn code cho phần thread pooling: 

{%codeblock DuppFind.java %}
public class DuppFind implements Runnable{
	private File directory;
	private Map<String, List<String>> md5FileMap;
	private ExecutorService pool;
	
	public DuppFind(File directory, Map<String, List<String>> md5FileMap, ExecutorService pool)
	{
		this.directory = directory;
		this.md5FileMap = md5FileMap;
		this.pool = pool;
	}	

	@Override
	public void run () {
		try
		{
			File[] files = directory.listFiles();
			ArrayList<Future<?>> results = new ArrayList<Future<?>>();
			for(File file : files)
			{
				if(file.isDirectory())
				{
					//System.out.println("Dir: " + file.getAbsolutePath());
					DuppFind df = new DuppFind(file, md5FileMap, pool);
					Future<?> result = pool.submit(df);
					results.add(result);
				}
				else if(file.isFile())
				{
					//calculate md5
					String md5 = MD5Utils.getMD5(file);
					List<String> listFile = new CopyOnWriteArrayList<String>();
					if(md5FileMap.get(md5) != null)
					{
						System.out.println("Duplicate md5: " + md5 + ", size now: " + md5FileMap.get(md5).size());
						listFile.addAll(md5FileMap.get(md5));
					}
					listFile.add(file.getAbsolutePath());
					md5FileMap.remove(md5);
					md5FileMap.put(md5, listFile);
					System.out.println("Add: File" + file.getAbsolutePath() + ", MD5: " + md5);
				}
			}
			
			//wait until all sub-tasks complete
			for(Future<?> result: results)
			{
				result.get();
			}
		}
		catch(InterruptedException e)
		{
			e.printStackTrace();
		}
		catch(ExecutionException e)
		{
			e.printStackTrace();
		}
	}
}
{%endcodeblock %}

Toàn bộ code đã ở trên github: [https://github.com/viethnguyen/DuppFind](https://github.com/viethnguyen/DuppFind)     

#Đánh giá

- Đoạn code trên chạy chính xác với những thư mục nhỏ, không có quá nhiều thư mục con, cháu... Tuy nhiên, với những thư mục chứa nhiều thư mục con, vì có quá nhiều tác vụ vào thread pool, nên hay xảy ra exception out of memory - heap. 

- Mới chỉ kiểm tra xem 2 file có MD5 trùng nhau không. Nếu trùng nhau rồi, ta cần kiểm tra thêm độ dài 2 file có trùng nhau không, rồi nếu trùng tiếp thì phải check từng byte để chắc chắn nhất có thể (xóa đi khỏi hối hận :P) 

- Ở trên mới hiển thị ra những file nào trùng lặp. Cần cho phép user xóa file trùng lặp trong chương trình.

- Cần thiết kế GUI! 

Bạn thấy đó, còn khá nhiều vấn đề cần giải quyết để có một tool hoàn chỉnh. Những vấn đề này sẽ được cải tiến và được report lại trong một ngày không xa :) Nếu bạn cảm thấy hứng thú, rất welcome contribute :)  

#Tham khảo
1. Core Java
2. Java Concurrency in Practice
3. Effective Java 
