//
//  RideTableViewCell.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit

class RideTableViewCell: UITableViewCell {

    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var mapImageView: UIImageView!
    
    @IBOutlet var mainContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainContentView.layer.cornerRadius = 8
        mapImageView.layer.masksToBounds = true
    }
}
