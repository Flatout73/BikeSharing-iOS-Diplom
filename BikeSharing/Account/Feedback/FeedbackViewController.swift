//
//  FeedbackViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 27/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import MBProgressHUD

class FeedbackViewController: UIViewController {
    
    @IBOutlet var feedbackTextView: UITextView!
    @IBOutlet var bikeNumberField: UITextField!
    @IBOutlet var placeField: UITextField!
    
    var apiService: ApiService!
    var coreDataManager: CoreDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedbackTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.feedbackTextView.layer.borderWidth = 1
        self.feedbackTextView.layer.cornerRadius = 8
    }
    
    @IBAction func sendFeedback(_ sender: Any) {
        guard let text = feedbackTextView.text else {
            NotificationBanner.showErrorBanner("Напишите фидбек")
            return
        }
        
        let feedback = FeedBackViewModel(text: text, address: placeField.text ?? "", bike: nil)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        apiService.sendFeedback(feedback) { result in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch (result) {
            case .success(let feedback):
                NotificationBanner.showSuccessBanner("Отзыв отправлен")
            case .failure(let error):
                NotificationBanner.showErrorBanner("Ошибка: \(error.localizedDescription)")
            }
        }
    }
}
