//
//  BikeInfoView.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 27/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable class BikeInfoView: UIView {

    var bike: BikeViewModel?

    @IBOutlet var scanButton: BSButton!
    @IBOutlet var routeButton: BSButton!
    
    @IBOutlet var addressLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "BikeInfoView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: [:]).first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        self.transform = CGAffineTransform.init(translationX: 0, y: -self.frame.height)
    }
    
    func show(for bike: BikeViewModel, mapkitManager: MapKitManager) {
        self.bike = bike
        
        mapkitManager.address(for: bike.location) { address in
            self.bike?.address = address
            self.addressLabel.text = address
        }

        
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
    }
    
}
