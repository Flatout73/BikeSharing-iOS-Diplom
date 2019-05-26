//
//  BikeMapRouter.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore
import RxSwift

protocol BikeMapRouter {
    func scanQR(for bike: BikeViewModel)
    func startRide(token: PaymentModel)
}

class BaseBikeMapRouter: Router, BikeMapRouter {
    
    let disposeBag = DisposeBag()
    
    func scanQR(for bike: BikeViewModel) {
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "ScannerViewController") as? ScannerViewController else { return }
        controller.bike = bike
        controller.paymentBike.asObservable().subscribe(onNext: { payment in
            self.startRide(token: payment)
        }, onError: { error in
            
        }).disposed(by: disposeBag)
        controller.startLocation = bike.location
        viewController?.present(controller, animated: true, completion: nil)
    }
    
    func startRide(token: PaymentModel) {
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "RidingViewController") as? RidingViewController else { return }
        controller.paymentInfo = token
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.barStyle = .blackTranslucent
        navigationController.navigationBar.tintColor = .white
        viewController?.present(navigationController, animated: false, completion: nil)
    }
}
