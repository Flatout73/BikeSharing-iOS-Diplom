//
//  UserViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

struct UserViewModel: Codable {
    let id: Int64
    let email: String
    let googleId: String?
    let pictureURL: String?
    let locale: String?
}
