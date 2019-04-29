//
//  RideInfoAssembly.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Swinject
import SwinjectStoryboard

class RideInfoAssembly: Assembly {
    func assemble(container: Container) {
        
//        container.register(RideListRouter.self) { (_: Resolver, viewController: UIViewController) in
//            return BaseRideListRouter(viewController: viewController)
//        }
//
//        container.register(RideListService.self) { _ in
//            return BaseRideListService()
//        }
//
//        container.register(RideListViewModel.self) { (resolver: Resolver, viewController: UIViewController) in
//            return BaseRideListViewModel(service: resolver.resolve(RideListService.self)!, router: resolver.resolve(RideListRouter.self, argument: viewController)!)
//        }
//
//        container.storyboardInitCompleted(RidesViewController.self) { resolver, controller in
//            controller.viewModel = resolver.resolve(RideListViewModel.self, argument: controller as UIViewController)
//        }
    }
}
