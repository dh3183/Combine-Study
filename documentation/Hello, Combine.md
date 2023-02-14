# 🎁 Hello, Combine
> Customize handling of asynchronous events by combining event-processing operators.

* 시간 경과에 따라 변경되는 값을 내보내는 Publisher와 이를 수신하는 Subscriber로 시간 경과에 따른 값 처리를 위한 선언적 Swift API
* UIKit로 비동기 통신을 할 때 RxSwift를 이용하지만 SwiftUI를 사용할 땐 Combine을 사용함

## 🥑 Combine을 사용해야 하는 이유
* Delegate Pattern, Callback Function, Completion Closure 등을 활용해 비동기 프로그래밍을 구현할 수 있지만 Callback Function 혹은 Delegate Pattern이 늘어날수록 코드의 무게감이 증가한다.(Swift 5.5에서 Async, Await 등장)
* iOS 13부터 사용 가능

## 🥑 Publisher와 Subscriber
```Swift
protocol Publisher<Output, Failure>

protocol Subscriber<Input, Failure> : CustomCombineIdentifierConvertible
```

* 데이터와 에러 Type을 같이 내보내며 이벤트 데이터, 에러타입을 보내게된다.
* Publisher와 Subscriber는 서로 연결된 존재
* Publisher는 이벤트를 내보낸다는 설정을 두고 Subscriber가 Publisher를 Subscribe를 하면 Subscriber가 이벤트를 받을 수 있음
* Publisher의 연산자는 Just, Sequence, Future, Fail, Empty, Deferred, Record까지 해서 총 7가지가 있다.

<img width="500" src="https://user-images.githubusercontent.com/83414134/218549802-3d383253-21a7-4a05-b629-882e40a5ca19.png">

Publishers는 총 두 가지 ```typealias```를 선언했고 Publishers는 ```Output```과 ```Failure```를 내보낸다는것을 알 수 있다.

```Swift
var myIntArrayPublisher: Publishers.Sequence<[Int], Never> = [1,2,3].publisher
```

* Combine을 import하고 1, 2, 3이 담긴 Array를 Sequence 타입의 Publishers를 선언했다.
* Sequence는 **주어진 Sequence를 방출하는 Publisher**
* Never는 ```@frozen enum```인데 **The return type of functions that do not return normally, that is, a type with no values.**
* 즉, 정상적으로 리턴하지 않는 함수의 리턴 타입, 값이 없는 타입
* Combine에서는 Publisher가 오류를 생성하지 않는 경우 Never 타입으로 맞춘다.

```Swift
var myIntArrayPublisher: Publishers.Sequence<[Int], Never> = [1,2,3].publisher

myIntArrayPublisher.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        print("완료")
    case .failure(let error):
        print("실패: error : \(error)")
    }
}, receiveValue: { recerivedValue in
    print("값을 받았다. : \(recerivedValue)")
})
```

```Swift
// 결과

값을 받았다. : 1
값을 받았다. : 2
값을 받았다. : 3
완료
```

우선 위의 코드를 이해하기 위해선 sink에 대해 알아야 하는데 Apple Developer Documentation에선 다음과 같이 설명하고 있다.

```Swift
sink(receiveCompletion:receiveValue:)
```

```Swift
func sink(
    receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
    receiveValue: @escaping ((Self.Output) -> Void)
) -> AnyCancellable
```

> Attaches a subscriber with closure-based behavior.

즉, 클로저 기반의 동작이 있는 subscriber를 절대 실패하지 않게 하는 Publisher와 연결하는 것을 말하고 있다.
그렇기 때문에 에러 타입은 ```Never``` 일때만 가능하다. 

다시 원래 코드를 다시 들여다보면 

* myIntArrayPublisher를 통해 이벤트가 들어왔고 subscribe 했을 땐 즉각적으로 이벤트를 흘려보내게 된다. 그럼 recerivedValue를 통해 1,2,3을 받게되고 받을 때 마다 print 해준다.
*  receiveCompletion은 Switch를 이용해 stream이 성공적으로 종료되었음을 알려준다. finished일 때 print("완료")가 출력되면서 종료가된다. 
* failure는 해당 코드에서 사실상 일어나지 않기 때문에 해당 case를 타지 않는다.

