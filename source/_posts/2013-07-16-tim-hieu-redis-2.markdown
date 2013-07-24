---
layout: post
title: "Tìm hiểu redis (phần 2): Framework lập trình sự kiện"
date: 2013-07-16 00:00
comments: true
categories: system linux
---

## 1. Giới thiệu

Trong bài viết [tìm hiểu redis phần 1][], chúng ta đã tìm hiểu cách redis quản lý dữ liệu (AOF và RDB) cũng như cách redis tận dụng các tính năng của OS (fsync) để sao lưu dữ liệu. Bài viết này tập trung trình bày cụ thể hơn về framework lập trình hướng sự kiện của redis.

[tìm hiểu redis phần 1]: http://ktmt.github.io/blog/2013/07/02/tim-hieu-redis/

## 2. Lập trình hướng sự kiện

[Lập trình hướng sự kiện][] không phải là khái niệm mới, mà là một paradigm dược sử dụng từ rất lâu. Trong lập trình GUI (Giao diện đồ họa), khi người dùng click hay di chuyển chuột, các framework đồ họa thường hỗ trợ các phương pháp như onClick, onMouseMove ... cho phép người dùng định nghĩa hành vi của hệ thống cho những sự kiện đấy. 

[Lập trình hướng sự kiện]: http://en.wikipedia.org/wiki/Event-driven_programming

Các hệ thống Unix(BSD, MacOS)/Linux/Solaris từ lâu đã hỗ trợ lập trình hướng sự kiện. Mỗi hệ điều hành cung cấp API cho phép lập trình viên chỉ định 1 tập các file descriptor hoặc mốc thời gian (time-event) cần theo dõi và sẽ trigger mỗi sự kiện khi các file descriptor thay đổi trạng thái (có đọc hoặc ghi) hoặc khi một mốc thời gian quan trọng đã đến. Lập trình viên hệ thống chỉ cần cung cấp 1 hàm callback và các API này sẽ thực hiện chạy các callback này. Cụ thể:

* [select][] Chuẩn POSIX đình nghĩa hàm này.
* Unix (BSD, MacOS): [kqueue][]
* Linux: poll, [epoll][] (edge-trigger)
* Solaris: [event ports][] (port_associate)

[select]: http://en.wikipedia.org/wiki/Select_%28Unix%29
[kqueue]: people.freebsd.org/~jlemon/papers/kqueue.pdf
[epoll]: http://man7.org/linux/man-pages/man7/epoll.7.html
[event ports]: http://docs.oracle.com/cd/E19082-01/819-2243/port-associate-3c/index.html


Việc các hệ thống đều hỗ trơ cơ chế event multiplexing là điều tốt (hệ thống của bạn sẽ không phải thay đổi design nếu muốn hỗ trợ 1 hệ thống đặc biệt) tuy vậy có một khó khăn đó là: các API này có interface khác nhau. Do vậy đoạn code dùng epoll sẽ không thể nào chạy trên các Unix based và ngược lại một đoạn code dùng kqueue sẽ không chạy được trên linux. Để giải quyết vấn đề này, redis cung cấp 1 layer hướng sự kiện và thay đổi backend API (kqueue, event ports, epoll) theo hệ thống mà redis được biên dịch trên đó.

## 3. Framework

### a. Kiến trúc
						╒========================╕
						|  Redis layer cao hơn   | (aof, rdb, cron...)
						╘========================╛

						╒========================╕
						|     API layer hướng    | frontend: aeCreateEventLoop, aeStop, aeCreateFileEvent... 
						|       sự kiện          | backend: aeAddEvent, aeDelEvent, aeApiPoll...
						╘========================╛

		╒=============╕		╒=============╕		╒=============╕		╒=============╕
		|   select    |		|   kqueue    |		|   epoll     |		| event ports |
		╘=============╛		╘=============╛		╘=============╛		╘=============╛
		ae_select.c		ae_kqueue.c            	ae_epoll.c          	 ae_evport.c


Để hỗ trợ các event multiplexing api khác nhau của các hệ điều hành, redis xây dựng 1 api layer đứng giữa các layer cao hơn và các api của OS (như trong hình vẽ). Layer này có 2 loại api khác nhau: frontend và backend.

