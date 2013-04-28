---
layout: post
title: "fun with unix command prompt"
date: 2013-04-28 00:06
comments: true
categories: 
- linux, tips, tutorial
---

{% img /images/UnixCommandPrompt/unix.png %}

Chắc hẳn là một unix user (có thể mac os hay linux), lại là một programmer, bạn sẽ phải hàng ngày sử dụng terminal cho việc lập trình, quản lý source, monitoring hệ thống.... Và đã là người sử dụng terminal hàng ngày thì cái bạn phải nhìn thấy nhiều nhất chính là cái gọi là "Command prompt"

{% img /images/UnixCommandPrompt/unix-terminal.png %}

Cái command prompt này thì tùy thuộc vào shell bạn đang dùng (bash hay zsh..) mà sẽ có những cách tùy chỉnh khác nhau. Mình thì đang dùng bash (chắc một ngày gần đây sẽ chuyển qua zsh), nên bài viết này sẽ áp dụng chủ yếu ở trên bash. Command prompt ở trên bash thì gồm có 4 biến môi trường (environment variable) chính: PS1, PS2, PS3, PS4 (Ngoài ra còn có COMMAND_PROMPT nữa nhưng thằng này na ná PS1 nên mình không đề cập đến). Để sử dụng các biến môi trường này thì bạn chỉ cần:
{% codeblock export export.sh %}
export PS1 = "abcxyz"
{% endcodeblock%}
hoặc đặt đoạn code đó vào ~/.bash_profile hoặc ~/.bashrc rồi 
{% codeblock export export.sh %}
source ~/.bash_profile 
{% endcodeblock%}
để shell load lại các setting trong file tương ứng là biến môi trường đã được set.

Dưới đây mình sẽ nói về việc sử dụng các biến môi trường này để biến cái command prompt của bạn trở nên **màu mè** và **thân thiện** hơn. Về thứ tự thì mình sẽ nói về cái có độ tùy biến thấp đến cao

##PS2##
Trong 5 biến mình nói ở trên thì biến PS2 là thằng nhàm chán nhất. PS2 gọi là Continuation interactive prompt. Tại sao lại gọi như vậy thì: khi một câu lệnh unix quá dài thì bạn thường dùng kí hiệu "&#92;" ở cuối dòng để làm cho câu lệnh đấy thành multiple-line (gõ được ở nhiều dòng). Và PS2 là biến quyết định **cái gì được in ở đầu mỗi dòng đó**

{% img /images/UnixCommandPrompt/PS2-1.png %}

Cách sử dụng thì vô cùng đơn giản:
{% codeblock export export.sh %}
export PS2="continue here -> "
{% endcodeblock%}
Và kết quả là:

{% img /images/UnixCommandPrompt/PS2-2.png %}

Chắc bạn cũng đã hình dung ra cách dùng PS2 thế nào rồi nhỉ, và hẳn bạn đang nghĩ, biến này chả có gì thú vị lắm nhỉ, mình cũng nghĩ thế :D. Thế nên chúng ta qua thằng tiếp theo nhé: PS3

##PS3##
PS3 gọi là biến dùng cho việc "select inside shell script"
Giả sử bạn phải viết một đoạn script cho lựa chọn (ví dụ như bạn làm infra, phải viết script kiểu như: hãy chọn giữa install rvm hay rbenv chẳng hạn).Thì chắc đoạn script đó sẽ trông như sau:
{% codeblock select select.sh %}
==> code
echo "Select your option:"
select i in 1) 2) 3)
do
  case $i in 
    x)....
    y)....
    z)....
  esac
done

==> run
# /.select.sh
x)....
y)....
z)....

#? 1
x)
{% endcodeblock%}
Như các bạn thấy, prompt để lựa chọn khi không có setting gì sẽ là **không hiện gì**, quite boring 
Giờ nếu chúng ta chỉ cần setting PS3 cho đoạn code đó như sau

