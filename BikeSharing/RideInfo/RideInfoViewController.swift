//
//  RideInfoViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit

class RideInfoViewController: UIViewController {
    
    var viewModel: RideInfoViewModel!
    
    var completionHandler: (()->())?
    
    
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var bottomButton: BSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        if self.navigationItem.backBarButtonItem == nil {
//            self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close)), animated: false)
//        }
    }
    
    @IBAction func close() {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        completionHandler?()
    }
}
