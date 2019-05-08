//
//  NotificationBanner.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 08/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import NotificationBannerSwift


class NotificationBanner {
    static let errorBanner = StatusBarNotificationBanner(title: "Ошибка", style: .danger)
    static let successBanner = StatusBarNotificationBanner(title: "Успех", style: .success)
    
    static func showErrorBanner(_ error: String) {
        errorBanner.titleLabel?.text = error
        errorBanner.show()
    }
    
    static func showSuccessBanner(_ title: String) {
        successBanner.titleLabel?.text = title
        successBanner.show()
    }
}
