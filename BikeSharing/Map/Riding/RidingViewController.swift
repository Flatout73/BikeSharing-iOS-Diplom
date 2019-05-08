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
    
    var paymentInfo: PaymentBike!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        startTime = Date()
        
        formatter.allowedUnits = [.hour, .minute, .second]
    }
    
    @objc func fireTimer() {
        timeLabel.text = formatter.string(from: Date().timeIntervalSince(startTime))
    }
    @IBAction func close(_ sender: Any) {

        ApiService.payRequest(token: paymentInfo.token, amount: 50.5) { error in
            if let error = error {
                NotificationBanner.showErrorBanner(error.localizedDescription)
            } else {
                self.timer?.invalidate()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "RideInfoViewController")
//                let navigationItem = UINavigationItem(title: "Info")
//                navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismiss))
//
//                let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
//                navigationBar.setItems([navigationItem], animated: false)
//                controller.view.addSubview(navigationBar)
                
                (controller as? RideInfoViewController)?.completionHandler = {
                    self.dismiss(animated: false, completion: nil)
                }
            
                self.present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
            }
        }
    }
}
