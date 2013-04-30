---
layout: post
title: "Python object model"
comments: true
categories:
  - programming
  - python
---

### 1. old-style và new-style class trong Python
Bạn đã nghe ở đâu đó "In python everything is object".

Điều đó có nghĩa là gì? Liệu nó có giống các ngôn ngữ lập trình khác,
mọi thứ trong Python đều là instance của BaseClass? Tôi đã nghe về **object**
class trong Python, liệu đó có phải là Base Class của Python

Python có hai mô hình **old-style** và **new-style**. Thực tế trong các phiên bản cũ của Python, không có một class cụ thể nào cho mọi object cả. Nhưng từ Python 2.2, với sự giới thiệu của **new-style** class, chúng ta có thể biến mọi object là instance của **object**

Từ Python 2.1 trở về trước, **old-style** class là lựa chọn duy nhất cho các lập trình viên. Khái niệm **old-style** class là không liên quan tới khái niệm kiểu. Nếu x là một instance của old-style class, x.__class__ sẽ trỏ tới class của x, nhưng type(x) thì không.

{% codeblock python.py %}
# old-style class was define by statement:
#   class <class-name>: <class definition body>
>>> class A:
        pass
# type of class A is 'type' because 'type' is base-class in Python
>>> type(A)
<type 'type'>

# make an instance of A
>>> a = A()
# a.__class__ reference to class A
>>> a.__class__
<class __main__.A at 0x10aea6ce8>
# bute type of a is not A but 'instance'
>>> type(a)
<type 'instance'>
# 'instance' still is 'type' class
>>> type(type(a))
<type 'type'>
{% endcodeblock %}

**new-style** class được giới thiệu với động lực tạo ra một mô hình object thống nhất cho Python. Mọi đối tượng sẽ được kế thừa từ **object**

{% codeblock python.py %}
>>> object.__class__
<type 'type'>
>>> type(object)
<type 'type'>
{% endcodeblock %}

**new-style** class được định nghĩa bằng cách kế thừa từ **object** class.
Khác với **old-style** class, nếu x là một instance của **new-style** class, cả x.__class__ và type(x) đều trỏ về class của x

{% codeblock python.py %}
>>> class A(object): pass
>>> A.__class__
<type 'type'>
>>> x = A()
>>> x.__class__
>>> type(x)
<type 'A'>
{% endcodeblock %}

Để tương thích với các phiên bản của của Python, class mặc định vẫn được để ở **old-style**.
Nếu chúng ta muốn sử dụng **new-style**, chúng ta bắt buộc phải định nghĩa class là subclass của **object**

### 2. Điểm khác biệt giữa **old-style** và **new-style** class

Điểm khác biệt rõ nhất được nhìn thấy trong hệ thống kiểu.
Hãy xem làm thế nào **old-style** class và **new-style** class thực hiện việc đa kế thừa. "Đa kế thừa" là khả năng một class có thể kế thừa từ nhiều class khác nhau. Nếu A kế thừa từ B, A là subclass(child class, derived class) của B, còn B là superclass (base class, parent class của A)

Đa kế thừa cho phép một class A có thể có nhiều cha (theo tôi, đa kế thừa không thực sự tốt. có nhiều cách để giải quyết vấn đề đa kế thừa, hãy xem Ruby với mixins hay Java với interface thực hiện điều đó. tôi thực sự rất thích mô hình mixins của Ruby)

Trong mô hình object của Python, mọi class đều có thuộc tình **__bases__** để lưu lại tất cả các class cha của nó, theo thứ tự xuất hiện của việc thừa kế.

{% codeblock python.py %}
>>> class A: pass
>>> class B: pass
>>> class C(A, B): pass
>>> C.__bases__
(<class __main__.A at 0x10aea6ce8>, <class __main__.B at 0x10af8de20>)
{% endcodeblock %}

Vấn đề của đa kế thừa đó là thự tự của các superclass.

Khi một instance của một subclass truy cập vào một thuộc tính (hoặc một method),
    đầu tiên, nó sẽ tìm kiếm các thuộc tính được định nghĩa trong không gian của nó.
    Nếu thuộc tình (hoặc method) không được tìm thấy, nó sẽ tìm đến không gian
    của class (thuộc tính của class, hàm của class). Nếu vẫn không tìm thấy, nó
    sẽ tìm kiếm tiếp trong không gian của các super class. Khi một class có nhiều
    super class, thứ tự của các super class chính là thứ tự khi tìm kiếm

