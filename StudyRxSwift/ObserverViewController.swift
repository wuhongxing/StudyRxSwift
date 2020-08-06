//
//  ObserverViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/5.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import NSObject_Rx

class ObserverViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        testAnyObserver()
//        testBinder()
        testBinder1()
    }
    
    private func testAnyObserver() {
        let observer: AnyObserver<Bool> = AnyObserver { [weak self] event in
            switch event {
            case .next(let isHidden):
                self?.alertLabel.isHidden = isHidden
            default:
                break
            }
        }
        textField.rx.text.orEmpty.map { $0.count > 5 }.bind(to: observer).disposed(by: rx.disposeBag)
    }
    
    private func testBinder() {
        let binder = Binder<Bool>(self.alertLabel) { (self, isHidden) in
            self.isHidden = isHidden
        }
        textField.rx.text.orEmpty.map { $0.count > 5 }.bind(to: binder).disposed(by: rx.disposeBag)
    }
    
    private func testBinder1() {
        textField.rx.text.orEmpty.map { $0.count > 5 }.bind(to: alertLabel.rx.test).disposed(by: rx.disposeBag)
    }
}

extension Reactive where Base == UILabel {
    var test: Binder<Bool> {
        Binder<Bool>(base) { (self, isHidden) in
            self.isHidden = isHidden
        }
    }
}
