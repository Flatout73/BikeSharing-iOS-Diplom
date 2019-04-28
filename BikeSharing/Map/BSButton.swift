//
//  BSButton.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit

@IBDesignable class BSButton: UIButton {
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commomInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commomInit()
    }
    
    func commomInit() {
        self.backgroundColor = #colorLiteral(red: 1, green: 0.8000000119, blue: 0.3000000119, alpha: 1)
        self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        self.layer.cornerRadius = 8
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
