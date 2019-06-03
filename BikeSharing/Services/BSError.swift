//
//  BSError.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

enum BSError: LocalizedError {
    case userError
    case parseError
    case unknownError
    
    case paymentError(String)
    
    var errorDescription: String? {
        switch self {
        case .userError:
            return "Ошибка пользователя"
        case .unknownError:
            return "Неизвестная ошибка"
        case .parseError:
            return "Ошибка парсинга"
        case .paymentError(let message):
            return message
        }
    }
}
