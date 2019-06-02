//
//  BikeMapAssembly.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Swinject
import SwinjectStoryboard

class BikeMapAssembly: Assembly {
    func assemble(container: Container) {
        container.register(BikeMapRouter.self) { (_: Resolver, viewController: UIViewController) in
            return BaseBikeMapRouter(viewController: viewController)
        }
        
        container.register(BikeMapService.self) { resolver in
            return BaseBikeMapService(coreDataManager: resolver.resolve(CoreDataManager.self)!, mapkitManager: resolver.resolve(MapKitManager.self)!, apiService: resolver.resolve(ApiService.self)!)
        }
        
        container.register(BikeMapViewModel.self) { (resolver: Resolver, viewController: UIViewController) in
            return BaseBikeMapViewModel(service: resolver.resolve(BikeMapService.self)!, router: resolver.resolve(BikeMapRouter.self, argument: viewController)!)
        }
        
        container.storyboardInitCompleted(MapViewController.self) { resolver, controller in
            controller.viewModel = resolver.resolve(BikeMapViewModel.self, argument: controller as UIViewController)
        }
    }
}
