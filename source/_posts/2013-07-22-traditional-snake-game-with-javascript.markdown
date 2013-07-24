---
layout: post
title: "traditional snake game with javascript"
date: 2013-07-22 14:18
comments: true
categories: 
- programming
- javascript
---

##I. Mở đầu
Năm nay năm âm là năm rắn, hồi tết mình ngồi rỗi không biết làm gì nên quyết định làm một game liên quan đến con rắn. Mà đã liên quan đến rắn thì chắc hẳn mọi người đều nhớ đến game cổ điển snake trên chiếc điện thoại nokia 1010. Để code xong cái đưa được cho bạn bè xem ngay, mình nghĩ làm trên javascript có lẽ là sự lựa chọn tốt nhất. Trong bài này mình sẽ giới thiệu về cách làm game snake trên javascript.

##II. Thiết kế chương trình
Chỉ cần google với từ khóa "snake game trên javascript" cácbạn sẽ có khá nhiều kết quả với khác nhiều cách implement khác nhau cho đò họa. Có cách sử dụng canvas, có cách sử dụng đơn thuần css bình thường. Để làm cho nhanh thì mình sẽ sử dụng css.

- **Idea của game**:

Game snake có dạng như sau:

{% img /images/snake/snake_normal.jpg 'image' 'images' %}

Do đó chúng ta sẽ cần một bảng dạng "grid" để con rắn của chúng ta chạy. Bảng này có thể được implement một cách dễ dàng bằng table của html. Chúng ta sẽ tạo một table dynamically bằng code như dưới đây:

{% codeblock snake.js %}
var boardsize = 10;
//create table
tbl = "";
for(var i = 1; i <= boardsize; i++) {
  tbl += "<tr>";
  for (var j = 1; j <= boardsize; j++) {
    tbl += "<td type='' row='"+i+"' col='"+j+"'></td>";
  }
  tbl += "</tr>";
}
$("#gameboard").html(tbl);
{% endcodeblock %}

Như vậy chúng ta sẽ có cái grid view để con rắn của chúng ta chạy vòng quanh. Tiếp theo chúng ta sẽ design logic cho game. Về mặt idea, do chúng ta dùng css cho GUI, nên body con rắn của chúng ta sẽ được quản lý dưới dạng một **array**, mà mỗi element của array đó sẽ chứa 2 phần tử là **row** và **col** chính là vị trí của mỗi một khúc của thân con rắn. Với mỗi một step của Game loop, chúng ta sẽ vẽ những điểm có tọa độ nằm trong body con rắn với một màu nhất định.

- **Coding**:

Để implement idea đó, chúng ta cần có một object Game. Trong object đó sẽ có các properties: snake_head (đầu con rắn), snake_body(array thân con rắn), snake_direction (hướng đi hiện tại, gồm có 4 hướng là left, right, up, down), fps (tốc độ di chuyển con rắn), và food (vị trí của thức ăn)

{% codeblock snake.js %}
var Game = function(){
  this.snake_head = {row:5, col:5};
  this.snake_body = [this.snake_head];  
  this.snake_direction = 0;
  this.food = {row:-1, col:-1}
  this.timer = 0;
  this.fps = 10;
  this.keys = {
    LEFT: 37,
    UP: 38,
    RIGHT: 39,
    DOWN: 40  
  };  
  this.key_list = [37, 38, 39, 40];

  this.colorset = {
    SNAKE: "black",
    FOOD: "blue",
    BACKGROUND: "white"
  }
};
{% endcodeblock %}

Ok như vậy là đã xong phần khung. Giờ đến đoạn di chuyển và ăn thức ăn của con rắn. Đầu tiên là về mặt di chuyển. Để di chuyển con rắn thì đầu tiên chúng ta phải catch event key và set direction cho nó. Việc này được thực hiện thông qua đoạn code dưới đây:

{% codeblock snake.js %}
Game.prototype.key_handler = function(evt) {
  var self = this;
  var diff = self.snake_direction - evt.keyCode;
  if(self.key_list.contains(evt.keyCode)) {
    if (Math.abs(diff) != 2) { 
/*logic này dùng để check việc khi snake đang di chuyển 
left thì người dùng bấm right (hoặc tương tự với đang di
 chuyển up bấm down...), khi đó thì con rắn của chúng ta 
sẽ không chuyển hướng*/
      self.snake_direction = evt.keyCode;
    }
  }
}

//binding key
$('body').keydown(function(evt){
  snakeGame.key_handler(evt);  
})
{% endcodeblock %}

Như vậy chúng ta đã có logic để khi người dùng bấm phím di chuyển con rắn chúng ta sẽ có direction thích hợp. Vấn đề là với direction đó con rắn của chúng ta sẽ di chuyển thế nào. Vấn đề đó được implement ở đoạn code dưới đây:

{% codeblock snake.js%}
Game.prototype.set_body = function() {
  var self = this;
  var direction = self.snake_direction;
   
  //set snake body
  len = this.snake_body.length;
  var head_row = self.snake_body[len-1].row, 
      head_col = self.snake_body[len-1].col;

  switch(direction) { //set head pos with direction
    case self.keys.LEFT: 
      head_col = head_col-1; 
      break;
    case self.keys.RIGHT: 
      head_col = head_col+1; 
      break;
    case self.keys.UP: 
      head_row = head_row-1; 
      break;
    case self.keys.DOWN: 
      head_row = head_row+1; 
      break;
    default: return;
  }
  
  var head_pos = getat(head_row, head_col);

  //check game over
  if(head_pos.attr("type") === "snake" ||
    head_row < 1 || head_col < 1 || head_row > boardsize || head_col > boardsize) {
    self.end_game(); 
    return;
  } 
  
  self.snake_body.push({row: head_row, col: head_col}); //push head
  len = self.snake_body.length;
  //if not get food
  if (head_pos.attr("type") !== "food")
    self.snake_body = self.snake_body.slice(1,len); //cut tail
  else {
    $("#score").html(parseInt($("#score").html()) + 1);
    self.set_food();
  }
  return true;
}
{% endcodeblock %} 

Chúng ta có thể thấy gì từ đoạn code trên. Đầu tiên các bạn sẽ thấy chúng ta di chuyển con rắn bằng cách nào. Việc di chuyển con rắn được thưc hiện rất đơn giản. Với mỗi step di chuyển, chúng ta set vị trí mới cho đầu con rắn dựa vào direction tính được ở trên, và cắt cái đuôi của cái array đi. Rất đơn giản phải không :D. Ngoài ra ở đoạn code trên chúng ta cũng thấy, khi vị trí mới của đầu con rắn trùng với vị trí của thức ăn, thì chúng ta sẽ không cắt đuôi của array đi, và việc này đồng nghĩa với việc con rắn dài ra.

Đoạn code trên đồng thời cũng implement hệ thống tính điểm (mỗi lần ăn thức ăn là score increment thêm 1), và logic về khi con rắn đâm vào tường hoặc là đâm vào chính nó thì sẽ chết (ở đoạn //check game over)

Thêm thắt một chút css, chúng ta đã có một game con rắn hoàn chỉnh

{% img /images/snake/screenshot.png 'image' 'images' %}

Toàn bộ source code cho ví dụ này mình để ở trên [https://github.com/ktmt/snake-js](https://github.com/ktmt/snake-js) , các bạn có thể sử dụng tùy thích.
