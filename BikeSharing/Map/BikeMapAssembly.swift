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
//        container.register(BikeMapRouter.self) { (_: Resolver, viewController: UIViewController) in
//            return BaseBikeMapRouter(viewController: viewController)
//        }
//        
//        container.register(BikeMapService.self) { _ in
//            return BaseBikeMapService()
//        }
//        
//        container.register(BikeMapViewModel.self) { (resolver: Resolver, viewController: UIViewController) in
//            return BikeMapViewModel(service: resolver.resolve(BikeMapService.self)!, router: resolver.resolve(BikeMapRouter.self, argument: viewController)!)
//        }
//        
//        container.storyboardInitCompleted(RidesViewController.self) { resolver, controller in
//            controller.viewModel = resolver.resolve(RideListViewModel.self, argument: controller as UIViewController)
//        }
    }
}