## 🥑 NotificationCenter를 이용한 Combine
```Swift
var mySubscription: AnyCancellable?

var mySubscriptionSet = Set<AnyCancellable>()

var myNotification = Notification.Name("com.elbin.customNotification")

var myDefaultPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: myNotification)

mySubscription = myDefaultPublisher.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        print("완료")
    case .failure(let error):
        print("실패: error \(error)")
    }
}, receiveValue: { receivedValue in
    print("받은 값: \(receivedValue)")
})

mySubscription?.store(in: &mySubscriptionSet)

NotificationCenter.default.post(Notification(name: myNotification))
NotificationCenter.default.post(Notification(name: myNotification))
NotificationCenter.default.post(Notification(name: myNotification))
```

이것 또한 하나하나 뜯어본다면

```Swift
var mySubscription: AnyCancellable?
var mySubscriptionSet = Set<AnyCancellable>()
var myNotification = Notification.Name("com.elbin.customNotification")
var myDefaultPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: myNotification)
```

1. myDefaultPublisher에 ```NotificationCenter.default```인 publisher를 만들고 Notification의 Name을 담는 myNotification를 선언 후 publisher에 지정한다.
2. 해당 publisher를 활용해서 이벤트를 보내게 되는데 ```NotificationCenter.default.post```를 통해 이벤트를 알리게 되고 그 이름이 myNotification이다.

```Swift
var myNotification = Notification.Name("com.elbin.customNotification")
var myDefaultPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: myNotification)

NotificationCenter.default.post(Notification(name: myNotification))
NotificationCenter.default.post(Notification(name: myNotification))
NotificationCenter.default.post(Notification(name: myNotification))
```

이 상태로 그대로 두면 ```myDefaultPublisher```가 이벤트를 보냈지만 구독을 하지 않았기 때문에 받지 못하는 상태다.

```Swift
var mySubscription: AnyCancellable?
var mySubscriptionSet = Set<AnyCancellable>()
var myNotification = Notification.Name("com.elbin.customNotification")
var myDefaultPublisher: NotificationCenter.Publisher = NotificationCenter.default.publisher(for: myNotification)
```

## 🥑 KVO를 이용한 Combine
```Swift
import Combine
class MyFriend {
    var name = "철수" {
        didSet {
            print("name - didSet(): ", name)
        }
    }
}
var myFriend = MyFriend()
var myFriendSubscription: AnyCancellable = ["영수"].publisher.assign(to: \.name, on: myFriend)
```

### Cancellable
> A protocol indicating that an activity or action supports cancellation.

```Swift
protocol Cancellable
```

* Combine 작업들을 취소(cancellation)할 수 있다는 의미를 가지고 있는 프로토콜
* Combine에서는 이벤트 스트림을 action이라는 이름을 사용, action을 취소할 수 있는 프로토콜이 Cancellable 이라는 의미
* cancel()을 호출 시 할당 된 모든 리소스가 해제됨.
* Timer, Network Access, Disk I/O와 같은 사이드 이펙트 발생을 중지해 부작용을 막아주는 역할을 함

#### cancel()
```Swift
func cancel()
```

* 작업에 대한 취소 메서드
* cancel() 호출 시 다운 스트림 구독 호출을 중지하도록 해줌
* 호출 즉시 바로 취소 적용됨
* 즉, cancel() 메서드가 호출되고 나면 후속 호출에서 어떠한 작업도 진행되지 않음

```Swift
func sink(
    receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void),
    receiveValue: @escaping ((Self.Output) -> Void)
) -> AnyCancellable
```

sink 호출 시 구현체를 보면 반환 타입은 AnyCancellable인 것을 확인할 수 있는데 실행 후 해당 타입으로 반환해주는 걸 확인할 수 있다.

### AnyCancellable
```Swift
final class AnyCancellable
```

* 취소될 때 정의한 클로저 블록을 실행해주는 즉, 취소 해주는 객체를 의미함
* 이 구현에서는 sink안에서 반환으로 쓰이면 내부적으로 cancel()을 적절하게 호출하도록 되어 있음
* 즉, 해당 객체가 해제될 때 cancel()을 자동으로 호출하여 사용한다는 것

### Store
```Swift
final func store(in set: inout Set<AnyCancellable>)
```