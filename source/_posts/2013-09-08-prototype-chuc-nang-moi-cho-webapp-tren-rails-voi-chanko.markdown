---
layout: post
title: "prototype chức năng mới cho webapp trên rails với chanko"
date: 2013-09-08 21:49
comments: true
categories: rails
---

Là một web developer nói chung và ruby on rails developer nói riêng, bạn chắc hẳn sẽ gặp nhiều khó khăn khi muốn thêm chức năng mới vào hệ thống hiện tại. Khó khăn đáng nói đến nhất bao gồm: bạn phải add sao cho chức năng mới được add vào sẽ dễ extend, dễ tháo bỏ khi không cần thiết, và việc add chức năng mới vào sẽ có ảnh hưởng tối thiểu nhất đến các chức năng đã có. Trong bài viết này, mình sẽ giới thiệu về **[chanko](https://github.com/cookpad/chanko)**, một **(framework/engine) trên ruby on rails**, mà sẽ giúp cho việc tạo chức năng mới trên một app đã có cực kì clean và dễ dàng.

# 1. Cài đặt
Để cài đặt chanko thì chúng ta chỉ cần add chanko vào Gemfile:
```ruby
gem "chanko"
```

# 2. Sử dụng
Đầu tiên chúng ta sẽ nói về ý tưởng của chanko. Chanko tách chức năng mới với app hiện tại thông qua việc tạo ra một folder trong /app/unit. Trong đó sẽ chứa các chức năng được tạo mới thông qua chanko. Việc này có thể được nhìn thấy dễ dàng khi chúng ta sử dụng chanko generator. 

```
$ rails generate chanko:unit example_unit
      create  app/units/example_unit
      create  app/units/example_unit/example_unit.rb
      create  app/units/example_unit/views/.gitkeep
      create  app/units/example_unit/images/.gitkeep
      create  app/units/example_unit/javascripts/.gitkeep
      create  app/units/example_unit/stylesheets/.gitkeep
      create  app/assets/images/units/example_unit
      create  app/assets/javascripts/units/example_unit
      create  app/assets/stylesheets/units/example_unit
```

Chúng ta có thể thấy chanko generator gần tương tự như scaffold generator của rails. unit ở đây là một đơn vị chức năng. 

Ví dụ khi bạn cần add chức năng search button thì bạn sẽ `generate chanko:unit add_search_button`, khi đó chanko sẽ tự động tạo folder add_search_button ở trong app/units, và tạo sẵn file add_search_button_unit.rb và thư mục view để chứa view của chức năng mới này. File add_search_button.rb này sẽ chứa logic của cả model/controller của chức năng add_search_button mà chúng ta cần thêm vào. 

Các bạn có thể thấy rõ ý tưởng của chanko là tách logic và cả asset của chức năng mới cần thêm vào càng tách biệt với các chức năng cũ càng tốt. Việc này có tác dụng là chúng ta có thể thêm, bớt chức năng vào hệ thống cũ bằng một flow rất clean , và độ ảnh hưởng với hệ thống cũ cực kì thấp. Vậy nếu tách unit mới ra dưới dạng gần như một thư viện riêng như vậy, chúng ta sẽ intergrate unit này vào rails ra sao?

Việc intergrate unit được tạo ra bởi chanko vào rails được thể hiện qua các chức năng dưới đây:

## 2.1 Invoke
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def index
    invoke(:add_search_button_unit, :index) do
      @users = User.all
    end
  end
end
```

```ruby
module AddSearchButtonUnit
  include Chanko::Unit
  function (:index) do 
    @users = Users.unit.active
  end
end
```
Hàm invoke này sẽ đưa logic của hàm `index` được định nghĩa trong `add_search_button_unit.rb` vào trong logic của hàm hiện tại. Block được pass vào hàm invoke sẽ là fallback function, được execute khi có lỗi hày có vấn đề gì xảy ra với hàm invoke. Chúng ta có thể hình dung đơn giản chức năng invoke dùng để extend logic của một hàm của một unit (chức năng mới) và logic của controller (chức năng cũ)

## 2.2 Unit module
Unit module chính là module của chức năng mới được thêm vào, ở đây chính là module AddSearchButton mà chúng ta đã nói đến ở trên. Trong module này sẽ định nghĩa logic cho controller, model và cả view helper cho chức năng mới. Tất cả MVC logic đều được nhét vào 1 file có thể hơi khó nhìn khi chức năng của chúng ta có nhiều logic phức tạp , tuy nhiên khi dừng lại ở mức prototyping thì việc này có thể chấp nhận được.

**Logic của controller** được add vào thông qua hàm `scope(:controller)`
```ruby
scope(:controller) do
  function(:show) do
    @user = User.find(params[:id])
  end

  function(:index) do
    @users = User.active
  end
end
```

Gần tương tự, **Logic của của model** sẽ được thực hiện thông qua hàm `model`. Một điểm hơi khác là trong block pass vào thì chúng ta phải extend model mà chúng ta muốn thêm chức năng vào. Một điều đặc biệt ở đây là các hàm được extend cho một model X sẽ không được add trực tiếp vào model X thông qua monkey patch, mà sẽ add gián tiếp thông qua một proxy tên là unit. Do đó giả sử chúng ta một thêm hàm `method` vào model X thì chúng ta sẽ gọi nó thông qua `X.unit.method`. Như ở ví dụ dưới đây thì hàm active? sẽ được gọi thông qua user.unit.active?

```ruby
models do
  expand(:User) do
    scope :active, lambda { where(:deleted_at => nil) }

    def active?
      deleted_at.nil?
    end
  end
end
```

Logic của view được thực hiện thêm vào thông qua hàm `scope(:view)` và qua file view được add vào thư mục /units/unit_name/views (file view này sẽ có extension là slim)

```ruby
scope(:view) do
  function(:active) do
    render '/active' if user.unit.active?
  end
end
```
Hàm view này sẽ render view active.html.slim nằm trong app/units/unit_name/views

Ngoài việc add logic của unit vào controller/model/view thông qua các hàm scope và model như đã giới thiệu ở trên. Chanko::Unit cung cấp cho chúng ta một hàm rất hữu ích là `active_if`. Hàm này giống như một dạng functionality toggle, giúp chúng ta có thể on/off một chức năng mới cực kì dễ dàng. Block được pass vào active_if sẽ quyêt định chức unit có được enable không, nếu không được enable thì tất cả các logic của unit sẽ không được execute. 

```ruby
active_if do |context, options|
  true
end
```
# 3. Kết luận
Qua bài viết này chúng ta đã biết cách sử dụng gem chanko để có thể prototype chức năng mới một cách dễ dàng hơn, và ít ảnh hưởng đến hệ thống cũ nhất. Một cách đơn giản thì chanko đưa logic của cả model/view/controller vào tập trung trong 1 file, và cung cấp các helper function để giúp logic của hệ thống cũ có thể invoke các chức năng của unit mới một cách đơn giản nhất.

Các bạn có thể tham khảo chi tiết thông qua [homepage của chanko](http://cookpad.github.io/chanko/)
