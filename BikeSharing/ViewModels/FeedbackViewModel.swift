//
//  FeedbackViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 27/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

struct FeedBackViewModel: Codable {
    let text: String
    let address: String?
    
    let bike: BikeViewModel?
}
