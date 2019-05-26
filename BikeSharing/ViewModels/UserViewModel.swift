//
//  UserViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

struct UserViewModel: Codable {
    typealias CoreDataType = User
    
    let id: Int64
    let email: String?
    let googleID: String?
    let facebookID: String?
    let pictureURL: String?
    let locale: String?
    let name: String?
}

extension UserViewModel: BSModelProtocol {
    func saveModel(for entity: User) {
        entity.serverID = id
        entity.email = email
        entity.googleID = googleID
        entity.facebookID = facebookID
        entity.name = name
        entity.avatarURL = pictureURL
    }
}
