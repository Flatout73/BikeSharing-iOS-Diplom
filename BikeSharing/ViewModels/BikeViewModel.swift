//
//   BikeViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

struct BikeViewModel: Codable {
    let id: Int64
    let location: Point
    let name: String?
}

struct Point: Codable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "x"
        case longitude = "y"
    }
}
