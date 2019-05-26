//
//  User+Extension.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 26/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

extension User {
    
    var viewModel: UserViewModel {
        return UserViewModel(id: serverID, email: email, googleID: googleID, facebookID: facebookID, pictureURL: avatarURL, locale: locale, name: name)
    }
    
}
