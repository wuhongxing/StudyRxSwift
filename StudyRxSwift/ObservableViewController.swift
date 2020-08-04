//
//  ObservableViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/4.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx

class ObservableViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // 普通创建
    private func test0() {
        let numbers: Observable<Int> = Observable.create { (ob) -> Disposable in
            ob.onNext(0)
            ob.onNext(1)
            ob.onNext(2)
            ob.onNext(3)
            ob.onNext(4)
            ob.onNext(5)
            ob.onNext(6)
            ob.onNext(7)
            ob.onCompleted()
            return Disposables.create()
        }
        
    }
    
    @IBAction func singleButtonDidTouched(_ sender: UIButton) {
        getRepo("ReactiveX/RxSwift")
            .subscribe(onSuccess: { [unowned self] (json) in
                self.resultLabel.text = json.description
                print("JSON: ", json)
            }) { (error) in
                print("Error: ", error)
        }.disposed(by: rx.disposeBag)
    }
    
    private func getRepo(_ repo: String) -> Single<[String: Any]> {
        return Single<[String: Any]>.create { (single) -> Disposable in
            let url = URL(string: "https://api.github.com/repos/\(repo)")!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    single(.error(error))
                    return
                }
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves), let result = json as? [String: Any] else {
                    single(.error(NSError(domain: "can not parse json", code: 0, userInfo: nil)))
                    return
                }
                single(.success(result))
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }.observeOn(MainScheduler.instance)
    }
    
    @IBAction func completableButtonDidTouched(_ sender: UIButton) {
        cacheLocally().subscribe(onCompleted: { [unowned self] in
            self.resultLabel.text = "completed"
        }) { [unowned self] (error) in
            self.resultLabel.text = error.localizedDescription
        }.disposed(by: rx.disposeBag)
    }
    
    private func cacheLocally() -> Completable {
        return Completable.create { (completable) -> Disposable in
            let success = UserDefaults.standard.bool(forKey: "success")
            guard success else {
                completable(.error(NSError(domain: "cache failed", code: 0, userInfo: nil)))
                return Disposables.create()
            }
            completable(.completed)
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }
    
    @IBAction func maybeButtonDidTouched(_ sender: UIButton) {
        generateString()
        .subscribe(onSuccess: { element in
            self.resultLabel.text = "Completed with element \(element)"
        }, onError: { error in
            self.resultLabel.text = "Completed with an error \(error.localizedDescription)"
        }, onCompleted: {
            self.resultLabel.text = "Completed with no element"
        }).disposed(by: rx.disposeBag)
    }
    
    private func generateString() -> Maybe<String> {
        return Maybe<String>.create { (maybe) -> Disposable in
            maybe(.success("RxSwift"))
            maybe(.completed)
            maybe(.error(NSError(domain: "error", code: 0, userInfo: nil)))
            return Disposables.create()
        }
    }
    
    @IBAction func driverButtonDidTouched(_ sender: UIButton) {
        
    }
    
    @IBAction func signalButtonDidTouched(_ sender: UIButton) {
        
    }
    
    @IBAction func controlEventButtonDidTouched(_ sender: UIButton) {
        
    }
}
