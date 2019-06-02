//
//  TransactionViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 03/06/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

struct TransactionViewModel: Codable {
    let id: Int64?
    let token: String
    let cost: Double?
    let description: String?
    let currency: String?
}
