//
//  ViewController.swift
//  StudyRxSwift
//
//  Created by wuhongxing on 2020/6/25.
//  Copyright © 2020 zto. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "RxSwift"
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(ObservableViewController(), animated: true)
        case 1:
            navigationController?.pushViewController(ObserverViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(SubjectViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(OperatorViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(DisposableViewController(), animated: true)
        case 5:
            navigationController?.pushViewController(SchedulersViewController(), animated: true)
        case 6:
            navigationController?.pushViewController(ErrorHandlingViewController(), animated: true)
        case 7:
            navigationController?.pushViewController(GithubSignupViewController(), animated: true)
            
        default:
            break
        }
    }
}

