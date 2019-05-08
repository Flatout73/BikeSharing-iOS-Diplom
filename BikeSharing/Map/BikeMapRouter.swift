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
    func scanQR()
    func startRide(token: STPToken)
}

class BaseBikeMapRouter: Router, BikeMapRouter {
    
    let disposeBag = DisposeBag()
    
    func scanQR() {
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "ScannerViewController") as? ScannerViewController else { return }
        controller.paymentToken.asObservable().subscribe(onNext: { token in
            
        }, onError: { error in
            
        }).disposed(by: disposeBag)
        viewController?.present(controller, animated: true, completion: nil)
    }
    
    func startRide(token: STPToken) {
        guard let controller = viewController?.storyboard?.instantiateViewController(withIdentifier: "RidingViewController") as? RidingViewController else { return }
        controller.token = token
        viewController?.present(controller, animated: true, completion: nil)
    }
}
