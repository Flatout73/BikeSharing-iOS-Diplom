//
//  BikeMapViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import RxSwift

protocol BikeMapViewModel {
    
    var items: Observable<[BikeViewModel]> { get }
    func rentBike(_ articleViewModel: BikeViewModel)
    var triggerText: Variable<String> { get set }
}


class BaseBikeMapViewModel: BikeMapViewModel {
    var triggerText = Variable<String>("")
    
    var items: Observable<[BikeViewModel]>
    
    private let service: BikeMapService
    private let router: BikeMapRouter
    
    public init(service: BikeMapService, router: BikeMapRouter) {
        self.service = service
        self.router = router
        
        items = triggerText.asObservable()
            //wait 0.3 s after the last value to fire a new value
            .debounce(0.3, scheduler: MainScheduler.instance)
            //only fire if the value is different than the last one
            .distinctUntilChanged()
            //convert Observable<String> to Observable<Weather>
            .flatMapLatest { searchString -> Observable<[BikeViewModel]> in
                return service.getAllBikes()
            }
            //make sure all subscribers use the same exact subscription
            .share(replay: 1)
        
        service.apiService.sessionManager.asObservable().subscribe(onNext: { value in
            self.triggerText.value = ""
        })
    }
    
    func rentBike(_ bike: BikeViewModel) {
        router.scanQR(for: bike)
    }
}
