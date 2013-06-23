---
layout: post
title: "playing with web audio api (part 2)"
date: 2013-06-21 23:07
comments: true
categories: 
  - html5
---

###Playing audio with multisource and precise timing
Để làm game một game hay trên html5 thì âm thanh là một thứ không thể thiếu. Đầu tiên hãy đến với một game rất nổi tiếng: 
[Angry bird chrome](http://chrome.angrybirds.com/)

Các bạn có thể để ý khi play một màn game bất kì nào đấy thì sẽ thấy rất nhiều âm thanh với các lớp (layer) khác nhau,
được play vào các thời điểm khác nhau một cách hợp lý. Nếu chỉ đơn thuần dùng audio tag thì việc control các layer âm
thanh khác nhau được play vào thời điểm nào sẽ rất khó.

Nhờ có web audio api mà việc này trở nên dễ dàng hơn rất nhiều.

Như mình đã nói ở bài trước, web audio api xoay quanh audio context. Điều đặc biệt là **một context có thể load cùng một lúc 
nhiều audio source**, và **play mỗi audio source tại các thời điểm khác nhau**, với một interface rất dễ hiểu.
Đầu tiên là việc load nhiều audio source vào cùng một context. Dưới đây là module ***BufferLoader*** có nhiệm vụ load các file audio từ
nhiều source khác nhau và quản lý thông qua bufferList.

 
{% codeblock loadfile.js %}
function BufferLoader(context, urlList, callback) {
  this.context = context;
  this.urlList = urlList;
  this.onload = callback;
  this.bufferList = new Array();
  this.loadCount = 0;
}

BufferLoader.prototype.loadBuffer = function(url, index) {
  // Load buffer asynchronously
  var request = new XMLHttpRequest();
  request.open("GET", url, true);
  request.responseType = "arraybuffer";

  var loader = this;

  request.onload = function() {
    // Asynchronously decode the audio file data in request.response
    loader.context.decodeAudioData(
      request.response,
      function(buffer) {
        if (!buffer) {
          alert('error decoding file data: ' + url);
          return;
        }
        loader.bufferList[index] = buffer;
        if (++loader.loadCount == loader.urlList.length)
          loader.onload(loader.bufferList);
      },
      function(error) {
        console.error('decodeAudioData error', error);
      }
    );
  }

  request.onerror = function() {
    alert('BufferLoader: XHR error');
  }

  request.send();
}

BufferLoader.prototype.load = function() {
    for (var i = 0; i < this.urlList.length; ++i)
        this.loadBuffer(this.urlList[i], i);
}
{% endcodeblock %}

Giải thích đoạn code trên một chút, module BufferLoader sẽ có properties là **urllist** chứa một list url của các audio source,
BufferList là một **array các buffer** tương ứng với từng source đã load. 

Hàm **load** sẽ chạy từng file trong urllist, gọi hàm ***loadBuffer*** để load từng file thông qua **XHR**, sau khi load được qua XHR
thì buffer được tạo ra và cho vào **bufferList**
Như vậy là chúng ta đã có thể control multiple audio source thông qua ***BufferLoader***

Giờ đến việc play theo precise timing, như bài lần trước chúng ta đã biết để play thì chúng ta sẽ dùng hàm noteOn(t), để play từ đầu 
thì t = 0, thế nên để play tại một thời điểm bất kì thì chúng ta sẽ chỉ cần set t(với đơn vị là second và relative theo thời điêm bắt đầu
của audio).

Hãy thử bằng một ví dụ đơn giản :D, bạn muốn làm 1 game bắn súng, trong đấy có một khẩu súng rất cool, giả sử là m4a1 đi :D. Chắc hẳn bạn 
nào đã chơi counter strike rồi thì sẽ biết là m4a1 thì phải bắt phát một được, hoặc bắn 3 viên một, hoặc bắn liên thanh. Cơ mà bạn chỉ có
1 file âm thanh chứa ngắn chứa một tiếng súng, vậy bạn phải làm sao? Rất đơn giản, bạn chỉ cần timing để playback lại cái source của bạn là ok
. Hãy tham khảo đoạn code dưới đây:

{% codeblock loadfile.js %}
MachineGun.prototype.shootRound = function (type, rounds, interval, random, random2) {
    if (typeof random == 'undefined') {
        random = 0;
    }
    var time = context.currentTime;
    for (var i = 0; i < rounds; i++) {
        var source = this.makeSource(this.buffers[type]);
        source.playbackRate.value = 1 + Math.random() * random2;
        source.noteOn(time + i * interval + Math.random() * random);
    }
}

MachineGun.prototype.makeSource = function (buffer) {
    var source = context.createBufferSource();
    var compressor = context.createDynamicsCompressor();
    var gain = context.createGainNode();
    gain.gain.value = 0.2;
    source.buffer = buffer;
    source.connect(gain);
    gain.connect(compressor);
    compressor.connect(context.destination);
    return source;
};
{% endcodeblock %}

Đoạn code trên có 2 hàm là **shootRound** và **makeSource**. 
Hàm **makeSource** nhận đầu vào là buffer , chỉnh lại âm thanh cho nhỏ đi một chút thông qua việc set gain = 0.2, sử dụng compressor Node 
để smoothing data đi một chút trước khi kết nối với destination node. 
Hàm **shootRound** có mục đích đúng như cái tên của nó, dùng để bắn, hay chính xác là timing buffer có sẵn theo các paramter đầu vào. 
Các parameter ở đây gồm có rounds ( là số lần lặp lại, ví dụ súng của bạn bắn 3 phát một thì rounds sẽ là 3), interval (khoảng cách giữa 2 lần bắn), 2 biến random và random2 dùng để set xem nên bắn đều đều hay bắn một cách random cho nó thật :D. 

Chỉ nói lý thuyết không hơi khó hiểu, các bạn có thể xem ví dụ trực quan ở:
[https://github.com/huydx/html5collection.git](https://github.com/huydx/html5collection.git)
Ví dụ ở trên mình đặt ở html5collection / webaudioapi / guneffect.html. Lưu ý một chút là mình dùng XHR để load file nên các bạn sẽ phải sử dụng thông qua web server (đơn giản nhất là XAMPP) và xem thông qua localhost.




