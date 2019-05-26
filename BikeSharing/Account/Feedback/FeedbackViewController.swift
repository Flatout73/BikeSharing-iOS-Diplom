//
//  FeedbackViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 27/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {
    
    @IBOutlet var feedbackTextView: UITextView!
    @IBOutlet var bikeNumberField: UITextField!
    @IBOutlet var placeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedbackTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.feedbackTextView.layer.borderWidth = 1
        self.feedbackTextView.layer.cornerRadius = 8
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        
    }
}
