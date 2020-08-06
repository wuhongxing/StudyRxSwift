//
//  OperatorViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/5.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class OperatorViewController: UIViewController {

    let observable = Observable<Int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9])
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func filter(_ sender: Any) {
        observable.filter { $0 > 5 }.subscribe { (event) in
            print(event.element)
        }.disposed(by: rx.disposeBag)
    }
    
    @IBAction func map(_ sender: Any) {
        observable.map { "\($0)~" }.subscribe { (event) in
            print(event.element)
        }.disposed(by: rx.disposeBag)
    }
    
}
