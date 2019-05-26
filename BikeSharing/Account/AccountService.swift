//
//  AccountService.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 26/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore

class AccountService {
    var coreDataManager: CoreDataManager?
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func getUser() -> UserViewModel? {
        guard let user: User = coreDataManager?.fetchEntity() else { return nil }
        return user.viewModel
    }
}
