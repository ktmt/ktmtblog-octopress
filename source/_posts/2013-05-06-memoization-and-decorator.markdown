---
layout: post
title: "Memoization and Decorator"
date: 2013-05-06 16:44
comments: true
categories: 
  - python 
  - programming
---


## What is memoization ##

Trước hết chúng ta làm quen với khái niệm memoization. Ngôn ngữ ở đây là Python, bài toán là viết hàm tính giai thừa (n!)

Hàm giai thừa thông thường sẽ được viết đệ quy như sau:
{% codeblock  python.py %}
def fac(n):
    if n < 2: return 1
    return n * fac(n - 1)
{% endcodeblock %} 

Có gì không ổn ở đoạn code này ? Cách giải quyết hoàn toàn không có vấn đề, nhưng nếu tinh ý bạn sẽ nhận thấy có 1 khối lượng tính toán bị lặp lại khá nhiều khi chạy nhiều hàm fac(n). fac(3), fac(4) và fac(10) lần lượt đòi hỏi 3 flow tính toán riêng rẽ mà không có reuse. 

Áp dụng memoization dưới dạng dict, ta có thể viết hàm fac_m như sau:

{% codeblock  python.py %}
memo = {}
def fac_m(n):
    if n<2: return 1
    if n not in memo:
        rel = n * fac_m(n-1)
    return rel
{% endcodeblock %} 

Ở đây memo đóng vài trò như 1 cache. fac(3) sẽ generate ra 3 record in cache, và fac(4) sẽ hit cache khi chạy đệ quy được 1 lần. Tương tự fac(10) sẽ hit cache khi giảm xuống fac(4)

Như vậy memoization đơn giản chỉ là tìm cách nhớ những phần tử để giảm khối lượng tính toán

Memoization có thể implement dưới dạng function... 

{% codeblock  python.py %}
def memoize(fn, arg):
    memo = {}
    if arg not in memo:
        memo[arg] = fn(arg)
    return memo[arg]
def fac_m_f(n):
    return memoize(fac,n)
{% endcodeblock %} 


...hoặc class

{% codeblock  python.py %}
class Memoize:
    def __init__(self, f):
        self.f = f
        self.memo = {}
    def __call__(self, *args):
        if not args in self.memo:
            self.memo[args] = self.f(*args)
        return self.memo[args]
fac= Memoize(fac)
{% endcodeblock %} 

Thêm 1 step nữa, thay vì "fac=Memoize(fac)" như ở trên, bạn có thể viết hàm mới theo kiểu decorator

{% codeblock  python.py %}
@Memoize
def fac_m_d(n):
    if n<2: return 1
    return n * fac_m_d(n-1)
{% endcodeblock %} 

Decorator ở đây là từ khoá "@Memoize" trước định nghĩa của hàm fac_m_d

Vậy decorator trong Python là gì và cách dùng ra sao ?

## Python decorator ##
Trong số các design pattern, có 1 design pattern gọi là "decorator design pattern". Decorator ở Python chỉ là 1 cách implement decorator design pattern. 2 khái niệm này không hoàn toàn giống nhau. Một điểm nữa cần nhớ là, memoization ở trên chỉ là 1 trong các ứng dụng của decorator, decorator còn có nhiều ứng dựng khác.

Decorator cho phép ta execute code trước hoặc sau function mà ko làm thay đổi code của function. Mọi function trong python đều là object, cho phép ta có thể assign funtion cho variable hoặc defince function trong chính 1 function khác. Dựa vào đó, decorator có thể là decorator class như trên, hoặc là decorator function

{% codeblock  python.py %}
def gotham(f):
    def inside_gotham():
        print "Gotham needs Batman"
        f()
    return inside_gotham

@gotham
def batman():
    print "Batman Here! Gotham is saved! " 
{% endcodeblock %} 

Cơ chế của decorator có thể hiểu đơn giản là, khi compiler đọc đến đoạn code đefine function với decorator, compiler sẽ compile function 1 cách bình thường và pass function object kết quả thẳng cho decorator(function hoặc class). Có thể coi decorator là một "function" đặc biệt, lấy agrument là 1 function object và return kết quả cũng là 1 function object. 

Ngoài memoization bên trên, bạn có thể dễ thấy rất nhiều ứng dụng của decorator trong các task liên quan đến wrap VD như:

Timing

{% codeblock  python.py %}
def time_cal(func):
    def wrapper(*arg):
        t = time.time()
        res = func(*arg)
        print func.func_name, time.time()-t
        return res
    return wrapper

@time_cal
def fac(n):
    if n < 2: return 1
    return n * fac(n - 1)
{% endcodeblock %} 


hay trong web application, nếu bạn đã dùng Flaskr, bạn có thể thấy đoạn code sau

{% codeblock  python.py %}
@mod.route('/me/')
@requires_login
def home():
...
{% endcodeblock %} 


Ở đây trang web của bạn ở sublink ".../me" sẽ được đảm bảo chỉ viewable với user đã login. Decorator "@requires_login" có thể viết ở 1 file độc lập và mọi hàm cần tính đảm bảo như trên chỉ cần thêm "@requires_login" đằng trước.

{% codeblock  python.py %}
from functools import wraps
...
def requires_login(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if g.user is None:
            flash(u'You need to be signed in for this page.')
            return redirect(url_for('users.login', next=request.path))
        return f(*args, **kwargs)
    return decorated_function
{% endcodeblock %} 


## Kết luận ##

* Memoization: pattern dùng để nhớ các tính toán nhằm làm giảm workload khi gặp các bài toán đệ quy
* Decorator pattern: decorator design pattern
* Python Decorator: Python tools để implement decorator pattern
 
