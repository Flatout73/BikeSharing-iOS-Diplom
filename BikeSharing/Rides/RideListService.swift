//
//  RideListService.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 23/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import BikeSharingCore
import RxCocoa
import RxSwift
import RxAlamofire
import SwiftyUserDefaults
import CoreData

protocol RideListService {
    func getAllRides() -> Observable<[RideViewModel]>
}

class BaseRideListService: RideListService {
    let jsonDecoder = JSONDecoder()
    let coreDataManager: CoreDataManager
    
    let apiService: ApiService
    
    init(coreDataManager: CoreDataManager, apiService: ApiService) {
        self.coreDataManager = coreDataManager
        self.apiService = apiService
    }
    
    func getAllRides() -> Observable<[RideViewModel]> {
        return Observable.concat([getRidesFromCoreData(), getRidesFromServer()])
    }
    
    private func getRidesFromServer() -> Observable<[RideViewModel]> {
        
        let observable = apiService.sessionManager.value.rx.request(.get, ApiService.serverURL + "/api/rides", parameters: nil)
            .data()
            .flatMap { data -> Observable<[RideViewModel]> in
                guard let rides = try? self.jsonDecoder.decode([RideViewModel].self, from: data) else {
                    return Observable.error(BSError.parseError)
                }
                
                return Observable.just(rides)
        }
        
        
        
        return observable.do(onNext: { viewModels in
            self.coreDataManager.saveRide(viewModels: viewModels)
        }).catchErrorJustReturn(coreDataManager.fetchRides().map({ $0.viewModel }))
    }
    
    private func getRidesFromCoreData() -> Observable<[RideViewModel]> {
        let observable = Observable<[RideViewModel]>.create() { subscriber in
           
            let rides = self.coreDataManager.fetchRides()
            subscriber.onNext(rides.map({ $0.viewModel }))
            subscriber.onCompleted()
            
            return Disposables.create()
        }
        
        return observable
    }
    
}
