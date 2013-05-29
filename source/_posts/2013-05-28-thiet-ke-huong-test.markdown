---
layout: post
title: "Sử dụng unittest để refactoring code"
date: 2013-05-28 16:53
comments: true
categories: unittest
---

Ở bài viết trước tôi đã đề cập đến [cách sử dụng mock để viết unittest](http://ktmt.github.io/blog/2013/05/09/mock-with-unittest-in-python/). Unittest có tác dụng không chỉ trong việc đảm bảo các đoạn code mới được viết thêm không phá vỡ các yêu cầu logic trước đó, trong bài viết này, tôi sẽ chia sẽ các kinh nghiệm sử dụng unittest để refactoring các đoạn code

Một trong những vấn đề khi viết các hàm đó là các hàm thường quá phức tạp. [Robert Martin](http://en.wikipedia.org/wiki/Robert_Cecil_Martin) trong cuốn sách "Clean code - a handbook of Agile Software Craftmenship" đã nói về nói về các quy tắc khi thiết kế hàm: Quy tắc đầu tiên của function đó là chúng nên nhỏ, quy tắc thứ hai là chúng nên nhỏ hơn thế nữa" (The first rule ò functions is that they should be small. The second rule of functions is that they should be smaller than that). Function càng ngắn thì càng dễ hiểu, function càng ngắn thì nó càng tách biệt so với các hàm khác. Và hơn thế nữa hàm càng ngắn, thì test càng đơn giản. Vậy làm thế nào để biết function bạn viết là đủ ngắn hay chưa? Nếu để test 1 hàm cần tới hơn 20 dòng code, theo bản thân tôi, hàm đó nên được viết lại.

Hãy xét một ví dụ sau

{% codeblock models.py %}

class Order(models.Model):
    # define fields in here


    def create_final_pdf_file(self, client_order_id):
        front_image = self.tree.create_frontcover_image()
        back_image = self.tree.create_backcover_image(client_order_id)

        if self.order_type == Order.SOFT_COVER:
            frontcover_file = pdf.create_pdf_from_images(
                [image_helper.save_image(front_image), None], self.book_size)
            backcover_file = pdf.create_pdf_from_images(
                [None, image_helper.save_image(back_image)], self.book_size)
            input_files = [frontcover_file, self.cached_pdf_file, backcover_file]
        elif self.order_type == Order.HARD_COVER:
            hardcover_image = self.create_hardcover_image(back_image, front_image)
            hardcover_size = self.PDF_SIZES[self.size_type]
            hardcover_file = pdf.create_pdf_from_images(
                [image_helper.save_image(hardcover_image)], hardcover_size)
            input_files = [hardcover_file, self.cached_pdf_file]

        new_path = pdf.merge_pdf_files(input_files)
        return new_path

{% endcodeblock %}

Hàm `create_final_pdf_file` nhận tham số là một `client_order_id`, tạo ra một pdf file tương ứng `client_order_id`, và trả về đường dẫn của pdf file đó. Hàm này tạo ra một ảnh cover trước, và ảnh cover sau, sau đó ghép với một file pdf có sẵn để tạo nên `final_pdf`.

Tuy nhiên tuỳ theo giá trị của `self.order_type` mà cách tạo các ảnh trước và ảnh sau là khác nhau.

Nếu chỉ dừng ở đây, bản thân tôi, thấy khá hài lòng với hàm  `create_final_pdf_file`. Hàm dài vừa đủ, không quá dài (19 lines), chỉ có một input đầu vào, và 1 output đầu ra. Tuy nhiên, nếu viết testcase cho hàm này, chúng ta sẽ thấy có vấn đề

{% codeblock test_models.py %}

class TestModel(unittest.TestCase):
    def setUp(self):
        tree = Tree()
        self.order = Order(tree=tree)

    @mock.patch('StoryTree.helpers.image_helper.save_image')
    @mock.patch('StoryTree.helpers.generator.pdf.merge_pdf_files')
    @mock.patch('StoryTree.helpers.generator.pdf.create_pdf_from_images')
    def test_create_final_pdf_file_soft_cover(
            self, mock_create_pdf, mock_merge_pdf, mock_save_image):
        self.order.order_type = Order.SOFT_COVER

        mock_cached_pdf = PropertyMock(
            return_value='StoryTree/tests/fixtures/1.pdf')
        mock_backcover = mock.Mock(return_value=image)
        mock_frontcover = mock.Mock(return_value=image)

        with nested(
                mock.patch.object(Order, 'cached_pdf_file', mock_cached_pdf),
                mock.patch.object(Tree, 'create_backcover_image', mock_backcover),
                mock.patch.object(Tree, 'create_frontcover_image', mock_frontcover)):
            self.order.create_final_pdf_file('STORYTREE01111')

            self.assertEqual(1, mock_backcover.call_count)
            self.assertEqual(1, mock_frontcover.call_count)
            self.assertEqual(2, mock_create_pdf.call_count)
            first_args = mock_create_pdf.call_args_list[0][0]
            self.assertTrue(first_args[0][-1] is None)

    @mock.patch('StoryTree.helpers.image_helper.save_image')
    @mock.patch('StoryTree.helpers.generator.pdf.merge_pdf_files')
    @mock.patch('StoryTree.helpers.generator.pdf.create_pdf_from_images')
    def test_create_final_pdf_file_hard_cover(
            self, mock_create_pdf, mock_merge_pdf, mock_save_image):
        self.order.order_type = Order.HARD_COVER

        mock_cached_pdf = PropertyMock(
            return_value='StoryTree/tests/fixtures/1.pdf')
        mock_backcover = mock.Mock(return_value=image)
        mock_frontcover = mock.Mock(return_value=image)
        mock_hardcover = mock.Mock(return_value=image)

        with nested(
                mock.patch.object(Tree, 'create_backcover_image', mock_backcover),
                mock.patch.object(Tree, 'create_frontcover_image', mock_frontcover),
                mock.patch.object(Order, 'cached_pdf_file', mock_cached_pdf),
                mock.patch.object(Order, 'create_hardcover_image', mock_hardcover)):
            self.order.create_final_pdf_file('STORYTREE01111')
            self.assertEqual(1, mock_backcover.call_count)
            self.assertEqual(1, mock_frontcover.call_count)
            self.assertEqual(1, mock_hardcover.call_count)
            self.assertEqual(1, mock_create_pdf.call_count)
{% endcodeblock %}

Đoạn code test trên có vấn đề gì? Để test hàm `create_final_pdf_file`, chúng ta cần viết 2 test case, cho 2 trường hợp trong đoạn code if-else. Và 2 đoạn code test bị lặp lại khá nhiều, đặc biệt là ở việc mock các objects. Chúng ta có thể viết lại test case gọn hơn bằng cách viết một function chung, hoặc một function tạo ra các mock object và gọi nó trong từng hàm test. Nhưng liệu có phải đó là vấn đề chính.

Điều tôi muốn nói ở đây là: Code smell trong test code có nguyên nhân từ test code, hay từ bản thân đoạn code chúng ta muốn test. Hãy xem lại hàm `create_final_pdf_file`. Hàm nãy đã thực sự tốt? Một hàm tốt, là một hàm chỉ nên làm một việc. Hàm `create_final_pdf_file` ở đây, ngoài việc gọi các hàm khác, còn thêm vào nó đoạn xử lý logic xét kiểu của `order`. Đoạn code if-else xử lý 2 logic khác nhau, chúng nên được tách ra thành một hàm khác.

{% codeblock models.py %}

class Order(models.Model):

    def create_input_files(self, front_image, back_image):
        if self.order_type == Order.SOFT_COVER:
            frontcover_file = pdf.create_pdf_from_images(
                [image_helper.save_image(front_image), None], self.book_size)
            backcover_file = pdf.create_pdf_from_images(
                [None, image_helper.save_image(back_image)], self.book_size)
            input_files = [frontcover_file, self.cached_pdf_file, backcover_file]
        elif self.order_type == Order.HARD_COVER:
            hardcover_image = self.create_hardcover_image(back_image, front_image)
            hardcover_size = self.PDF_SIZES[self.size_type]
            hardcover_file = pdf.create_pdf_from_images(
                [image_helper.save_image(hardcover_image)], hardcover_size)
            input_files = [hardcover_file, self.cached_pdf_file]
        return input_files

    def create_final_pdf_file(self, client_order_id):
        front_image = self.tree.create_frontcover_image()
        back_image = self.tree.create_backcover_image(client_order_id)
        input_files = self.create_input_files(front_image, back_image)
        new_path = pdf.merge_pdf_files(input_files)
        return new_path

{% endcodeblock %}

Hàm `create_final_pdf_file` sau khi được refactoring, đã trở nên đơn giản và dễ đọc hơn, thay vì phải lướt qua 19 lines, và đọc hiểu logic của đoạn code if-else, giờ đây bạn có thể hiểu nó chỉ bằng `create_input_files`. Và code test mới cho hàm `create_final_pdf_file` như sau

{% codeblock test_models.py %}
class TestModel(unittest.TestCase):
    def setUp(self):
        self.order = Order()

    @mock.patch('StoryTree.helpers.generator.pdf.merge_pdf_files')
    def test_create_final_pdf_file(self, mock_merge_pdf):
        mock_cached_pdf = PropertyMock(
            return_value='StoryTree/tests/fixtures/1.pdf')
        mock_backcover = mock.Mock(return_value=image)
        mock_frontcover = mock.Mock(return_value=image)
        mock_input_files = mock.Mock(return_values=[''])

        with nested(
                mock.patch.object(Order, 'create_input_files', mock_input_files)
                mock.patch.object(Order, 'cached_pdf_file', mock_cached_pdf),
                mock.patch.object(Tree, 'create_backcover_image', mock_backcover),
                mock.patch.object(Tree, 'create_frontcover_image', mock_frontcover)):
            self.order.create_final_pdf_file('STORYTREE01111')

            self.assertEqual(1, mock_backcover.call_count)
            self.assertEqual(1, mock_frontcover.call_count)
            self.assertEquals(1, mock_input_files.call_count)

{% endcodeblock %}

Việc tách logic của đoạn code tạo 2 input files ra thành một hàm `create_input_files`, làm cho hàm `create_final_pdf` dễ hiểu hơn, nói cách khác, nó che giấu thông tin không cần thiết cho lập trình viên khi đọc tới đoạn code của `create_final_pdf`.
Hàm `create_final_test` giờ đây không làm gì khác ngoại việc gọi tới các hàm khác.
Không có bất cứ logic nào được đặt trong hàm này. Trên thực tế rất nhiều lập trình viên sẽ không viết test cho những hàm như `create_final_pdf` nữa. Họ chỉ cần viết test cho 4 hàm `create_input_files`, `create_backcover_image`, `create_frontcover_image`, và `cached_pdf_file` là đủ.

Tóm lại, bạn có thể tìm kiếm code smell trong unittest, và refactoring hàm mà unittest đó muốn test
