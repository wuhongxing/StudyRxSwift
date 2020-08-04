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
        default:
            break
        }
    }
}

