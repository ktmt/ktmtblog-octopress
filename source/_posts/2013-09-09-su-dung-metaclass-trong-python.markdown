---
layout: post
title: "Sử dụng metaclass trong python"
date: 2013-09-10 16:33
comments: true
categories:
---

Bài viết này trình bày về metaclass và một số cách dùng metaclass trong Python. Để hiểu bài viết này, bạn nên có kiến thức về `magic method` trong Python. Cụ thể là các hàm `__init__`, `__new__`, `__call__`

# 1. Metaclass là gì

Trong Python, tất cả mọi thứ đều là object, là instance của một Class nào đó. Để kiểm tra class của một object, chúng ta có thể sử dụng hàm `type` hoặc thuộc tính `__class__`

{% codeblock test.py %}
>>> int(1).__class__
<type 'int'>
>>> class A: pass
    ...
>>> a = A()
>>> type(a)
<class '__main__.A'>
{% endcodeblock %}

Trong ví dụ trên, a là một instance của class A, class của a chính là A. Vậy còn kiểu của A là gì?

{% codeblock test.py %}
>>> type(A)
<type 'type'>
{% endcodeblock %}

Kiểu của A là `type`. Bởi vì mặc đinh thì class A tạo bởi hàm [`type`](http://docs.python.org/2/library/functions.html#type), với 3 tham số truyền vào

{% codeblock test.py %}
type(name, bases, dict)
    name - Tên của class sẽ được tạo ra
    bases - Tuple danh sách các parent class của class sẽ được tạo ra
    dict - Danh sách các thuộc tính của class sẽ được tạo ra
{% endcodeblock %}

Sử dụng hàm `type`, chúng ta có thể tạo ra một class mới

{% codeblock test.py %}
>>> Person = type('Person', (), {'country': 'vietnam'}
>>> Person.country
vietnam
{% endcodeblock %}

Chúng ta có thể thay đổi quá trình tạo ra class A bằng cách set thuộc tính `__metaclass__` của A. Thuộc tính `__metaclass__` là một callable object (một function, hoặc một object) nhận 3 tham số truyền vào như hàm `type` nói trên.

Khi định nghĩa một class bằng từ khoá `class`, nếu `__metaclass__` được set, metaclass sẽ được gọi sau khi các thuộc tính khác của class đã được set.

{% codeblock test.py %}
class PersonMeta(type):
    def __init__(self, name, bases, attrs):
        return super(PersonMeta, self).__init__(name, bases, attrs)

class Person(object):
    __metaclass__ = PersonMeta

    country = 'Vietnam'
    people = []

{% endcodeblock %}

`PersonMeta` sẽ được gọi với các tham số ('Person', (object), {'country': 'Vietnam', 'people': []}). Bằng cách metaclass được gọi cuối cùng, chúng ta có thể sử dụng metaclass để can thiệp vào qúa trình tạo ra class, cụ thể là các thuộc tính ở mức class của class đó. Có thể coi Metaclass là Class của class. Và class là một instance của Metaclass. Những thuộc tính của ở mức class của một class (các class attribute, các @classmethod) chính là các thuộc tính ở mức instance của một Metaclass

# 2. Giới thiệu một số trường hợp sử dụng Metaclass

Metaclass là một trong những `black magic` và rất ít khi được sử dụng trong Python.

"Metaclasses are deeper magic than 99% of users should ever worry about. If you wonder whether you need them, you don't (the people who actually need them know with certainty that they need them, and don't need an explanation about why)." -Python Guru Tim Peters"

(Tạm dịch: Metaclass sâu sắc hơn 99% những gì mà người dùng nên lo lắng. Nếu bạn phân vân khi nào bạn cần chúng, bạn sẽ không bao giờ cần (những người thực sự cần Metaclass, sẽ biết chính xác trong trường hợp nào họ cần, và không cần phải giải thích lý do vì sao)

Tuy nhiên để giúp bạn đọc hiểu rõ metaclass, trong bài viết này, tôi trình bày 2 ví dụ về cách sử dụng metaclass

## 2.1. Sử dụng metaclass để can thiệp vào việc tạo instance của class

Giả sử chúng ta có B là metaclass của A. Việc tạo ra một instance của A chính là việc gọi hàm `A(*args, **kwargs)`. Nhưng vì A là một instance của B, nên gọi A, chính là gọi hàm `__call__` của một instance của B. Do đó, để can thiệp vào quá trình tạo instance của class, chúng ta có thể override hàm `__call__` trong class B

Xét ví dụ chúng ta muốn tạo ra một Singleton class bằng Metaclass

{% codeblock singleton.py %}
class SingletonMeta(type):
    def __init__(self, *args, **kwargs):
        self._instance = None
        super(SingletonMeta, self).__init__(*args, **kwargs)

    def __call__(self, *args, **kwargs):
        if not self._instance:
            self._instance = super(SingletonMeta, self).__call__(*args, **kwargs)
        return self._instance

class Person(object):
    __metaclass__ = SingletonMeta

    def __init__(self):
        self.name = 'kiennt'
        self.age = 26

a = Person()
print a.name # kiennt
print a.age # 26
b = Person()
print b == a # True
{% endcodeblock %}

Nếu bỏ thuộc tính `__metaclass__` trong class Person, thì b sẽ không bằng a nữa

{% codeblock singleton.py %}
class Person(object):
    #__metaclass__ = SingletonMeta

    def __init__(self):
        self.name = 'kiennt'
        self.age = 26

a = Person()
b = Person()
print b == a # False
{% endcodeblock %}

## 2.2. Sử dụng metaclass để can thiệp vào các thuộc tính của một class

Hãy xem xét một ví dụ về cài đặt ORM (Object Relational Mapping)

{% codeblock orm.py %}
class Field(object):
    def __init__(self, *args, **kwargs):
        pass


class CharField(Field):
    pass


class IntegerField(Field):
    pass


class Programmer(object):
    name = CharField(max_length=100)
    age = IntegerField(default=18)
{% endcodeblock %}

Giờ nếu chúng ta muốn lưu một biến `_fields` để chứa tất cả các thuộc tính của class là một instance của `Field`, chúng ta có thể sử dụng metaclass để can thiệp

{% codeblock orm.py %}
class ModelMeta(type):
    def __new__(cls, name, bases, attrs):
        # get all Field attributes
        fields = []
        for k, v in attrs.items():
            if isinstance(v, Field):
                fields.append(v.__class__)

        ## update attrs
        attrs['_fields'] = fields
        return super(ModelMeta, cls).__new__(cls, name, bases, attrs)


class Programmer(object):
    __metaclass__ = ModelMeta

    name = CharField(max_length=100)
    age = IntegerField(default=18)


print Programmer._fields # [<class '__main__.IntegerField'>, <class '__main__.CharField'>]
{% endcodeblock %}

Chú ý rằng `__new__` là static class, nên chúng ta cần truyền `cls` vào trong lời gọi `super(ModelMeta, cls).__new__(cls, name, bases, attrs)`

Nếu không implement ở trong hàm `__new__`, chúng ta có thể implement ở trong hàm `__init__` của metaclass như sau

{% codeblock orm.py %}
class ModelMeta(type):
    def __init__(self, name, bases, attrs):
        self._fields = []
        for k, v in attrs.items():
            if isinstance(v, Field):
                self._fields.append(v.__class__)


class Programmer(object):
    __metaclass__ = ModelMeta

    name = CharField(max_length=100)
    age = IntegerField(default=18)


print Programmer._fields # [<class '__main__.IntegerField'>, <class '__main__.CharField'>]

{% endcodeblock %}

Tuy nhiên cách implement này thường it khi được sử dụng bằng cách implement thứ nhất trong hàm `__new__`, vì trong Python, hàm `__new__` thường được sử dụng để allocate object, và `__init__` được sử dụng để khởi tạo object


# 3. Kết luận
Bài viết trình bày về khái niệm metaclass và một số cách sử dụng metaclass trong python. Với metaclass, chúng ta có thể thay đổi các thuộc tính ở mức class của một class thông qua hàm `__new__` và `__init__` của Metaclass, can thiệp vào quá trình tạo ra instance của class bằng cách thay đổi hàm `__call__` của metaclass.

Metaclass là một trong những vấn đề khó và ít khi gặp trong python. Để hiểu và sử dụng metaclass một cách dễ dàng,cách ngăn nhất là code và đọc code python thật nhiều

# 4. Tham khảo

[Python Cookbook](http://www.amazon.com/Python-Cookbook-David-Beazley/dp/1449340377)

[redisco](https://github.com/kiddouk/redisco)

