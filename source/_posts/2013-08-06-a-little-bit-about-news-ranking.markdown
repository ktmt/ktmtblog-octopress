---
layout: post
title: "survey about news ranking"
date: 2013-08-06 17:37
comments: true
categories: 
---

# Mở đầu:
- **Problem**: Bạn là web programmer, bạn sở hữu một trang web đăng tin tức với rất nhiều users. Users của bạn sẽ vote up hoặc down cho một tin tức nào đó, Vấn đề là không gian hiển thị tin luôn là hữu hạn và nhỏ hơn rất nhiều so với số lượng tin được đăng. Do vậy việc sắp xếp tin nào hot lên trên , ít hot hơn xuông dưới là một bài toán cần giải quyết. Việc sắp xếp ở đây được thông qua độ hot hay là hot-score. Một thuật toán quyết định **hot-score** tốt sẽ giúp cho user luôn theo dõi được các trend hiện tại, và tìm ra được tin mình muốn theo dõi.

- **Giải quyết**: Định nghĩa về việc định nghĩa hot-score thế nào là tốt là một việc khá khó vì không có cách nào đánh giá cụ thể được, vì vậy ở bài viết này chúng ta sẽ tìm hiểu các thuật toán đã và đang được áp dụng trên reddit, hacker-news và trên [lamernews](https://github.com/antirez/lamernews) ( một open source clone hackernews )

# Idea để giải quyết bài toán **hot-score**
- Đầu tiên hãy nói về mặt ý tưởng. Thường với những hệ thống có chức năng vote, chúng ta sẽ nghĩ ngay đến công thức :
{% codeblock score.py %}
score = up_vote - down_vote
{% endcodeblock %}
Tuy nhiên công thức trên có gì không tốt?
Giả sử một item có 1000 up votes và 500 down votes, như vậy score của item đó sẽ là 500, tỉ lệ là 66.6% positive (1000/1500). Một item khác có 2000 up votes và 1300 down votes, có score là 700, nhưng tỉ lệ lại chỉ có 60.6% (2000/3300). So sánh 2 item trên thì về mặt logic thông thường chúng ta sẽ muốn item thứ nhất, với tỉ lệ positive cao hơn hẳn và số lượng sample (mẫu) votes không quá tầm thường (1500 votes).

- Từ ví dụ trên, chúng ta lại nảy ra ý nghĩ sử dụng tỉ lệ (portion) thay vì khoảng cách (distance) ở công thức trên
{% codeblock score.py %}
score = up_vote / down_vote
{% endcodeblock %}
Tuy nhiên công thức trên không tốt ở đâu? Vấn đề thứ 1 của công thức trên chính là việc dùng phép chia. Vấn đề dùng phép chia sẽ gặp phải bài toán chia cho 0 (divide by zero), do đó là 1 item với 2 up votes và 0 down votes sẽ có giá trị là Inf, có độ lớn vô tận. Vấn đề này có thể giải quyết một cách đơn giản bằng cách cộng thêm 1 vào cả up votes và down votes.  
{% codeblock score.py %}
score = (up_vote + 1) / (down_vote + 1)
{% endcodeblock %}

Tuy nhiên mặc dù có cộng thêm một, vẫn còn một vấn đề nữa, là vấn đề thời gian. Công thức trên hoàn toàn không có parameter liên quan đến thời gian. Việc đó sẽ gây ra điều gì? Chúng ta dễ dàng nhận thấy là những item được post sớm sẽ có chiều hướng được rank cao hơn. Lý do là vì những item được post sớm sẽ được nhìn thấy nhiều hơn, được vote nhiều hơn, do đó nó dễ dàng ngự trị ở vị trí top-score một cách ổn định. Do đó việc có một parameter để quyết định độ "cũ" (stale) của một item là cần thiết. 

Như vậy chúng ta cần một thuật toán tính toán hot-score dựa trên up votes, down votes, và thời gian (thời gian ở đây chính là khoảng thời gian từ lúc post bài cho đến thời điểm hiện tại).

# Một số cách giải quyết của các website nổi tiếng
## Reddit
- Đầu tiên đến với [reddit](http://reddit.com). Reddit là một web-site chuyên đăng tin tức với comment vào dạng lớn nhất trên thế giới. Source code của reddit được open tại [https://github.com/reddit/reddit](https://github.com/reddit/reddit). Thuật toán tính toán hot-score của reddit nằm tại đoạn code ./r2/r2/lib/db/_sorts.pyx :
{% codeblock reddit_implement.py %}
epoch = datetime(1970, 1, 1, tzinfo = g.tz)

cpdef double epoch_seconds(date):
    """Returns the number of seconds from the epoch to date. Should
       match the number returned by the equivalent function in
       postgres."""
    td = date - epoch
    return td.days * 86400 + td.seconds + (float(td.microseconds) / 1000000)

cpdef long score(long ups, long downs):
    return ups - downs

cpdef double _hot(long ups, long downs, double date):
    """The hot formula. Should match the equivalent function in postgres."""
    s = score(ups, downs)
    order = log10(max(abs(s), 1))
    if s > 0:
        sign = 1
    elif s < 0:
        sign = -1
    else:
        sign = 0
    seconds = date - 1134028003
    return round(order + sign * seconds / 45000, 7)
{% endcodeblock %}

Đoạn code trên được implement bằng cython. Đoạn code hơi dài, nhưng chúng ta chỉ cần chú ý đến dòng cuối cùng 
{% codeblock reddit_rank.py %}
  round(order + sign * seconds / 45000, 7)
{% endcodeblock %}

Ở đây seconds chính là thời gian tính từ 1970/1/1 đến giờ theo seconds. sign là giá trị mà (-1) khi có số vote âm, (+1) khi có số vote dương và (0) khi có số vote 0. order chính là log10(số vote). Từ công thức trên chúng ta có thể thấy độ hot của một item, khi có số vote âm mà càng cũ (seconds lớn) thì sẽ tụt rất nhanh về phía dưới. Việc sử dụng log scale, và chia time-lapse cho một con số khá lớn (45000) giúp cho giá trị vote không ảnh hưởng quá nhiều đến ranking. Do đó chúng ta có thể thấy rằng ở công thức của reddit thì:

- Thời gian post bài có giá trị quan trọng nhất, thường thì bài mới hơn sẽ rank cao hơn bài cũ.
- Giá trị votes không quá ảnh hưởng đến bài, một bài viết với 10 up votes và một bài viết với 100 up votes không quá chênh lệch nhau về rank.

## Hackernews
- Tiếp theo chúng ta sẽ đến với thuật toán của hacker-news. Source code của hacker-news (ycombinator) được viết bằng Arc, một ngôn ngữ gần giống Lisp và được open source ở [http://arclanguage.org/](http://arclanguage.org/)

{% codeblock hnrank.sh %}
(= gravity* 1.8 timebase* 120 front-threshold* 1
       nourl-factor* .4 lightweight-factor* .17 gag-factor* .1)

    (def frontpage-rank (s (o scorefn realscore) (o gravity gravity*))
      (* (/ (let base (- (scorefn s) 1)
              (if (> base 0) (expt base .8) base))
            (expt (/ (+ (item-age s) timebase*) 60) gravity))
         (if (no (in s!type 'story 'poll))  .8
             (blank s!url)                  nourl-factor*
             (mem 'bury s!keys)             .001
                                            (* (contro-factor s)
                                               (if (mem 'gag s!keys)
                                                    gag-factor*
                                                   (lightweight s)
                                                    lightweight-factor*
                                                   1)))))


{% endcodeblock %}

Đoạn code trên viết theo poland notation nên hơi khó nhìn một chút, về mặt bản chất thì đoạn code trên tương đương với
{% codeblock hnrank.py %}
def score(votes, age, gravity=1.8):
  (votes - 1) / pow((age+2), gravity);
{% endcodeblock %}

Chúng ta có thể rút ra được 2 điều:

- Thời gian càng tăng (age >>) thì score càng giảm với tốc độ rất nhanh theo hàm power
- Bài viết càng cũ thì dù up votes có tăng nhanh nhưng cũng không thể kéo được rank.

Công thức của ycombinator đã phản ánh rất đúng power law về pupularity ranking, là popularity của một data source bao giờ cũng có dạng long-tail. Định lý này nói lên rằng tỉ lện những item dominate (có rank cao) chỉ chiếm tầm 20% so với tổng số item, nên rule này còn được gọi là 80/20 rule.

{% img /images/long_tail.png %}

## Lamernews
- Lamernews được viết bởi creator của reddit, và được open source tại [https://github.com/antirez/lamernews](https://github.com/antirez/lamernews). Lamernews được viết bằng ruby (sinatra) và thuật toàn của lamernews được viết khá đơn giản như sau:

{% codeblock lamerrank.rb %}
def compute_news_rank(news)
    age = (Time.now.to_i - news["ctime"].to_i)
    rank = ((news["score"].to_f)*1000000)/((age+NewsAgePadding)**RankAgingFactor)
    rank = -age if (age > TopNewsAgeLimit)
    return rank
end
{% endcodeblock %}

Chúng ta có thể thấy thuật toán này khá giống với ycombinator nên sẽ không bàn thêm về hiệu quả của nó ở đây

# Kết luận
Như vậy chúng ta đã lướt qua một số thuật toán ranking được implement bởi các web service nổi tiếng. Việc quyết định thuật toán nào tùy thuộc vào chúng ta muốn chú trọng đến cái gì. Với một service có tốc độ post bài và comment rất nhanh như reddit thì nên dùng một thuật toán base chủ yếu vào aging. Còn nếu muốn chú trọng hơn vào số lương votes và giữ một tốc độ giảm rank đều với các bài viết cũ, thì chúng ta có thể sử dụng thuật toán của ycombinator

Chi tiết các bạn có thể tham khảo:

- [http://amix.dk/blog/post/19588](http://amix.dk/blog/post/19588)
- [http://possiblywrong.wordpress.com/2011/06/05/reddits-comment-ranking-algorithm/](http://possiblywrong.wordpress.com/2011/06/05/reddits-comment-ranking-algorithm/)
- [http://amix.dk/blog/post/19574](http://amix.dk/blog/post/19574)
- [http://www.evanmiller.org/how-not-to-sort-by-average-rating.html](http://www.evanmiller.org/how-not-to-sort-by-average-rating.html)