Trong **old-style** class, thứ tự của các superclass là depth-first, left-to-right
theo thứ tự xuất hiện trong bases list

{% codeblock python.py %}
>>> class A:
      def test(self): print "A"
>>> class B(A):
      def test(self): print "B"
>>> class C(A)
      def test(self): print "C"
>>> class D(B, C): pass
# order of D.__bases__ is (B, C) so D.test => B.test
>>> D().test()
"B"
>>> class E(C, B): pass
# order of E.__bases__ is (C, B) so E.test => C.test
>>> E().test()
"C"

# so what if we make an class is inherited from D, E
# note that, D and E are inherited from 2 class B, C with reverse order
>>> class F(D, E): pass
# in old-style class, it does not matter, the searching method
# only care about order of superclass in __bases__
# so now F.test => D.test => B.test
>>> F().test()
"B"

# even if we make an class is inherited from A, D, E
# it still works and test() method will be test() method of A
>>> class G(A, D, E): pass
>>> G().test()
"A"
{% endcodeblock %}

Cách phân giải method của **old-style** khá đơn giản và dễ hiểu. Nhưng nếu chúng
ta áp dụng quy luật này, đôi khi chúng ta sẽ phạm phải sai lầm khi kế thừa.
Giả sử, một class G được kế thừa từ A, D và E, trong khi A là parent class của D và E.
Rõ ràng, một lỗi nên được Python ném ra trong trường hợp này để bảo về việc kế thừa vòng tròn như vậy

**new-stlye** giải quyết vấn đề này. **new-style** sử dụng MRO (Method Resolution Order) được giới thiệu từ Python 2.3

{% codeblock python.py %}

def mro(cls):
    """
    Return ordering of superclass of cls
    This ordering was used when we want to access class instance atrribute

    `cls`: class type we want to resolve

    @raise `TypeError` if cannot resolution superclass order
    @return `list` of class
    """
    bases_cls = cls.__bases__
    mro_base_lists = [mro(base_cls) for base_cls in bases_cls]
    mro_list = [cls]
    while mro_base_lists:
        # find the good head
        # good head is head of a list which is not is tail of any list in mro_base_lists
        list_head = (x[0] for x in mro_base_lists)
        set_tails = set()
        for x in mro_base_lists:
            set_tails.update(x[1:])

        good_head = None
        for head in list_head:
            if head not in set_tails:
                good_head = head
                break

        # if cannot find good_head, raise TypeError
        if not good_head:
            raise TypeError
        else:
            # add to mro_list
            mro_list.append(good_head)

            # remove good_head in all list and add to mro_list
            for alist in mro_base_lists:
                try:
                    alist.remove(good_head)
                except Exception:
                    pass
            mro_base_lists = [x for x in mro_base_lists if x]
    return mro_list

class A: pass
class B(A): pass
class C(A): pass
class D(B, C): pass
class E(C, B): pass
class F(D, E): pass

def test_mro():
    assert mro(A) == [A]
    print "Test1 passed"

    assert mro(B) == [B, A]
    print "Test2 passed"

    assert mro(C) == [C, A]
    print "Test 3 passed"

    assert mro(D) == [D, B, C, A]
    print "Test 4 passed"

    assert mro(E) == [E, C, B, A]
    print "Test 5 passed"

    try:
        mro(F)
    except Exception as e:
        assert isinstance(e, TypeError)
        print "Test 6 passed"

test_mro()

{% endcodeblock %}

Ý tướng của MRO là sắp xếp các super class với điều kiện:

    + Nếu B là cha của C, B luôn luôn đứng trước C trong list.


Với điều kiện đó, Python sẽ ném ra một lỗi nếu chúng ta cố gắng định nghĩa class
D kế thừa từ (B, C), E kế thừa từ (C, B) và F kế thừa từ (D, E)


Tham khảo
[explaination in python docs](http://www.python.org/download/releases/2.3/mro/)
