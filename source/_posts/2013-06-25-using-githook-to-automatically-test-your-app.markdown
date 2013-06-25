---
layout: post
title: "Giới thiệu về Githook và Client side hook"
date: 2013-06-25 21:07
comments: true
categories: git
---

# Githook là gì

Giống như các hệ thống quản lý version khác, Git cung cấp một cách để gọi những custom script khi một hành động đặc biệt được thực hiện trong git. Có 2 nhóm hook trong git: hook cho client, và hook cho server. Client hook là dành cho những hoạt động xảy ra ở client như commit và merge. Server hook là dành cho những hoạt động xảy ra ở Git server như nhận được một commit push lên từ client. Bài viết này giới thiệu một số cách sử dụng hook cả client side hook

# Install hook

Các hooks được lưu trong thư mục `hooks` của `.git` folder. Trong phần lớn các project, nó là `.git/hooks`. Ở chế độ mặc định, Git cung cấp một loạt các examples cho các hooks, các ví dụ này đưa ra khá nhiều chỉ dẫn về inputs của mỗi hook. Tất cả các examples được viết bằng shell script, với một vài mã lệnh Perl, tuy nhiên bạn có thể viết các script này bằng bất cứ ngôn ngữ nào (ví dụ như Python, Ruby). Tất cả các examples đều có tên kết thúc bằng `.sample`, bạn cần đổi tên các script trước khi chạy

Để enable các hook script, đặt một file trong thư mục `hooks` với tên tương ứng với tên của hook, và set quyền cho script đó là executable.

# Client side hooks

Có rất nhiều loại client side hooks, chúng ta chia chúng theo work flow

## Committing-Workflow Hooks

`pre-commit` hook được gọi đầu tiên, trước khi bạn gõ nội dung của một commit message. Hook này được sử dụng để kiểm tra nội dụng các files được commit. Bạn có thể viết script để kiểm tra coding convetion, hoặc để run test, để chạy static analysis trước khi commit. Nếu script trả về kết quả khác 0, commit sẽ bị loại bỏ. Tuy nhiên bạn có thể bỏ qua chạy hook này khi commit với lệnh `git commit --no-verify`

`prepare-commit-msg` là hook được chạy trước khi trình soạn thảo commit message được gọi đế và sau khi message mặc định được tạo ra. Hook này giúp bạn thay đổi default message trước khi commit author thấy nó. Hook này về cơ bản là ít khi hữu dụng, chỉ trừ khi các commit message được sinh ra tự động.

`commit-msg` hook nhận duy nhất một input là đường dẫn của file chứa commit message. Nếu script này trả về kết quả khác 0, commit sẽ bị loại bỏ. Hook này có tác dụng giúp bạn chuẩn hoá mesage trước khi commit

Sau khi toàn bộ quá trình commit được hoàn tất, `post-commit` hook sẽ chạy. hook này không nhận tham số đầu vào, nhưng bạn có thể dễ dàng lầy last commit bằng cách gọi `git log -1 HEAD`. Thông thường, hook này dụng để notification.

Committing-workflow client side scripts được sử dụng và setup bới chính các developer tại máy local của họ. Các developers phải tự maintain chúng, tuy nhiên họ có thể thay đổi chúng bất cứ lúc nào

## Email workflow hooks

Bạn có thể set up 3 client side hooks cho email workflow. Tất cả các hooks này đều liên quan đến `git am` command. Nếu bạn không sử dụng câu lệnh này trong workflow của bạn, bạn có thể bỏ qua phần này. Nếu bạn nhận patch qua email được chuẩn bị bới lệnh `git format-patch`, thì có thể những hook này sẽ có ích với bạn

Hook đầu tiên là `applypatch-msg`. Nó nhận một tham số: tên của file tạm chứ nội dụng của commit message. Git sẽ bỏ qua patch nếu hook này trả về giá trị khác 0. Bạn có thể sử dụng hook này để đảm bảo commit message là đúng chuẩn.

Hook tiếp theo khi apply patches thông qua `git am` là `pre-applypatch`. Hook không nhận giá trị đầu vào và được chay sau khi patch được applied. Vì thế bạn có thể sử dụng hook này để kiểm tra toàn bộ mã nguồn trước khi make commit. VD: chạy test, chạy static analysis, kiểm tra style (hook này tương đối giống `pre-commit` trong phần trước)

Hook cuối cùng được chạy trong process của `git am` là `post-applypatch`. Bạn có thể sử dụng nó để notify cho một group hoặc một author về patch này.

## Một vài client hooks khác

`pre-rebase` hooks run trước khi bạn rebase bất cứ commit nào, và sẽ cả process lại nếu hook trả về giái trị khác 0.

`post-checkout` được gọi sau khi bạn chạy lệnh `git checkout` thành công. Bạn có thể sử dụng nó để setup environment, hoặc tự động sinh document sau khi checkout

`post-merge` hook được chạy sau khi bạn chạy lệnh `git merge`. Bạn có thể sử dụng để phục hồi lại dữ liệu trong thư mục làm việc mà Git không thể kiểm tra ví dụ như dữ liệu liên quan đến permission.

# Kết luận

Bài viết giới thiệu về githooks và một số client hooks thường dùng. Hy vọng bạn tìm thấy một vài thông tin hữu ích giúp bạn tự động hoá một số công việc hàng ngày khi làm việc với git.


# Tham khảo
[Githook documentation](http://git-scm.com/book/en/Customizing-Git-Git-Hooks)











