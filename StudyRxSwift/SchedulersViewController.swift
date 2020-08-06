//
//  SchedulersViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/5.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

/*
 subscribeOn 决定数据序列的构建函数在哪个 Scheduler 上运行
 observeOn 决定在哪个 Scheduler 监听这个数据序列
 
 可以使用 subscribeOn 切到后台去发送请求并解析数据
 最后用 observeOn 切换到主线程更新页面
 */

class SchedulersViewController: UIViewController {
    private var data: Data? {
        didSet {
            print(data ?? "----")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        rxTest()
    }
    
    private func test() {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(count: 100)
            DispatchQueue.main.async {
                self.data = data
            }
        }
    }
    
    private func rxTest() {
        let rxData = Observable<Data>.just(try! Data(count: 100))
        rxData
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .subscribe { (event) in
                print(event, Thread.current)
        }.disposed(by: rx.disposeBag)
    }
}
