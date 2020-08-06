//
//  SubjectViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/5.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SubjectViewController: UIViewController {
    
    @IBOutlet weak var asyncButton: UIButton!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var relayButton: UIButton!
    @IBOutlet weak var behaviorButton: UIButton!
    @IBOutlet weak var publishRelayButton: UIButton!
    @IBOutlet weak var behaviorRelayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        asyncButton.rx.tap.subscribe { (event) in
            self.testAsyncSubject()
        }.disposed(by: rx.disposeBag)
        
        publishButton.rx.tap.subscribe { (event) in
            self.testPublishSubject()
        }.disposed(by: rx.disposeBag)
        
        relayButton.rx.tap.subscribe { (event) in
            self.testReplaySubject()
        }.disposed(by: rx.disposeBag)
        behaviorButton.rx.tap.subscribe { (event) in
            self.testBehaviorSubject()
        }.disposed(by: rx.disposeBag)
        publishRelayButton.rx.tap.subscribe { (event) in
            self.testPublishRelay()
        }.disposed(by: rx.disposeBag)
        behaviorRelayButton.rx.tap.subscribe { (event) in
            self.testBehaviorRelay()
        }.disposed(by: rx.disposeBag)
    }
    
    private func testAsyncSubject() {
        let subject = AsyncSubject<String>()
        subject
            .subscribe { print("Subscription: 1 Event: ", $0) }
            .disposed(by: rx.disposeBag)
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        subject.onCompleted()
    }
    
    /*
     这个我感觉是最好理解的
     啥时候订阅啥时候才能接收到消息
     就像你进一个群，进群之前的消息你是看不见的
     PublishRelay 就是 PublishSubject 去掉终止事件 onError 或 onCompleted
     */
    private func testPublishSubject() {
        let subject = PublishSubject<String>()
        subject
            .subscribe { print("Subscription: 1 Event: ", $0) }
            .disposed(by: rx.disposeBag)
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
        subject
            .subscribe { print("Subscription: 2 Event: ", $0) }
            .disposed(by: rx.disposeBag)
        subject.onNext("4")
        subject.onNext("5")
        subject.onNext("6")
        subject.onCompleted()
    }
    
    /*
     有的会将最新的 n 个元素发送给观察者
     有的会将限制时间段内最新的元素发送给观察者
     */
    private func testReplaySubject() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        
        subject
            .subscribe { print("Subscription: 1 Event:", $0) }
            .disposed(by: rx.disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject
            .subscribe { print("Subscription: 2 Event:", $0) }
            .disposed(by: rx.disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
        subject.onCompleted()
    }
    
    /*
     其实就是发送一个默认值
     如果后面又发送过其他值的话，那么默认值就会刷新成其他值
     */
    private func testBehaviorSubject() {
        let subject = BehaviorSubject(value: "🔴")
        
        subject
            .subscribe { print("Subscription: 1 Event:", $0) }
            .disposed(by: rx.disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject
            .subscribe { print("Subscription: 2 Event:", $0) }
            .disposed(by: rx.disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
    }
    
    private func testPublishRelay() {
        let relay = PublishRelay<String>()
        relay
            .subscribe { print("Event: ", $0) }
            .disposed(by: rx.disposeBag)
        relay.accept("🐶")
        relay.accept("🐱")
    }
    
    private func testBehaviorRelay() {
        let relay = BehaviorRelay<String>(value: "🔴")
        relay
            .subscribe { print("Event: ", $0) }
            .disposed(by: rx.disposeBag)
        relay.accept("🐶")
        relay.accept("🐱")
    }
}
