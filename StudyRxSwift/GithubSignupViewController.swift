//
//  GithubSignupViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/8/5.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

extension String {
    var URLEscaped: String {
       return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

enum SignupState {
    case signedUp(signedUp: Bool)
}

protocol GitHubAPI {
    func usernameAvailable(_ username: String) -> Observable<Bool>
    func signup(_ username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<ValidationResult>
    func validatePassword(_ password: String) -> ValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

class GitHubDefaultAPI: GitHubAPI {
    
    let URLSession: Foundation.URLSession
    static let shared = GitHubDefaultAPI(URLSession: Foundation.URLSession.shared)
    
    init(URLSession: URLSession) {
        self.URLSession = URLSession
    }
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return URLSession.rx.response(request: request)
            .map { pair in
                return pair.response.statusCode == 404
        }.catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : true
        return Observable.just(signupResult).delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}

class GitHubDefaultValidationService: GitHubValidationService {
    
    let API: GitHubAPI
    
    static let shared = GitHubDefaultValidationService(API: GitHubDefaultAPI.shared)
    
    init(API: GitHubAPI) {
        self.API = API
    }
    
    let minPasswordCount = 5
    
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.isEmpty {
            return .just(.empty)
        }
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        let loadingValue = ValidationResult.validating
        return API.usernameAvailable(username).map { available in
            if available {
                return .ok(message: "Username available")
            } else {
                return .failed(message: "Username already taken")
            }
        }.startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        return .ok(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.count == 0 {
            return .empty
        }
        if repeatedPassword == password {
            return .ok(message: "Password repeated")
        } else {
            return .failed(message: "Password different")
        }
    }
}

class GithubSignupViewController: UIViewController {
    @IBOutlet weak var usernameTf: UITextField! {
        didSet {
            usernameTf.delegate = self
        }
    }
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var password1Tf: UITextField!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var usernameValid: UILabel!
    @IBOutlet weak var passwordValid: UILabel!
    @IBOutlet weak var password1Valid: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let username = usernameTf.rx.text.orEmpty.asDriver()
        let password = passwordTf.rx.text.orEmpty.asDriver()
        let repeatedPassword = password1Tf.rx.text.orEmpty.asDriver()
        let loginTaps = signupButton.rx.tap.asSignal()
        
        let API = GitHubDefaultAPI.shared
        let service = GitHubDefaultValidationService.shared
        
        let validatedUsername = username.flatMapLatest { (username) in
            return service.validateUsername(username).asDriver(onErrorJustReturn: .failed(message: "Error contacting server"))
        }
        
        let validatedPassword = password.map { (password) in
            return service.validatePassword(password)
        }
        
        let validatedPasswordRepeated = Driver.combineLatest(password, repeatedPassword, resultSelector: service.validateRepeatedPassword)
        
        let usernameAndPassword = Driver.combineLatest(username, password) { (username: $0, password: $1) }
        
        let _signingIn = ActivityIndicator()
        let signingIn = _signingIn.asDriver()
        
        let signedIn = loginTaps.withLatestFrom(usernameAndPassword).flatMapLatest {
            return API.signup($0, password: $1).trackActivity(_signingIn).asDriver(onErrorJustReturn: false)
        }.flatMapLatest { loggedIn -> Driver<Bool> in
            let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
            print(message)
            return Driver.just(false)
        }
        
        let signupEnabled = Driver.combineLatest(validatedUsername, validatedPassword, validatedPasswordRepeated, signingIn) { username, password, repeatPassword, signingIn in
            username.isValid && password.isValid && repeatPassword.isValid && !signingIn
        }.distinctUntilChanged()
        let signupColor = signupEnabled.map { $0 ? UIColor.green : UIColor.lightGray }
        
        validatedUsername.drive(usernameValid.rx.validationResult).disposed(by: rx.disposeBag)
        validatedPassword.drive(passwordValid.rx.validationResult).disposed(by: rx.disposeBag)
        validatedPasswordRepeated.drive(password1Valid.rx.validationResult).disposed(by: rx.disposeBag)
        signupEnabled.drive(signupButton.rx.isEnabled).disposed(by: rx.disposeBag)
        signupColor.drive(signupButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        signingIn.drive(activityView.rx.isAnimating).disposed(by: rx.disposeBag)
        signedIn.drive(onNext: { (signed) in
            print("User signed in \(signedIn)")
        }).disposed(by: rx.disposeBag)
    }
}

extension GithubSignupViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

extension Reactive where Base == UILabel {
    var textColor: Binder<UIColor> {
        Binder<UIColor>(base) { (self, textColor) in
            self.textColor = textColor
        }
    }
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

extension GithubSignupViewController {
    private func test() {
        let userDriver = usernameTf.rx.text.orEmpty.asDriver()
        let passwordDriver = passwordTf.rx.text.orEmpty.asDriver()
        let password1Driver = password1Tf.rx.text.orEmpty.asDriver()
        
        let nameValid = userDriver
            .map { $0.count == 0 ? "" : ($0.count < 5 ? "validating..." : "Username available") }
        let nameColor = userDriver.map { $0.count < 5 ? UIColor.red : UIColor.green }
        nameValid.drive(usernameValid.rx.text).disposed(by: rx.disposeBag)
        nameColor.drive(usernameValid.rx.textColor).disposed(by: rx.disposeBag)
        
        let passValid = passwordDriver.map { $0.count == 0 ? "" : ($0.count < 6 ? "password must be at least 6 character" : "password acceptable") }
        let passColor = passwordDriver.map { $0.count < 6 ? UIColor.red : UIColor.green }
        passValid.drive(passwordValid.rx.text).disposed(by: rx.disposeBag)
        passColor.drive(passwordValid.rx.textColor).disposed(by: rx.disposeBag)
        
        let ensureDirver = Driver.combineLatest(passwordDriver, password1Driver).map { (pass, pass1) in
            pass != pass1
        }
        let ensureValid = Driver.combineLatest(password1Driver, ensureDirver).map { $0.0.count == 0 ? "" : ($0.1 ? "password diffrent" : "password acceptable") }
        
        let ensureColor = Driver.combineLatest(passwordDriver, password1Driver).map { (pass, pass1) in
            pass != pass1
        }.map { $0 ? UIColor.red : UIColor.green }
        ensureValid.drive(password1Valid.rx.text).disposed(by: rx.disposeBag)
        ensureColor.drive(password1Valid.rx.textColor).disposed(by: rx.disposeBag)
        
        let driver = Driver.combineLatest(userDriver, passwordDriver, password1Driver).map { (t1, t2, t3) in
            t1.count > 0 && t2.count > 0 && t3.count > 0
        }.distinctUntilChanged()
        let background = driver.map { $0 ? UIColor.green : UIColor.gray }
        background.drive(signupButton.rx.backgroundColor).disposed(by: rx.disposeBag)
        driver.drive(signupButton.rx.isEnabled).disposed(by: rx.disposeBag)
    }
}

public class ActivityIndicator : SharedSequenceConvertibleType {
    public typealias Element = Bool
    public typealias SharingStrategy = DriverSharingStrategy

    private let _lock = NSRecursiveLock()
    private let _relay = BehaviorRelay(value: 0)
    private let _loading: SharedSequence<SharingStrategy, Bool>

    public init() {
        _loading = _relay.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }

    fileprivate func trackActivityOfObservable<Source: ObservableConvertibleType>(_ source: Source) -> Observable<Source.Element> {
        return Observable.using({ () -> ActivityToken<Source.Element> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }

    private func increment() {
        _lock.lock()
        _relay.accept(_relay.value + 1)
        _lock.unlock()
    }

    private func decrement() {
        _lock.lock()
        _relay.accept(_relay.value - 1)
        _lock.unlock()
    }

    public func asSharedSequence() -> SharedSequence<SharingStrategy, Element> {
        return _loading
    }
}

extension ObservableConvertibleType {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<Element> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}

private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Cancelable

    init(source: Observable<E>, disposeAction: @escaping () -> Void) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }

    func dispose() {
        _dispose.dispose()
    }

    func asObservable() -> Observable<E> {
        return _source
    }
}
