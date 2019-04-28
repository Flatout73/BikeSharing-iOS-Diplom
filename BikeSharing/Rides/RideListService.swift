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
    
    func getAllRides() -> Observable<[RideViewModel]> {
        
        return Observable.merge([getRidesFromCoreData(), getRidesFromServer()])
    }
    
    private func getRidesFromServer() -> Observable<[RideViewModel]> {
        
        let observable = request(.get, ApiService.serverURL + "/api/rides/\(Defaults[.userId]!)", parameters: nil)
            .data()
            .flatMap { data -> Observable<[RideViewModel]> in
                guard let rides = try? self.jsonDecoder.decode([RideViewModel].self, from: data) else {
                    return Observable.error(BSError.parseError)
                }
                
                return Observable.just(rides)
        }
        
        
        
        return observable.do(onNext: { viewModels in
            CoreDataManager.shared.saveRide(viewModels: viewModels)
        }).catchErrorJustReturn(CoreDataManager.shared.fetchRides().map({ RideViewModel(id: $0.serverId) }))
    }
    
    private func getRidesFromCoreData() -> Observable<[RideViewModel]> {
        let observable = Observable<[RideViewModel]>.create() { subscriber in
           
            let rides = CoreDataManager.shared.fetchRides()
            subscriber.onNext(rides.map({ RideViewModel(id: $0.serverId) }))
            subscriber.onCompleted()
            
            return Disposables.create()
        }
        
        return observable
    }
    
}
