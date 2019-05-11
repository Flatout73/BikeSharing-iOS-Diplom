//
//  RideViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

struct RideViewModel: Codable {
    let id: Int64?

    let startLocation: Point
    var endLocation: Point?
    
    let startTime: Date
    var endTime: Date?
    
    var cost: Double?
    
    var bike: BikeViewModel?
}
