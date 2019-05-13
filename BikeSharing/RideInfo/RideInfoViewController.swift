//
//  RideInfoViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class RideInfoViewController: UIViewController {
    
    var ride: RideViewModel!
    
    var completionHandler: (()->())?
    
    
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var costLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet var bottomButton: BSButton!
    
    let dateFormatter = DateFormatter()
    let components = DateComponentsFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        if self.navigationItem.backBarButtonItem == nil {
//            self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close)), animated: false)
//        }
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        
        components.allowedUnits = [.hour, .minute, .second]
        components.unitsStyle = .short
        
        if let url = ride.imageURL {
            imageView.af_setImage(withURL: url)
        }
        
        startLabel.text = ride.startAddress
        endLabel.text = ride.endAddress
        
        dateTimeLabel.text = dateFormatter.string(from: ride.endTime!)
        costLabel.text = String(format: "%.2f", ride.cost!)
        timeLabel.text = components.string(from: ride.startTime, to: ride.endTime!)
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
