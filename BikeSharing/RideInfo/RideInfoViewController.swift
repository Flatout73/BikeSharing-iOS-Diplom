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
    
    var shouldHideBottomButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 8
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
 //       if self.navigationController == nil {
//            self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.close)), animated: false)
//        }
        
        if shouldHideBottomButton {
            bottomButton.isHidden = true
        }
        
        if let url = ride.imageURL {
            imageView.af_setImage(withURL: url)
        }
        
        startLabel.text = ride.startAddress
        endLabel.text = ride.endAddress
        
        dateTimeLabel.text = ShortDateFormatter.string(from: ride.endTime!)
        costLabel.text = String(format: "%.2f", ride.cost!)
        timeLabel.text = ComponentsFormatter.string(from: ride.startTime, to: ride.endTime!)
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