* frontend api: là các api cho phép các layer ở trên thao tác với các sự kiện và **vòng lặp sự kiện** (event loop). Các api này gồm có:
aeCreateEventLLoop, aeStop, aeMain, aeCreateFileEvent, aeCreateTimeEvent...
* backend api: thực chất là interface api. Các api hệ thống khác nhau sẽ được viết để phù hợp với interface này. Interface này gồm các api như: aeAddEvent, aeDelEvent, aeApiPoll, aeApiName.

frontend api sẽ gọi backend api để taoji các sự kiện, poll các file descriptor... Các backend api sẽ đối chiếu sử dụng tương ứng với api của hệ thống. Việc sử dụng api nào sẽ được quyết định lúc biên dịch.

Để thống nhất các polling api khác nhau về cùng 1 interface, redis định nghĩa các cấu trúc dữ liệu giống nhau với mỗi api, cụ thể là các sự kiện và **vòng lặp sự kiện**. Các cấu trúc này được viết trong file ae.h

{% codeblock ae.c %}
#ifndef __AE_H__
#define __AE_H__

#define AE_OK 0
#define AE_ERR -1

#define AE_NONE 0
#define AE_READABLE 1
#define AE_WRITABLE 2

#define AE_FILE_EVENTS 1
#define AE_TIME_EVENTS 2
#define AE_ALL_EVENTS (AE_FILE_EVENTS|AE_TIME_EVENTS)
#define AE_DONT_WAIT 4

#define AE_NOMORE -1

/* Macros */
#define AE_NOTUSED(V) ((void) V)

struct aeEventLoop;

/* Types and data structures */
typedef void aeFileProc(struct aeEventLoop *eventLoop, int fd, void *clientData, int mask);
typedef int aeTimeProc(struct aeEventLoop *eventLoop, long long id, void *clientData);
typedef void aeEventFinalizerProc(struct aeEventLoop *eventLoop, void *clientData);
typedef void aeBeforeSleepProc(struct aeEventLoop *eventLoop);

/* File event structure */
typedef struct aeFileEvent {
    int mask; /* one of AE_(READABLE|WRITABLE) */
    aeFileProc *rfileProc;
    aeFileProc *wfileProc;
    void *clientData;
} aeFileEvent;

/* Time event structure */
typedef struct aeTimeEvent {
    long long id; /* time event identifier. */
    long when_sec; /* seconds */
    long when_ms; /* milliseconds */
    aeTimeProc *timeProc;
    aeEventFinalizerProc *finalizerProc;
    void *clientData;
    struct aeTimeEvent *next;
} aeTimeEvent;

/* A fired event */
typedef struct aeFiredEvent {
    int fd;
    int mask;
} aeFiredEvent;

/* State of an event based program */
typedef struct aeEventLoop {
    int maxfd;   /* highest file descriptor currently registered */
    int setsize; /* max number of file descriptors tracked */
    long long timeEventNextId;
    time_t lastTime;     /* Used to detect system clock skew */
    aeFileEvent *events; /* Registered events */
    aeFiredEvent *fired; /* Fired events */
    aeTimeEvent *timeEventHead;
    int stop;
    void *apidata; /* This is used for polling API specific data */
    aeBeforeSleepProc *beforesleep;
} aeEventLoop;

/* Prototypes */
aeEventLoop *aeCreateEventLoop(int setsize);
void aeDeleteEventLoop(aeEventLoop *eventLoop);
void aeStop(aeEventLoop *eventLoop);
int aeCreateFileEvent(aeEventLoop *eventLoop, int fd, int mask,
        aeFileProc *proc, void *clientData);
void aeDeleteFileEvent(aeEventLoop *eventLoop, int fd, int mask);
int aeGetFileEvents(aeEventLoop *eventLoop, int fd);
long long aeCreateTimeEvent(aeEventLoop *eventLoop, long long milliseconds,
        aeTimeProc *proc, void *clientData,
        aeEventFinalizerProc *finalizerProc);
int aeDeleteTimeEvent(aeEventLoop *eventLoop, long long id);
int aeProcessEvents(aeEventLoop *eventLoop, int flags);
int aeWait(int fd, int mask, long long milliseconds);
void aeMain(aeEventLoop *eventLoop);
char *aeGetApiName(void);
void aeSetBeforeSleepProc(aeEventLoop *eventLoop, aeBeforeSleepProc *beforesleep);

#endif
{% endcodeblock %}

Theo như ae.h, redis có 3 kiểu sự kiện khác nhau: 

* Sự kiện trên File (đọc, ghi) (aeFileEvent)
* Sự kiện thời gian (aeTimeEvent)
* Sự kiện đã được triggered (aeFiredEvent)

