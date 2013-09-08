---
layout: post
title: "Giới thiệu về python descriptor"
date: 2613-09-08 11:30
comments: true
categories:  python
---

Trong các bài viết trước, chúng tôi đã giới thiệu về các kiến thức cơ bản trong python, như [object trong python](/blog/2613/04/29/python-object-model/), [decorators](/blog/2613/05/06/memoization-and-decorator/).

Bài viết này sẽ giới thiệu một kỹ nâng cao trong Python, đó là `descriptor`

# 1. Ví dụ về descriptor

Xét ví dụ khi chúng ta muốn xây dựng mô hình cho bài toán về các lập trình viên

{% codeblock programmer.py %}
class Programmer(object):
    def __init__(self, name, age, salary, rating):
        self.name = name
        self.age = age
        self.salary = salary
        self.rating = rating
{% endcodeblock %}

Giờ nếu bạn muốn thêm một điều kiện là tuổi của lập trình viên phải luôn lớn hơn 0, bạn có thể cài đặt như sau

{% codeblock programmer.py %}
class Programmer(object):
    def __init__(self, name, age, salary, rating):
        self.name = name
        self.salary = salary
        self.rating = rating

        if age > 0:
            self.age = age
        else:
            raise ValueError("Negative value not allowed: %s" % age)
{% endcodeblock %}

Tuy nhiên với cách làm này, bạn vẫn có thể làm cho `age` < 0, nếu gán giá trị của `age` trực tiếp từ instance của Programmer

{% codeblock %}
>>> kiennt = Programmer('kiennt', 26, 500, 5)
>>> kiennt.age = -10
{% endcodeblock %}

May mắn thay, ta có thể sử dụng `property` để giải quyết vấn đề này

{% codeblock programmer.py %}
class Programmer(object):
    def __init__(self, name, age, salary, rating):
        self._age = None # tạo một thuộc tính private cho age

        self.name = name
        self.age = age
        self.salary = salary
        self.rating = rating

    @property
    def age(self):
        return self._age

    @age.setter
    def age(self, value)
        if age > 0:
            self._age = age
        else:
            raise ValueError("Negative value not allowed: %s" % age)

{% endcodeblock %}

{% codeblock python %}
>>> kiennt = Programmer('kiennt', 26, 500, 5)
>>> try:
        kiennt.age = -10
    except ValueError:
        print "Cannot set negative value"
Cannot set negative value
{% endcodeblock %}

Cách chúng ta làm ở đây đó là tạo ra một biến private `_age` để chứa giá trị thật của `age`. Và sử dụng @getter và @setter để bind thuộc tính `age` với 2 method. Trong 2 method này, chúng ta sẽ cài đặt logic cho việc gán trị của `age`. Khi chúng ta gọi `kiennt.age = value`, python sẽ tự động gọi đến setter của `age`, còn nếu chỉ gọi `kiennt.age` (không có gán giá trị), thì getter sẽ được gọi.

# 2. Vấn để của getter và setter

Nếu giờ, chúng ta cũng muốn kiểm tra giá trị của hai thuộc tính `salary` và `rating`. Chúng ta có thể làm tương tự như sau

{% codeblock programmer.py %}
class Programmer(object):
    def __init__(self, name, age, salary, rating):
        self._age = None # tạo một thuộc tính private cho age
        self._salary = None # tạo một thuộc tính private cho salary
        self._rating = None # tạo một thuộc tính private cho rating

        self.name = name
        self.age = age
        self.salary = salary
        self.rating = rating

    @property
    def age(self):
        return self._age

    @age.setter
    def age(self, value)
        if age > 0:
            self._age = age
        else:
            raise ValueError("Negative value not allowed: %s" % age)

    @property
    def salary(self):
        return self._salary

    @age.setter
    def salary(self, value)
        if salary > 0:
            self._salary = salary
        else:
            raise ValueError("Negative value not allowed: %s" % age)

    @property
    def rating(self):
        return self._rating

    @age.setter
    def rating(self, value)
        if rating > 0:
            self._rating = rating
        else:
            raise ValueError("Negative value not allowed: %s" % age)
{% endcodeblock %}

Tuy nhiên cách làm này làm cho code của chúng ta có qúa nhiều đoạn code lặp về logic. Đây chính là lúc `descriptor` có thể sử dụng.

# 3. Descriptor

