//
//  RidingViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 29/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit

class RidingViewController: UIViewController {
    
    
    @IBOutlet var timeLabel: UILabel!
    
    var startTime = Date()
    let formatter = DateComponentsFormatter()
    
    var token: STPToken!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        startTime = Date()
        
        formatter.allowedUnits = [.hour, .minute, .second]
    }
    
    @objc func fireTimer() {
        timeLabel.text = formatter.string(from: Date().timeIntervalSince(startTime))
    }
    @IBAction func close(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
    }
}