Các callback prototype đều nhận đối số đầu tiên là 1 con trỏ chỉ đến cấu trúc aeEventLoop. Cấu trúc này quản lý rất nhiều thông tin khác nhau như: số sự kiện được đăng ký, sự kiện được gọi, file descriptor lớn nhất đang quản lý, danh sách các **sự kiện thời gian** v.v

### b. Chi tiết thực hiện

Toàn bộ quá trình xử lý sự kiện được bắt đầu bằng cách gọi aeMain. Xử lý trong aeMain thực chất là một vòng lặp gọi hàm xử lý sự kiện: aeProcessEvents. Tất cả các sự kiện sẽ được thực thi ở hàm aeProcessEvents này. Ta hãy cùng tìm hiểu công việc mà aeProcessEvent phải làm.

{% codeblock ae.c %}

void aeMain(aeEventLoop *eventLoop) {
    eventLoop->stop = 0;
    while (!eventLoop->stop) {
        if (eventLoop->beforesleep != NULL)
            eventLoop->beforesleep(eventLoop);
        aeProcessEvents(eventLoop, AE_ALL_EVENTS);
    }
}

/* Process every pending time event, then every pending file event
 * (that may be registered by time event callbacks just processed).
 * Without special flags the function sleeps until some file event
 * fires, or when the next time event occurs (if any).
 *
 * If flags is 0, the function does nothing and returns.
 * if flags has AE_ALL_EVENTS set, all the kind of events are processed.
 * if flags has AE_FILE_EVENTS set, file events are processed.
 * if flags has AE_TIME_EVENTS set, time events are processed.
 * if flags has AE_DONT_WAIT set the function returns ASAP until all
 * the events that's possible to process without to wait are processed.
 *
 * The function returns the number of events processed. */
int aeProcessEvents(aeEventLoop *eventLoop, int flags)
{
    int processed = 0, numevents;

    /* Nothing to do? return ASAP */
    if (!(flags & AE_TIME_EVENTS) && !(flags & AE_FILE_EVENTS)) return 0;

    /* Note that we want call select() even if there are no
     * file events to process as long as we want to process time
     * events, in order to sleep until the next time event is ready
     * to fire. */
    if (eventLoop->maxfd != -1 ||
        ((flags & AE_TIME_EVENTS) && !(flags & AE_DONT_WAIT))) {
        int j;
        aeTimeEvent *shortest = NULL;
        struct timeval tv, *tvp;

        if (flags & AE_TIME_EVENTS && !(flags & AE_DONT_WAIT))
            shortest = aeSearchNearestTimer(eventLoop);
        if (shortest) {
            long now_sec, now_ms;

            /* Calculate the time missing for the nearest
             * timer to fire. */
            aeGetTime(&now_sec, &now_ms);
            tvp = &tv;
            tvp->tv_sec = shortest->when_sec - now_sec;
            if (shortest->when_ms < now_ms) {
                tvp->tv_usec = ((shortest->when_ms+1000) - now_ms)*1000;
                tvp->tv_sec --;
            } else {
                tvp->tv_usec = (shortest->when_ms - now_ms)*1000;
            }
            if (tvp->tv_sec < 0) tvp->tv_sec = 0;
            if (tvp->tv_usec < 0) tvp->tv_usec = 0;
        } else {
            /* If we have to check for events but need to return
             * ASAP because of AE_DONT_WAIT we need to set the timeout
             * to zero */
            if (flags & AE_DONT_WAIT) {
                tv.tv_sec = tv.tv_usec = 0;
                tvp = &tv;
            } else {
                /* Otherwise we can block */
                tvp = NULL; /* wait forever */
            }
        }

        numevents = aeApiPoll(eventLoop, tvp);
        for (j = 0; j < numevents; j++) {
            aeFileEvent *fe = &eventLoop->events[eventLoop->fired[j].fd];
            int mask = eventLoop->fired[j].mask;
            int fd = eventLoop->fired[j].fd;
            int rfired = 0;

	    /* note the fe->mask & mask & ... code: maybe an already processed
             * event removed an element that fired and we still didn't
             * processed, so we check if the event is still valid. */
            if (fe->mask & mask & AE_READABLE) {
                rfired = 1;
                fe->rfileProc(eventLoop,fd,fe->clientData,mask);
            }
            if (fe->mask & mask & AE_WRITABLE) {
                if (!rfired || fe->wfileProc != fe->rfileProc)
                    fe->wfileProc(eventLoop,fd,fe->clientData,mask);
            }
            processed++;
        }
    }
    /* Check time events */
    if (flags & AE_TIME_EVENTS)
        processed += processTimeEvents(eventLoop);

    return processed; /* return the number of processed file/time events */
}
{% endcodeblock %}