{% codeblock select select.sh %}
==> code
PS3="Select an option of installer (1-3): "
select i in 1) 2) 3)
do
  case $i in 
    x)....
    y)....
    z)....
  esac
done

==> run
# /.select.sh
x)....
y)....
z)....

#? Select an option of installer (1-3): 1
x)
{% endcodeblock%}
Như vậy là chúng ta sẽ có một cái prompt **có hiện gì**, use case để dùng thì chắc trong phần lớn các trường hợp sẽ là để cung cấp thông tin cho user về các option lựa chọn phía dưới. PS3 có vẻ khá useful trong một số case nhất định đúng không :D, tiếp theo chúng ta sẽ đến với PS4 

## PS4 ##
Khi execute một đoạn script mà bạn muốn tracking output (để debug chẳng hạn), bạn sẽ dùng {set -x} để làm việc đó. ví dụ như đoạn code ở dưới đây:
{% codeblock tracking tracking.sh %}
==> code tracking.sh
set -x
ls -all -lrt | grep xyz
pwd

==> run
++ ls -all -lrt
++ grep xyz
drwxr-xr-x   2 doxuanhuy  staff   68 Apr 28 11:45 xyz
++ pwd
/Users/doxuanhuy/cur-project/android-globalit
{% endcodeblock%}

Như các bạn thấy, {set -x} sẽ output ra các câu lệnh được execute và prefix bằng cái "++". 2 kí tự này có vè không thể hiện được gì nhỉ, và với PS4, bạn có thể thêm thông tin hữu ích cho việc debug như line number thông qua biến $LINENO, hay function name thông qua biến $FUNCNAME, hay script name thông qua biến $0

{% codeblock tracking tracking.sh %}
==> code tracking.sh
export PS4='$0.$FUNCNAME $LINENO '

set -x
somefunction() {
    ls -all -lrt | grep xyz
      pwd
}
somefunction

==> run
../test.sh. 8 somefunction
../test.sh.somefunction 5 ls -all -lrt
../test.sh.somefunction 5 grep xyz
drwxr-xr-x   2 doxuanhuy  staff   68 Apr 28 11:45 xyz
../test.sh.somefunction 6 pwd
/Users/doxuanhuy/cur-project/android-globalit
{% endcodeblock%}
Như vậy chúng ta đã có những thông tin khá hữu ích để debug đúng không.
Và tiếp theo chúng ta sẽ đi đến bộ đôi thú vị nhất trong ngày: PS1 và COMMAND_PROMPT

##PS1##
Đây chính là biến quyết định cái gì sẽ hiện lên ở command prompt, và là biến có nhiều cái để hack nhất trong các loại PSx

{% img /images/UnixCommandPrompt/PS1-1.png %}

Đầu tiên chúng ta sẽ nói về PS1
Giả sử chúng ta muốn command prompt hiện lên Username, Hostname và full-path đến directory hiện tại, đơn giản chúng ta chỉ cần
{% codeblock PS1 PS1.sh %}
export PS1="\u@\h \w> "
{% endcodeblock%}

Ở đây \u là Username, \h là Hostname và \w là full path của current dir.
Như vậy chúng ta sẽ có 1 cái prompt như dưới đây 
{% codeblock PS1 PS1.sh %}
doxuanhuy@xxx ~/cur-project/android-globalit> 
{% endcodeblock%}

Quite easy phải không :D
Hay hơn chút nữa, bạn muốn hiện thêm current time, lên prompt, rất đơn giản:
{% codeblock PS1 PS1.sh %}
export PS1="\$(date +%k:%M:%S) \w> "
{% endcodeblock%}
Ở đây (date +%k:%M:%S) là để format date và biến nó thành variable thông qua $

Và kết quả là
{% codeblock PS1 PS1.sh %}
12:23:59 ~/cur-project/android-globalit> 
{% endcodeblock%}

Ngoài ra còn rất nhiều cái bạn có thể cho vào command prompt để biến nó thêm phần phong phú như:

