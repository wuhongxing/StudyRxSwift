//
//  DisposableViewController.swift
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
 一般来说，一个序列如果发出了 error 或者 completed 事件，那么所有内部资源都会被释放。
 */
class DisposableViewController: UIViewController {
    
    var disposable: Disposable?
    var disposeBag = DisposeBag()
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        _ = textField.rx.text.orEmpty.takeUntil(rx.deallocated).subscribe { (event) in
//            print(event)
//        }
        
//        _ = textField.rx.text.orEmpty.subscribe { (event) in
//            print(event)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.disposable = textField.rx.text.orEmpty.subscribe(onNext: { text in print(text) })
//        textField.rx.text.orEmpty.subscribe(onNext: { text in print(text) }).disposed(by: disposeBag)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.disposable?.dispose()
//        disposeBag = DisposeBag()
    }
    
    deinit {
        print("DisposableViewController deinit")
    }

}
