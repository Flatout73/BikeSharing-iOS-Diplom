//
//  AccountViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import AlamofireImage

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
    
    func paymentMethod() {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "PaymentMethodController") else { return }
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func exit() {
        
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
