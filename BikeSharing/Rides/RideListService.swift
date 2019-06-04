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
    var apiService: ApiService { get }
    
    func getAllRides() -> Observable<[RideViewModel]>
}

class BaseRideListService: RideListService {
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
        
        let observable = apiService.sessionManager.rx.request(.get, ApiService.serverURL + "/rides/all", parameters: nil)
            .data()
            .flatMap { data -> Observable<[RideViewModel]> in
                guard let rides = try? self.apiService.jsonDecoder.decode([RideViewModel].self, from: data) else {
                    return Observable.error(BSError.parseError)
                }
                
                return Observable.just(rides.sorted(by: { $0.startTime > $1.startTime }))
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
