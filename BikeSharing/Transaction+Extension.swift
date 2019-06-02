//
//  Transaction+CoreDataClass.swift
//  
//
//  Created by Леонид Лядвейкин on 03/06/2019.
//
//

import BikeSharingCore

extension Transaction {
    var viewModel: TransactionViewModel {
        return TransactionViewModel(id: self.serverID, token: self.token!, cost: self.cost, description: self.description, currency: self.currency)
    }
}
