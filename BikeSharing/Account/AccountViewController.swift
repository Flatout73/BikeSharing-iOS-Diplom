//
//  AccountViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyUserDefaults

class AccountTableViewController: UITableViewController {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    
    var service: AccountService!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = service.getUser() {
            nameLabel.text = user.name
            
            if let url = user.pictureURL {
                avatarImage.af_setImage(withURL: URL(string: url)!, filter: CircleFilter())
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsHelper.event(name: "account_show")
    }
  
    func paymentMethod() {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMethodController") else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func exitFromApp() {
        service.coreDataManager.destroyDatabase()
        Defaults[.token] = nil
        
        exit(0)
    }
    
    func sendFeedback() {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "FeedbackController") else { return }
        self.navigationController?.pushViewController(controller, animated: true)
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
                paymentMethod()
            case 1:
                sendFeedback()
            case 2:
                exitFromApp()
            default:
                break
            }
        default:
            break
        }
    }
}
