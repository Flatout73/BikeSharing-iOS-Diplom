//
//  Router.swift
//  BikeSharingCore
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation

open class Router {
    public weak var viewController: UIViewController?
    
    required public init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
