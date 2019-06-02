//
//  BikeMapViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import RxSwift
import RxCocoa
import MapKit

protocol BikeMapViewModel {
    var triggerText: BehaviorRelay<String> { get }
    var items: Observable<[BikeViewModel]> { get }
    var mapkitManager: MapKitManager { get }
    
    func rentBike(_ articleViewModel: BikeViewModel)
    func calculateRoute(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, completion: @escaping (MKRoute?)->Void)
}


class BaseBikeMapViewModel: BikeMapViewModel {
    var triggerText = BehaviorRelay<String>(value: "")
    
    var items: Observable<[BikeViewModel]>
    
    private let service: BikeMapService
    private let router: BikeMapRouter
    
    let disposeBag = DisposeBag()
    
    var mapkitManager: MapKitManager {
        return service.mapkitManager
    }
    
    public init(service: BikeMapService, router: BikeMapRouter) {
        self.service = service
        self.router = router
        
        items = triggerText.asObservable()
            //wait 0.3 s after the last value to fire a new value
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            //only fire if the value is different than the last one
            //.distinctUntilChanged()
            //convert Observable<String> to Observable<Weather>
            .flatMapLatest { searchString -> Observable<[BikeViewModel]> in
                return service.getAllBikes()
            }
            //make sure all subscribers use the same exact subscription
            .share(replay: 1)
        
        self.service.apiService.sessionManager.asObservable().subscribe(onNext: { value in
            self.triggerText.accept("")
        }, onError: {error in
            print(error)
        }, onCompleted: {
            print("kek")
        },onDisposed: {
            print("disposed")
        })
            .disposed(by: disposeBag)
    }
    
    func rentBike(_ bike: BikeViewModel) {
        router.scanQR(for: bike)
    }
    
    func calculateRoute(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, completion: @escaping (MKRoute?)->Void) {
        self.service.getRouteForBike(sourceLocation: sourceLocation, destinationLocation: destinationLocation, completion: completion)
    }
}
