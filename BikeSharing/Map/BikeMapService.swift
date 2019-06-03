//
//  BikeMapService.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import RxSwift
import RxAlamofire
import Alamofire
import MapKit

protocol BikeMapService {
    var apiService: ApiService { get }
    var mapkitManager: MapKitManager { get }
    
    func getAllBikes() -> Observable<[BikeViewModel]>
    func getRouteForBike(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, completion: @escaping (MKRoute?)->Void)
}

class BaseBikeMapService: BikeMapService {
    let coreDataManager: CoreDataManager
    let apiService: ApiService
    let mapkitManager: MapKitManager
    
    init(coreDataManager: CoreDataManager, mapkitManager: MapKitManager, apiService: ApiService) {
        self.coreDataManager = coreDataManager
        self.mapkitManager = mapkitManager
        self.apiService = apiService
    }
    
    func getRouteForBike(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, completion: @escaping (MKRoute?)->Void) {
        mapkitManager.calculateRoute(sourceLocation: sourceLocation, destinationLocation: destinationLocation, completion: completion)
    }
    
    func getAllBikes() -> Observable<[BikeViewModel]> {
        return Observable.concat([getBikesFromCoreData(), getBikesFromServer()])
    }
    
    private func getBikesFromServer() -> Observable<[BikeViewModel]> {
        let observable = self.apiService.sessionManager.value.rx.request(.get, ApiService.serverURL + "/bikes/all", parameters: nil)
            .data()
            .flatMap { data -> Observable<[BikeViewModel]> in
                guard let bikes = try? self.apiService.jsonDecoder.decode([BikeViewModel].self, from: data) else {
                    return Observable.error(BSError.parseError)
                }
                
                return Observable.just(bikes)
            }
        
        return observable.do(onNext: { viewModels in
            self.coreDataManager.saveBike(viewModels: viewModels)
        }).catchErrorJustReturn(self.coreDataManager.fetchBikes().map({ $0.viewModel }))
    }
    
    private func getBikesFromCoreData() -> Observable<[BikeViewModel]> {
        let observable = Observable<[BikeViewModel]>.create() { subscriber in
            
            let bikes = self.coreDataManager.fetchBikes()
            subscriber.onNext(bikes.map({ $0.viewModel }))
            subscriber.onCompleted()
            
            return Disposables.create()
        }
        
        return observable
    }
}
