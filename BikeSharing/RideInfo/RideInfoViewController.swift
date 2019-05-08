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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationItem.backBarButtonItem == nil {
            self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close)), animated: false)
        }
    }
    
    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
        completionHandler?()
    }
}