Descriptor cho phép chúng ta bind cách xử lý truy cập của một thuộc tính trong class A với một class B khác. Nói cách khác, nó cho phép đưa việc truy cập thuộc tính ra ngoài class. Sau đây là cách cài đặt đối với bài toán của chúng ta


{% codeblock programmer.py %}
class NonNegativeDescriptor(object):
    def __init__(self, label):
        self.label = label

    def __get__(self, instance, owner):
        return instance.__dict__.get(self.label)

    def __set__(self, instance, value):
        instance.__dict__[self.label] = value


class Programmer(object):
    age = NonNegativeDescriptor('age')
    salary = NonNegativeDescriptor('salary')
    rating = NonNegativeDescriptor('rating')

    def __init__(self, name, age, salary, rating):
        self.name = name
        self.age = age
        self.salary = salary
        self.rating = rating

{% endcodeblock %}

{% codeblock python %}
>>> kiennt = Programmer('kiennt', 26, 500, 5)
>>> print kiennt.age
>>> kiennt.age = 20
{% endcodeblock %}

NonNegativeDescriptor là một descriptor vì class này cài đặt 2 phương thức `__get__` và `__set__`.  Python nhận ra một class là descriptor nếu như class đó implement một trong 3 phương thức.

+ `__get__`: Nhận 2 tham số `instance` và `owner`. `instance` là instance của class mà Descriptor được bind tới. `owner` là class của `instance`. Trong trường hợp, không có `instance` nào được gọi, `owner` sẽ là None.
+ `__set__`: Nhận 2 tham số `instance` và `value`. `instance` có ý nghĩa như trong `__get__`, value là giá trị muốn set cho thuộc tính của `instance`
+ `__delete__`: Nhận 1 tham số `instance`

Trong class `Programmer`, chúng ta tạo ra 3 Descriptor ở mức class là `age`, `salary` và `rating`.
Khi gọi `print kiennt.age`, python sẽ nhận ra age là một descriptor, nên nó sẽ gọi đến hàm `__get__` của descriptor `NonNegativeDescriptor.__get__(kiennt, Programmer)`. Tương tự khi gán giá trị cho `kiennt.age = 20`, hàm `__set__` của descriptor cũng được gọi `NonNegativeDescriptor.__set__(kiennt, 20)`.

Nếu chúng ta gọi `Programmer.age`, thì hàm `__get__` sẽ được gọi với `owner` = None.


# 4. Descriptor và Metaclass
Một điểm cần lưu ý đó là trong descriptor, có sử dụng biến label để bind giữa descriptor và thuộc tính của class. Ta có thể sử dụng Metaclass để giải quyết vấn đề này


{% codeblock programmer.py %}
class NonNegativeDescriptor(object):
    def __init__(self, label=None):
        self.label = label

    def __get__(self, instance, owner):
        return instance.__dict__.get(self.label)

    def __set__(self, instance, value):
        instance.__dict__[self.label] = value

class DescriptorMeta(type):
    def __new__(cls, name, bases, attrs):
        for k, v in attrs.items():
            if isinstance(v, NonNegativeDescriptor):
                v.label = k
        return super(DescriptorMeta, cls).__new__(cls, name, bases, attrs)

class Programmer(object):
    age = NonNegativeDescriptor()
    salary = NonNegativeDescriptor()
    rating = NonNegativeDescriptor()

    def __init__(self, name, age, salary, rating):
        self.name = name
        self.age = age
        self.salary = salary
        self.rating = rating

{% endcodeblock %}

Metaclass hoạt động như thế nào, sẽ được giới thiệu trong bài viết tiếp theo.

# Kết luận

Bài viết này giới thiệu với các bạn về descriptor trong Python. Với descriptor, chúng ta có thể chuyển việc can thiệp vào từng thuộc tính của một instance trong class tới việc can thiệp vào thuộc tính ở mức class. Cùng với metaclass, descriptor được sử dụng như một `ma thuật đen` (black magic) trong metaprogramming. Descriptor được sử dụng rất nhiều khi xây dựng các bộ thư viện về ORM (django ORM, peewee, redisco)

# Tham khảo

 + [Python Descriptors Demystified](http://nbviewer.ipython.org/urls/gist.github.com/ChrisBeaumont/5758381/raw/descriptor_writeup.ipynb)

 + [Python 3 Metaprogramming](http://dabeaz.com/py3meta/Py3Meta.pdf)


