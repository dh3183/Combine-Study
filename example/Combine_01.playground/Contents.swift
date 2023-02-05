import UIKit
import Combine

var myIntArrayPublisher: Publishers.Sequence<[Int], Never> = [1,2,3].publisher

//myIntArrayPublisher.sink(receiveCompletion: { completion in
//    switch completion {
//    case .finished:
//        print("완료")
//    case .failure(let error):
//        print("실패: error: \(error)")
//    }
//}, receiveValue: { recerivedValue in
//    print("값을 받았다. : \(recerivedValue)")
//})

var mySubscription: AnyCancellable?

var mySubscriptionSet = Set<AnyCancellable>()

var myNotification = Notification.Name("com.elbin.customNotification")

var myDefaultPublisher = NotificationCenter.default.publisher(for: myNotification)

mySubscription = myDefaultPublisher.sink(receiveCompletion: { completion in
    switch completion {
    case .finished:
        print("완료")
    case .failure(let error):
        print("실패: error: \(error)")
    }
}, receiveValue: { receivedValue in
    print("받은 값: \(receivedValue)")
})

// 매개변수를 in-out을 통해 변경 가능
mySubscription?.store(in: &mySubscriptionSet)

NotificationCenter.default.post(Notification(name: myNotification))
NotificationCenter.default.post(Notification(name: myNotification))
NotificationCenter.default.post(Notification(name: myNotification))

//MARK: KVO - Key value observing

class MyFriend {
    var name = "철수" {
        didSet {
            print("name - didSet() : ", name)
        }
    }
}

var myFriend = MyFriend()

var myFriendSubscription: AnyCancellable = ["영수"].publisher.assign(to: \.name, on: myFriend)