Hàm aeProcessEvents làm 3 nhiệm vụ chính: 

* Tìm sự kiện có thời gian timeout gần nhất
* Lắng nghe sự kiện File, với thời gian poll không quá thời gian sự kiện gần nhất ở trên.
* Với các sự kiện được triggered (file có thể đọc, ghi; thời gian timeout đã đến), chạy các callback được đăng ký với các sự kiện.

Việc tìm thời gian timeout gần nhất ở đầu vòng lặp nhằm hạn chế thấp nhất khả năng delay của các sự kiện thời gian (Nên nhớ serverCron chạy với thời gian timeout 1ms trên 1 lần). 

Sau khi xử lý lần lượt các xử lý các sự kiện file, redis sẽ xử lý các sự kiện thời gian. Xử lý sự kiện thời gian cũng khá đơn giản. Redis lần lượt xét từng sự kiện thời gian trong danh sách các sự kiện thời gian và gọi callback với các sự kiện đã quá thời hạn. Tuy nhiên, ta sẽ thấy 1 đoạn code khá **mập mờ** ở đầu xử lý sự kiện thời gian, với comment như dưới đây:

{% codeblock ae.c %}
    /* If the system clock is moved to the future, and then set back to the
     * right value, time events may be delayed in a random way. Often this
     * means that scheduled operations will not be performed soon enough.
     *
     * Here we try to detect system clock skews, and force all the time
     * events to be processed ASAP when this happens: the idea is that
     * processing events earlier is less dangerous than delaying them
     * indefinitely, and practice suggests it is. */
    if (now < eventLoop->lastTime) {
        te = eventLoop->timeEventHead;
        while(te) {
            te->when_sec = 0;
            te = te->next;
        }
    }
    eventLoop->lastTime = now;
    ...
{% endcodeblock %}

Làm sao thời gian hệ thống trả về bởi time(NULL) có thể nhỏ hơn thời gian xử lý được ghi nhận lần trước đấy được? Thực chất ở đây, antirez đã cân nhắc rất kỹ 1 tính huống có thể xảy ra với hệ thống thời gian của Linux. Trong điều kiện hoạt động bình thường, thời gian hệ thống sẽ luôn tăng. Tuy vậy, với 1 số trường hợp rủi ro: 

* Nguồn cung cấp điện không đủ.
* Pin CMOS có vấn đề.

1s trong máy tính có thể bằng 2, 3s trong thời gian thực, nói cách khác đồng hồ máy tính sẽ bị chạy chậm đi. Với tình huống này các sự kiện thời gian sẽ bị sai lệch và redis sẽ hoạt động không bình thường. Đấy chính là lý do antirez thêm đoạn code trên.

## 4. Redis dùng framework này như thế nào?

- Sự kiện file được sử dụng ở redis client và cluster. Thực chất các redis instance cần phải liên lạc với nhau để trao đổi dữ liệu. Việc trao đổi này tiến hành qua mạng và vì vậy hệ thống không thể nào biết khi nào dữ liệu mới sẽ đến. Thay vì phải chờ dữ liệu, bằng cách dùng framework sự kiện, hệ thống có thể tiến hành các xử lý có ưu tiên cao hơn môt cách **bất đồng bộ**, nâng cao hiệu năng của hệ thống.
- Sự kiện thời gian được sử dụng để định kỳ gọi cronServer (Nhiệm vụ của cronServer: [tìm hiểu redis phần 1][]).

## 5. Kết luận
Redis sử dụng phương pháp lập trình hướng sự kiện để định kỳ gọi các thủ tục backup dữ liệu cũng như quản lý các kết nối từ client. Redis hỗ trợ kqueue, epoll và event port nên hiệu năng đạt được khá cao.

## 6. Tham khảo

1. [C10K][]
2. [kqueue][]
3. [epoll][]
4. [event ports][]
5. [redis mailing list][]
6. IOCP [Input/output completion port][]

[C10K]: http://www.kegel.com/c10k.html
[redis mailing list]: https://groups.google.com/forum/#!forum/redis-db
[Input/output completion port]: http://en.wikipedia.org/wiki/Input/output_completion_port

