---
layout: post
title: "Đôi điều về hệ thống quảng cáo (phần 1)"
date: 2014-11-09 17:16
comments: true
categories: 
  - advertising
---

# 1. Lời nói đầu
Là một lập trình viên, tôi có thể khẳng định một điều là tôi ***ghét quảng cáo***! Và tôi chắc chắn 90% các bạn cũng ghét quảng cáo như tôi. Bằng chứng là bạn đang cài adblock extension cho chrome hoặc firefox, hay là chúng ta hay đem hình tượng 'kangaroo' (một quảng cáo đã trở thành hiện tượng khi phát vào chung kết C1 năm 2011) là một hình tượng cho sự 'xấu xa', 'phiền phức' của quảng cáo. 

Chúng ta cũng hay dùng quảng cáo như là thước đo cho chất lượng của một kênh truyền hình hay là trang web, ví dụ như: 'vtv3 dạo này toàn quảng cáo', hay là 'trang web abcxyz toàn quảng cáo, lừa đảo đó!'.

Vậy lý do làm sao chúng ta lại ghét quảng cáo đến vậy? Có lẽ nguyên nhân lớn nhất là chúng **cản trở** chúng ta đến với dịch vụ (che tầm nhìn của trang web hay ti vi), và chúng hiển thị những thông tin mà chúng ta coi là **dư thừa**, không cần thiết. Tuy nhiên có phải vì thế mà quảng cáo chỉ toàn điều xấu và không đáng tồn tại?

Tuy nhiên, hãy nhìn vào mặt tốt của quảng cáo một chút 

- Quảng cáo giúp những người làm sản phẩm có cơ hội được khách hàng biết đến. Nếu không có quảng cáo thì những sản phẩm chưa được biết đến hầu như không có cơ hội 'ngoi lên' trên thị trường.
- Quảng cáo giúp người tiêu dùng gặp được những sản phẩm có ích (mặc dù theo cách rất tình cờ)
- Quảng cáo giúp cho các trang web miễn phí, các nhà phát triển app trên điện thoại miễn phí có nguồn doanh thu để tạo ra các sản phẩm có ích cho chúng ta dùng.

 Vậy nếu nhìn theo những hướng tích cực này thì quảng cáo không hề xấu, chỉ có cách thức tiến hành quảng cáo tồi đã gây nên những hình ảnh thiếu tích cực với quảng cáo. Vậy với tư cách là người tiêu dùng, chúng ta cần một hệ thống quảng cáo thông minh hơn, mà không **cản trở**, cũng như cung cấp những thông tin quảng cáo có ích, phù hợp hơn đúng không?

 Thực tế thì hệ thống quảng cáo đã và đang thay đổi hàng ngay để thông minh hơn, đến đúng người dùng hơn. Trong bài viết này tôi sẽ giới thiệu qua về hệ thống quảng cáo trên internet nói chung, về khái niệm cũng như cách thức vận hành của chúng. Qua đó bạn sẽ hiểu tại sao google lại chỉ có thể sống được mà chỉ nhờ có quảng cáo, bạn cũng hiểu được tại sao facebook, twitter sẵn sàng cung cấp dịch vụ miễn phí cho bạn. Để bắt đầu, trước tiên chúng ta sẽ đến với các thuật ngữ chuyên môn được sử dụng trong hệ thống quảng cáo.

# 2. Các thuật ngữ
Do hệ thống quảng cáo ở Việt Nam còn khá non nớt và thô sơ, nên các thuật ngữ trong ngành ít được phổ biến rộng rãi bằng tiếng Việt, do đó ở dưới đây tôi sẽ nói về các thuật ngữ bằng tiếng Anh.

## Thuật ngữ chung
- Media (hay còn gọi là publisher): media bạn có thể hiểu là các trang web (vd như vnexpress), hay các mobile application (vd như flappy bird). Media là nơi có nhiều user tập trung, và cũng là nơi để đặt quảng cáo.
- Advertiser: Là những người nắm(own) quảng cáo. Advertiser bạn có thể hình dung là các doanh nghiệp muốn đưa hình ảnh của mình đến người dùng, vd như cocacola, piagio, adidas...
- Click: Là một trong những đơn vị để tính đơn giá của quảng cáo. Khi người dùng 'click' vào một banner quảng cáo của advertiser, advertiser sẽ phải trả tiền cho click đó (trả tiền cho 'ai' thì chúng ta sẽ hiểu được ở các phần tiếp theo)
- Impression: Cũng là một đơn vị để tính đơn giá của quảng cáo. 1 impression có thể hiểu đơn giản là 1 'view', tức là khi 1 user 'nhìn' thấy một quảng cáo, advertiser sở hữu quảng cáo đó sẽ phải trả tiền.
- Conversion: Khi người dùng nhìn quảng cáo, bấm vào trang web của advertiser, mua hàng hay trở thành khách hàng của advertiser, toàn bộ quá trình đó được gọi là 'converse', do đó chỉ số conversion(CV) được dùng để ám chỉ độ hiệu quả của quảng cáo.
- Conversion Rate(CVR):  Là tỉ lệ converse chia cho số lượng truy cập vào website của advertiser.
- Click Per Cost(CPC): Nhà quảng cáo phải mất bao nhiêu tiền để có được 1 click của user.
- Click Through Rate(CTR): Là số click / số impression. Chỉ số này cho thấy 'độ hiệu quả' của 1 quảng cáo.
- Cost Per Acquisition(CPA): Là số tiền tốn để 'kiếm' được một khách hàng thực thụ (khách hàng trả tiền hay mua hàng của advertiser).
- ROI(Return on Investment): Đây là số tiền để đánh giá độ hiệu quả của một 'chiến dịch' quảng cáo. Một chiến dịch quảng cáo advertiser có thể tung ra ở rất nhiều nơi, sử dụng rất nhiều banner khác nhau. ROI là số tiền thu được sau chiến dịch quảng cáo đó / số tiền advertiser đã đầu tư và chiến dịch đó.