*  \!: The history number of the command
*  $kernel_version: The output of the uname -r command from $kernel_version variable
*  \$?: Status of the last command

Hacking thêm chút nữa, bạn có thể thay đổi màu của từng phần trên command prompt thông qua 3 metacharacter sau:

*  \e[ - Indicates the beginning of color prompt ( giống như cái "^" của regex vậy)
*  x;ym - Indicates color code. Use the color code values mentioned below ( bạn đặt x;ym ở trước node nào thì node đó sẽ được colorize theo màu đó)
*  \e[m - indicates the end of color prompt (giống như cái "$" của regex)

Một ví dụ đơn giản:
{% codeblock PS1 PS1.sh %}
export PS1="\e[0;34m\u@\h \w> \e[m"
{% endcodeblock%}
Đoạn code trên có nghĩa là gì:

{% img /images/UnixCommandPrompt/PS1-2.png %}

Hacking thêm một chút nữa, bạn hiện là một developer đang sử dụng git với rất nhiều repo, rất nhiều branch. Mỗi lần vào một repo nào đấy bạn lại phải {git branch} để xem bạn đang ở branch nào, bất tiện vô cùng. Bạn muốn prompt của bạn sẽ hiện branch name mỗi khi bạn vào folder của một repo nào đấy? Thật đơn giản, với backquote để execute bash command và sự trợ giúp của sed, bạn làm điều đó thật đơn giản:

{% codeblock PS1 PS1.sh %}
export PS1='\e[0;36m\u⌘ \e[0;35m\W \e[0;33m`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\*\ \(.+\)$/\(\1\)\ /`\e[m\]'
{%endcodeblock%}

Trông có vẻ đáng sợ, nhưng thực ra lại rất đơn giản :D, Chúng ta sẽ đi từng phần nhé:

*  \e[ : start của command prompt
*  [0;36m\u⌘ : bạn tô màu phần user (\u) bởi 0;36m (màu xanh dương) và thêm vào đằng sau cái kí tự ⌘ (cho cool thôi :D)
*  \e[0;35m\W : bạn tô màu phần directory hiện tại (\W) bởi 0;35m (màu hồng)
*  \e[0;33m : tô màu **toàn bộ phần đằng sau** bởi màu 0;33m (màu vàng)
*  git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /: nguyên văn đoạn này sẽ như sau: đầu tiên bạn dùng "git branch" để lấy branch hiện tại. Trong trường hợp không ở trong git repo nào thì sẽ có lỗi ra stderr, bạn redirect cái lỗi này vào dev/null thông qua "2> /dev/null" để nó không hiện ra prompt (2 là stderr). Sau đấy bạn tìm line nào có * ở đầu (current git branch) thông qua việc pipe vào grep. Tìm được line đó rồi thì bạn sẽ tách phần đằng sau dấu * ra thông qua sed , và output phần đó ra ngoài với format (branch) thông qua $/\(\1\). Tất cả đoạn code này được để vào backquote để được execute trực tiếp mỗi khi PS1 được gọi. Và kết quả thật bất ngờ:

{% img /images/UnixCommandPrompt/PS1-3.png %}

Looks so cool!!
Ngoài ra bạn còn có rất nhiều thứ có thể hacking với PS1 như:

*  \j the number of jobs currently managed by the shell
*  \# the command number of this command
*  \l the basename of the shell's terminal device name
.....
mà bạn có thể tham khảo ở đây: http://www.thegeekstuff.com/2008/09/bash-shell-ps1-10-examples-to-make-your-linux-prompt-like-angelina-jolie/

##Ending##
Như vậy với PS[1-4], bạn đã có thể customize command prompt của bạn trở nên đẹp đẽ hơn, cool hơn và useful hơn. Trong các bài viết sắp tới mình sẽ nói về việc sử dụng các công cụ rất mạnh của unix family os như grep, sed, wc để giúp cho công việc development của bạn trở nên thú vị hơn :D. Happy hacking!

