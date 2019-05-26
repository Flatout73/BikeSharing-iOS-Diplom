//
//  AccountViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func exit() {
        
    }
    
    func sendFeedback() {
        
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .black
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = .black
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                break
            case 1:
                sendFeedback()
            case 3:
                self.exit()
            default:
                break
            }
        default:
            break
        }
    }
}
