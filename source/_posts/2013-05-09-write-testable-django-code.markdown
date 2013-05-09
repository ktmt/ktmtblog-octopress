---
layout: post
title: "Sử dụng mock với unittest trong Python"
date: 2013-05-09 09:44
comments: true
categories:
- programming
- testing
- refactor
---

## Unittest là gì

Unit tes là các test dùng để test kiến trúc nội tại của chương trình, unit test gắn liền với
thiết kế chương trình. Khi viết unit test, tôi thường kiểm tra xem các hàm có
được gọi và gọi đúng với parameter cần thiết hay không. Mỗi một unit test chỉ
nên test 1 thứ. Đặc điểm của unit test là rất ngắn, một test case chỉ nên được
viết dưới 10 dòng. Nếu bạn cần viết hơn, hãy suy nghĩ lại về thiết kế của mình.
Các developer nên viết unit test cho các phần code mình viết. Tôi thường setup
môi trường phát triển, để bất cứ khi nào bạn commit một đoạn code, chương trình
quản lý mã nguồn sẽ chạy test tự động liên quan đến đoạn code đó. Điều này giúp
tôi kiểm tra ngay được code mình viết có gây ảnh hưởng tới các phần khác hay không.
Chính vì thế, unit test cần được chạy rất nhanh. Mỗi một đoạn code chỉ nên được
test một lần. Nếu bạn có 2 method A và B, B gọi đến A, code A đã được viết test,
 thì code test cho B không nên test lại A lần nữa

## Sử dụng mock với unittest

Tôi có một class sinh ra empty image với kích thước có sẵn, kèm theo barcode image
ở vị trí đã được định trước

{% codeblock generator/images.py %}
class BackCoverImage(object):

    BACK_COVER_IMAGE_PATH = 'assets/images/empty-barcode-image.jpg'
    BARCODE_IMAGE_SIZE = (650, 195)
    BARCODE_IMAGE_POSITION = (1925, 2300)

    def __init__(self, barcode):
        self.barcode = barcode.upper().replace('_', '-')

    @lazy
    def barcode_image(self):
        params = (
            ('cpaint_function', 'BuildBarcode'),
            ('cpaint_argument[]', self.barcode),
            ('cpaint_argument[]', 0),
            ('cpaint_argument[]', 5),
            ('cpaint_response_type', 'TEXT')
        )

        BARCODE_GENERATE_SITE = 'http://www.barcoding.com'
        BARCODE_GENERATE_URL = '%s/upc/buildbarcode.asp' % BARCODE_GENERATE_SITE
        url = BARCODE_GENERATE_URL + "?" + "&".join("%s=%s" % (k, v) for k, v in params)
        res = requests.get(url)
        image = utils.get_image_from_url(BARCODE_GENERATE_SITE + res.content)
        return image.resize(self.BARCODE_IMAGE_SIZE, Image.ANTIALIAS)

    def run(self):
        image = Image.open(self.BACK_COVER_IMAGE_PATH)
        image.paste(self.barcode_image, self.BARCODE_IMAGE_POSITION)
        return image

{% endcodeblock %}

Để sinh ra barcode, tôi connect tới một webservice và lấy dữ liệu về. Hàm `utils.get_image_from_url` trả về Image object từ content của một URL.

decorator `@lazy` biến một method của class thành property của class đó, và cached lại result, do đó nếu bạn gọi tới property lần thứ hai, bạn sẽ sự dụng lại giá trị từ trong cached

Đây là code test cho class trên

{% codeblock test_back_cover_image.py %}
import hashlib
from PIL import Image
from generator import images

class TestBackCoverImage(unittest.TestCase):
    def test_generate_image(self):
        generator = images.BackCoverImage('124124')
        image = generator.run()
        checksum = hashlib.md5(image.tostring()).hexdigest()
        self.assertEquals('efeae3cb498bbd57325991c2ac5346ad', checksum)

{% endcodeblock %}

Đoạn code trên generate BackCoverImage với một barcode xác định trước, và so sánh check sum của image được sinh ra, với image mà tôi đã sinh ra từ trước

Tuy nhiên, có vấn đề ở đây. Đó là mỗi lần tôi chạy code test, tôi sẽ phải connect tới service của `http://www.barcoding.com`. Tức là tốc độ của code test sẽ bị ảnh hưởng bởi network, hơn nữa hàm `run()` của class BackCoverImage gọi tới `barcode_image`, nếu chúng ta test như trên, thì code test không phải là một unit test, mà là một integration test. Để giải quyết vấn đề này, chúng ta sử dụng thư viện `mock`


{% codeblock test_back_cover_image.py %}
import mock
from PIL import Image
from generator import images

class PropertyMock(mock.Mock):
    def __get__(self, instance, owner):
        return self()

class TestBackCoverImage(unittest.TestCase):
    def test_generate_image(self):
        mock_barcode = PropertyMock()
        barcode_image = Image.open('StoryTree/assets/images/barcode_image.png')
        mock_barcode.return_value = barcode_image
        with mock.patch.object(images.BackCoverImage, 'barcode_image', mock_barcode):
            generator = images.BackCoverImage('storytree_124124')
            image = generator.run()
            checksum = hashlib.md5(image.tostring()).hexdigest()
            self.assertEquals('efeae3cb498bbd57325991c2ac5346ad', checksum)

{% endcodeblock %}

Tôi đã mock thuộc tính barcode_image của class BackCoverImage với `PropertyMock`.
Tốc độ của test được cải thiện đáng kể, từ 3-4s khi test không có mock, xuống < 0.3s


Xét tiếp ví dụ tiếp theo, tôi có một class Order, mỗi khi muốn order, tôi cần
sinh ra một pdf file cho class Order. Pdf file này cần có một page được sinh ra từ class `BackCoverImage`

{% codeblock order.py %}
from django.db import models
from generator import images

class Order(models.Model):
    key = models.AutoField(primary_key=True)
    ...

    def create_pdf_file(self):
        back_image = images.BackCoverImage(self.pk).run()
        ...

{% endcodeblock %}

Để test hàm `create_pdf_file`, chúng ta sẽ mock `BackCoverImage.run` với một Image
và kiểm tra xem hàm đó có được gọi hay không?

{% codeblock test_order.py %}

import mock
from PIL import Image
from generator import images
from order import Order

class TestBackCoverImage(unittest.TestCase):
    def test_generate_image(self):
        image = Image.open('StoryTree/assets/images/barcode_image.png')
        mock_backcover = mock.Mock(return_value=image)
        with mock.patch.object(images.BackCoverImage, 'run', mock_backcover):
            order = Order(pk=212)
            order.create_pdf_file()
            mock_backcover.assert_called_once_with(212)

{% endcodeblock %}

## Kết luận
Bằng việc có một bộ test để đảm bảo hệ thống đang hoạt động đúng, bạn giúp các
lập trình viên khác trong đội của bạn, hay chính bản thân bạn (sau một thời gian)
tự tin khi viết thêm/thay đổi code, mà không sợ ảnh hướng tới logic của những
chức năng khác. Điều này đặc biệt hữu ích khi bạn muốn refactor code.
Tuy nhiên để làm điều đó, bộ test của bạn cần chạy trong một thời gian ngắn.
Nếu bộ test của bọn tốn vài phút mới thực hiện xong, thì thật khó để yêu cầu các
developer khác chạy nó mỗi lần họ commit code.
Bằng cách sử dụng mock, bạn có thể isolate các unittest, đảm bảo mỗi một đoạn code
chỉ cần test duy nhất một lần, qua đó tăng tốc độ của unittest lên rất nhiều.
