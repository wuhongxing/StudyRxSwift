//
//  ErrorHandlingViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/5.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

/*
 错误处理
 一旦序列里面产出一个 error 事件，整个序列将被终止。
 retry - 重试
 catch - 恢复
 */
class ErrorHandlingViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let driver = Driver.combineLatest(textField1.rx.text.orEmpty.asDriver(), textField2.rx.text.orEmpty.asDriver())
        button.rx.tap.withLatestFrom(driver).flatMapLatest { (t1, t2) in
            return Observable<String>.create { (ob) -> Disposable in
                ob.onNext("t1: \(t1)")
                ob.onNext("t2: \(t2)")
                ob.onError(NSError(domain: "error", code: 0, userInfo: nil))
                return Disposables.create()
            }.catchErrorJustReturn("error-----")
            /// 一旦网络请求操作失败了，序列就会终止。整个订阅将被取消。
            /// 如果用户再次点击更新按钮，就无法再次发起网络 请求进行更新操作了
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (s) in
            print(s)
        }, onError: { (error) in
            print(error.localizedDescription)
        }).disposed(by: rx.disposeBag)
    }
    
}
