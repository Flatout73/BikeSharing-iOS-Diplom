//
//  BSError.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

enum BSError: Error {
    case userError
    case parseError
    
    case paymentError(String)
}