## Thuật ngữ về hệ thống kĩ thuật:
- Ad-Network: là một 'mạng lưới' các media (các website hay các application). Sẽ có các công ty nắm các ad-network này. Đặc điểm của các công ty đó là họ sẽ có chiến lược để 'phân phối' (deliver) các quảng cáo đến các media thích hợp để tăng lợi nhuận cho họ cũng như bên media.
- Ad-Exchange: Đây là một trong những bước tiến lớn để giúp quảng cáo thông minh hơn. Adexchange là một hệ thống nằm trung gian giữa Media và Advertiser, giúp 'trao đổi' quảng cáo giữa các advertiser. Bạn có thể hình dung Ad-Exchange giống như một sàn chứng khoán, mà những người chơi chứng khoán là các advertiser.
- Realtime-Bidding: Là hệ thống đi kèm với Ad-Exchange, giúp việc 'trao đổi', 'mua bán' quảng cáo được diễn ra tại thời gian thực. Bạn có thể hình dung có một thời điểm có một cô gái xinh đẹp vừa mua hàng của LV cách đây 2 ngày (hệ thống quảng cáo biết được việc này thông qua cookie) vào trang web X. Tại ngày thời điểm cô gái request đến X, X sẽ tung ra một món hàng là impression của cô gái này. Các advertiser của NineWest hay H&M sẽ đấu giá với nhau để mua impression của cô gái (và tất nhiên là ai chịu chơi hơn sẽ thắng). Người chiến thắng sẽ được hệ thống 'vận chuyển' quảng cáo của mình trở lại X, và có được impression của cô gái. Hệ thống giúp đấu giá nói trên chính là RTB.
- DSP (Demand Side Platform):  Là một hệ thống được sử dụng bởi các advertisers. Bạn có thể hình dung advertiser sử dụng DSP như một hệ thống cung cấp cánh của để bước vào thế giới của Ad-network và Ad-Exchage. DSP giúp quản lý một lúc nhiều Ad-network, Ad-exchange, giúp advertiser thống nhất cùng một user ở các media khác nhau (thông qua cookie), giúp advertiser sử dụng RTB và còn rất nhiều chức năng thông minh khác.
- SSP (Supply Side Platform): Khác với DSP ở phía 'gần' với advertiser hơn, SSP ở phía gần với media hơn. SSP giúp media quản lý nhiều Ad-Network,  Ad-Exchange khác nhau, giúp cho media có thể tăng lợi nhuận cho mình. Mỗi khi có một user truy cập vào media, media sẽ sử dụng SSP để chọn ra quảng cáo có giá trị tiền cao nhất. Giống như DSP, SSP là cách cửa giúp media bước vào thế giới của Ad-Network, Ad-Exchange.
- Retargeting: Đây là một kĩ thuật được sử dụng rất phổ biến trong quảng cáo. Giả sử có một cô gái xinh đẹp vào trang web của LV, ngẵm nghĩa một chiếc túi xách, xong do không có tiền, cô ấy rời khỏi trang web mất :(. Vài ngày sau, cô gái vào trang tin tức Y, đột nhiên thấy quảng cáo về chiếc túi xách cô ấy mong ước, rất may cô ấy đã nhận lương. Và nhờ thế cô ấy đã click vào quảng cáo của LV, và đôi bên cùng có lợi. Kĩ thuật giúp thực hiện quá trình tren được gọi là Re-targeting. 

Như vậy chúng ta đã có các khái niệm hết sức cơ bản về các thuật ngữ sử dụng trong quảng cáo, để có cái nhìn đầu tiên cho các bài viết tiếp theo. Trong phần tiếp chúng ta sẽ tiếp tục nói về:

- Phân loại hệ thống quảng cáo
- Kiến trúc hệ thống quảng cáo
