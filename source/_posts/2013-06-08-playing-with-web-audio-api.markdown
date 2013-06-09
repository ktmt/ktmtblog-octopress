---
layout: post
title: "playing with web audio api"
date: 2013-06-08 23:46
comments: true
categories: 
  - html5
  - introduction
---

### Web audio api là gì?
Web audio api là là javascript API dành cho xử lý (processing) và tái tạo(synthesizing) âm thanh. Mới được ra đời vào thời gian gần đây (first draft vào 2011/05/12), mặc dù chưa được sử dụng nhiều ( do phần nhiều là chưa được support rộng rãi, tình trạng support các bạn có thể xem ở [đây](http://caniuse.com/audio-api) ), nhưng cá nhân mình thấy web audio api có tiềm năng ứng dụng không nhỏ, nằm ở các lý do dưới đây:

- Web audio cung cấp api ở tầng cao, giúp cho việc xử lý âm thanh trở nên dễ dàng hơn rất nhiều, đặc biệt bạn không phải quan tâm nhiều đến những công đoạn như xử lý binary data, phân tích FFT, encode/decode, input/output.
- Engine để xử lý âm thanh của web audio api chạy trên một thread riêng biệt, chính vì thế một số xử lý nặng như convolve, filter sẽ không làm ảnh hưởng đến GUI thread, chính vì vậy bạn sẽ đỡ phải quan tâm nhiều đến việc phải xử lý thế nào cho nhẹ, hay cho không block UI.
- Việc xử lý âm thanh (đặc biệt là play vào thời điểm nào- timing control) là rất quan trọng với việc làm game. Xu hướng làm rich game trên browser ngày càng phát triển, khiến cho việc sử dụng và phát triên web audio api là không thể tránh khỏi.

Để tìm hiểu và sử dụng web audio api thì bài viết này mình sẽ chia làm 2 ý, đầu tiên là kiến thức cơ bản về xử lý âm thanh, và thứ hai là web audio cung cấp những gì, và sử dụng nó ra sao.


### Cơ bản về xử lý âm thanh
Bài viết này sẽ không đi quá sâu về xử lý âm thanh, mình sẽ đi qua một số khái niệm cơ bản để giúp cho việc sử dụng web audio api dễ dàng hơn. Đầu tiên các bạn nên tham khảo trước ở một số tài liệu cơ bản về digital audio processing. Mình có google thì nó ra một cái tài liệu khá dễ hiểu ở [đây](http://smc.dei.unipd.it/education/algo4smc_ch1.pdf). Sau khi đọc tài liệu trên thì mình mong muốn các bạn nắm rõ được các khái niệm 

1. **Khái niệm âm thanh là gì và được biểu diễn thế nào trên máy tính?** Âm thanh là các dao động cơ học  được truyền trong không khí, va đập vào màng nhĩ , làm rung màng nhĩ và kích thích não người. Trên máy tính ở dạng raw thì âm thanh thường được biểu diễn dưới dạng đồ thị dạng time-series data, tức là có 1 trục là thời gian , và một trục là độ lớn (amplitude)

{% img /images/webaudioapi/sound1.png %}

Để biểu diễn được trên máy tính thì sẽ cần làm 2 việc, 1 là sampling (tức là một khoảng thời gian bao nhiêu lại lấy dữ liệu một lần) và 2 là quantitize , tức là với sóng có biên độ là X thì bạn phải biểu diễn X dưới dạng bit để máy tính có thể hiểu được. Như hình vẽ dưới đây thì data được sampling với thời gian là 0.1s và được sử dụng 8bit để quantitize.

{% img /images/webaudioapi/sound2.png %}


2. **Khái niệm về tần số (frequency) và biến đổi Fourier(Fourier transform)**. Khái niệm về tần số các bạn có thể tìm hiểu thông qua google. Về Fourier transform, hay viết tắt là FT, thì FT giúp biên dữ liệu time series data nói chung ( ở đây là sound wave ) từ dạng ban đầu là trục độ lớn(x)/trục thời gian(y) trở thành trục độ lớn(x)/trục tần số(y). Việc biến đổi này có ích ở việc là giúp phân tích thành phần của sound wave, giúp cho ta biết trong data đó có những sóng có tần số thế nào, độ lớn ra sao. Điều này sẽ giúp cho việc nhận diện/ biểu diễn sound wave được thực hiện một cách dễ dàng hơn rất nhiều.

{% img /images/webaudioapi/ft.gif %}

Nắm được các khái niệm trên một cách rõ ràng, chúng ta đã có thể sử dụng web audio api để làm một số việc từ đơn giản đến tương đối phức tạp rồi :).


### Cấu trúc cơ bản của web audio api
Web audio api có thiết kế dưới dạng **graph**, được cấu thành bởi các **node** ( kiến trúc này còn được gọi là **modular routing** ). Mỗi node có thể có nhiều inputs và/hoặc nhiều outputs. 

{% img /images/webaudioapi/graph.png %}

Tại sao lại là dưới dạng graph? Vì audio processing thường qua nhiều công đoạn, mỗi công đoạn xử lý lại có thể có nhiều output ( giống như hình trên ), do đó mà việc biểu diễn dưới dạng graph và connection giữa các node giúp cho việc tách các xử lý ra/ tổng hợp kết quả xử lý lại được thực hiện một cách dễ dàng và clean hơn.

### Load audio file một cách đơn giản
Chúng ta sẽ bắt đầu sử dụng web audio api bằng cách load và play một file audio đơn giản:

{% codeblock loadfile.js %}
context = new webkitAudioContext();
sourceNode = context.createBufferSource();
sourceNode.connect(context.destination);

function loadSound(source) {
  var req = new XMLHttpRequest();
    req.open('GET', source, true);
    req.responseType = 'arraybuffer';

    req.onload = function() {
      context.decodeAudioData(req.response, function(buffer){
        playSound(buffer);
      }, function(){});
    }
    req.send();
}

function playSound( buffer ) {
  sourceNode.buffer = buffer;
  sourceNode.noteOn(0);
}
{% endcodeblock %}

Các bạn sẽ thấy để thao tác với web audio api thì đầu tiên các bạn sẽ phải tạo ra một object gọi là AudioContext ( trên chrome sẽ gọi là WebkitAudioContext ). Toàn bộ các thao tác như tạo node mới sẽ quay quanh object này

Sau khi đã có context rồi thì các bước tiếp theo sẽ là :

1. Tạo ra sourceNode (sourceNode còn là Node dùng để input data)
2. Tạo ra destinationNode (là Node dùng để output data)
3. Load data thông qua XHR
4. play thông qua hàm noteOn của sourceNode (noteOn(0) tức là play tại thời điểm 0 là thời điểm bắt đầu của audio data)

Các bạn có thể thấy ở trên một graph đơn giản nhất đã được tạo ra với 2 node là Source và Destination được connect với nhau.

### Kết luận
Như vậy các bạn đã có hình dung cơ bản về web audio api.

Ở bài viết tiếp theo mình sẽ nói về các node xử lý cơ bản như AnalyzerNode, ConvolverNode, OscillatorNode và các ứng dụng của chúng.

Các bạn có thể xem bài trình bày của mình tại osaka htmlday (bài viết bằng tiếng Nhật :D):

<script async class="speakerdeck-embed" data-id="8575d620b2e30130eaf25236bfdba4c0" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>
