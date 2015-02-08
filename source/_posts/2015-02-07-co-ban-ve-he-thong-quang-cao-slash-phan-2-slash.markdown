---
layout: post
title: "Cơ bản về hệ thống quảng cáo (phần 2) - Các hình thức quảng cáo trên internet"
date: 2015-02-07 23:27
comments: true
categories:
  - advertising
---

Ở [bài viết trước](http://ktmt.github.io/blog/2014/11/09/doi-dieu-ve-he-thong-quang-cao/), tôi đã giới thiệu về rất nhiều các thuật ngữ, cũng như khái niệm liên quan đến quảng cáo trên internet. Phần 2 sẽ thiên một chút về 'lịch sử' của quảng cáo trên internet, thông qua việc giới thiệu về các hình thức + cách tiến hành các chiến dịch quảng cáo. Thông qua đó cá bạn sẽ hiểu thêm tại sao chúng ta cần có các kĩ thuật quảng cáo ở mức hệ thống như DSP, hay SSP..

Đầu tiên tôi sẽ nói về các loại hình quảng cáo trên internet.

#Quảng cáo thuần (pure adverstisement)

Đây có lẽ là loại hình quảng cáo dễ hiểu nhất và mặc dù xuất hiện từ thời 'xa xưa', nhưng loại hình này vẫn khá thông dụng cho đến hiện nay. Cách quảng cáo này thông qua việc ***liên lạc trực tiếp*** giữa 'người bán' và 'người mua' (người mua ở đây có thể là nhà quảng cáo (advertiser) hoặc cũng có thể là công ty trung gian (ad-agency)). Hình thức này thường có giới hạn thời gian với một cái giá cố định, ví dụ bạn muốn đăng banner trên vnexpress trong vòng một ngày, bạn liên lạc trực tiếp cho vnexpress, trả cho vnexpress một cái giá cố định, hoặc là trả theo 'Impression' (hay là số view). Hình thức quảng cáo này thường có giá trị về mặt 'brand', nên thường khách hàng sẽ là các nhãn hiệu lớn, muốn cho khách hàng nắm được thông tin về 'campaign' của mình, hoặc để cho hình ảnh 'brand' in đậm vào tâm trí người nhìn. Hình thức này có ưu điểm và nhược điểm là :

  - Ưu điểm: Thường các media lớn sẽ có lượng view rất lớn -> có lợi về quảng bá brand
  - Nhược điểm: Giá cao, không target được người dùng nên sẽ phí một lượng impression rất lớn cho những người không quan tâm.


#Quảng cáo dựa vào search engine (listing adverstisement)
Đây là cách quảng cáo đem lại doanh thu chủ yếu cho các search engine thông dụng như google hay yahoo. Để hình dung về hình thức này, bạn chỉ cần tham khảo 2 ví dụ dưới đây mà mình chụp lại của google.

{% img /images/ad/listing1.png %}
{% img /images/ad/listing2.png %}

Ở hình thứ nhất, khi tôi search từ khoá liên quan đến quần áo, google sẽ đưa quảng cáo liên quan đến **từ khoá** đó lên đầu. Để mua được quảng cáo loại này, thì advertiser phải mua quảng cáo dưới dạng **từ khoá** (keyword). Dạng quảng cáo này chính là hệ thống [Adwords](http://www.google.co.uk/adwords/start/?channel=ha&sourceid=awo&subid=uk-en-ha-aw-bkha0~53770295815&gclid=CLrnxP2s0cMCFcKUvQodlykANQ) nổi tiếng của google mà chắc bạn đã từng nghe qua.

Ở hình thứ 2, bạn có thể thấy khi search từ khoá liên quan đến nhãn hiệu hàng hoá montbell, google không chỉ đưa ra link dẫn đến trang web có món hàng, mà còn đưa ra cụ thể chi tiết của từng sản phẩm. Hình thức quảng cáo này vẫn dựa trên nên tảng là adwords (mua keywords), tuy nhiên ở một mức cao hơn gọi là [listing ads](http://www.google.com/ads/shopping/getstarted.html). Để làm được việc này thì advertisers phải cung cấp cho google thông tin về sản phẩm (link ảnh, giá cả...) dựa trên hình thức ***feed*** (bạn có thể hình dung giống như RSS, advertiser cung cấp http://advertiser.com/feed.xml, google fetch thông tin về, đưa vào cơ sở dữ liệu của google).

Hình thức quảng cáo dựa trên search engine có ưu điểm và nhược điểm là:

  - Ưu điểm: 'động lực' của user rất cao -> tỉ lệ click rất tốt. (khi user đã 'chủ động' tìm kiếm thì khả năng click vào link một món hàng ưa thích sẽ rất cao)
  - Nhược điểm: Phụ thuộc vào keyword, một số keyword thông dụng có giá rất cao. Ngoài ra việc chọn lựa keyword một cách hợp lý cũng không hề dễ dàng.

#Quảng cáo hiển thị (display advertisement - programmatic)
Loại hình quảng cáo này là loại hình thông dụng và 'bình dân' nhất, với đặc điểm chính là 'tiến hoá' từ quảng cáo thuần (pure advertisement). Pure advertisement có nhược điểm là phải có quá trình trao đổi trực tiếp giữa 'người mua' và 'người bán', và người bán ở đây thường chỉ là các media lớn, có lượng impression cực cao. Các media lớn này thường là các trang web báo chí (The NYTimes, Vnexpress...), hay các trang portal (như yahoo news..). Vậy các media nhỏ hơn làm sao để có thể bán inventory của mình (inventory là các 'chỗ trống' trên trang web để có thể đặt quảng cáo vào). Đây chính là vấn đề mà display advertisement-programmatic giải quyết, khi sinh ra các khái niệm mà tôi đã đề cập ở bài viết trước như : Ad-network, Ad-exchange, DSP, SSP...

Ad-network lớn nhất hiện nay có thể nhắc đến Google Display Network (GDN). GDN bao gồm cả hệ thống google adsense mà các bạn nào đã từng đặt quảng cáo adsense có thể đã biết. Khi đặt quảng cáo adsense thì bạn (media) đã gia nhập vào hệ thống network của google (GDN).

Mô hình quảng cáo này sẽ được tôi nhắc đến kĩ hơn trong bài viết sắp tới, tuy nhiên có thể lại các ưu nhược điểm như sau:

  - Ưu điểm: có thể điều chỉnh được giá thông qua việc 'bid' nhở có RTB (bạn có thể xem lại khái niệm về Real time bidding ở bài viết trước) -> về cơ bản giá sẽ rẻ hơn. Độ phủ sóng rộng hơn nhờ có ad-network. Ngoài ra nhơ việc tracking người dùng nên có thể sử dụng kĩ thuật retargeting để 'kéo' người dùng lại với service của mình.
  - Nhược điểm: advertiser sẽ không biết quảng cáo của mình sẽ được đặt ở đâu (RTB sẽ quyết việc này tại real-time), dẫn đến có thể quảng cáo của công ty X, sẽ lại được đặt ở ... website của đối thủ của X (việc này có thể giải quyết dựa vào một số công ty 3rd-party chuyên đi đánh giá độ tin cậy của media). Một nhược điểm rất lớn nữa của loại hình này chính là các thuật toán RTB thường không đủ thông minh để xác định user nào 'nên' hiện và user nào 'không nên' hiện quảng cáo, khiến cho 90% impression sẽ bị qui vào thể loại quảng cáo gây khó chịu cho người dùng.

#Các hình thức quảng cáo khác
Ngoài các hình thức trên thì hiện nay còn rất nhiều hình thức quảng cáo khác 'mới nổi' mà có thể kể đến điển hình như:

  - Quảng cáo trên mạng xã hội (facebook, twitter): hình thức này có lẽ tương lai sẽ thống trị quảng cáo trên internet nói chung, khi mà các mạng xã hội như facebook, twitter nắm 'rất nhiều' thông tin về người dùng, đủ cho họ có thể target được chính xác 'ai cần gì', khiến cho chỉ với một cái giá rất rẻ nhưng đem lại hiệu quả rất lớn cho advertiser.
  - Quảng cáo trên mobile (admob, apple ad..): có lẽ các bạn sử dụng smartphone, cũng như các nhà phát triển smartphone sẽ nắm rất rõ loại hình này. Loại hình này có ưu điểm là impression rất lớn, khi mà lượng smartphone user tăng cao + thời gian sử dụng smartphone chiếm tỉ lệ cao sơ với web. Tuy nhiên nhược điểm lớn của loại hình này là các công ty như admob hay apple vẫn đang 'loay hoay' tìm các 'đăt' quảng cáo sao cho ít gây trở ngại đến người dùng nhất. 99% quảng cáo trên mobile sẽ được qui vào dạng gây cực kì khó chịu cho người dùng. Hơn nữa, tracking người dùng web và mobile hiện là một công việc không hề dễ (cross-device tracking), nên làm cho độ chính xác của quảng cáo trên mobile đang là cực thấp.


#Tổng kết
Ở bài viết này tôi đã giới thiệu một cách cơ bản nhất về các loại hình quảng cáo.
Bài viết chủ yếu đi về các khái niệm, để làm nền tảng cho bài viết sắp tới tôi sẽ nói rõ hơn về khía cạnh kĩ thuật của hình thức quảng cáo hiển thị (display advertisement), cũng như các cách để 'tracking' người dùng.
