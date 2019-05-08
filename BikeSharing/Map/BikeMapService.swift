//
//  BikeMapService.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import RxSwift
import RxAlamofire

protocol BikeMapService {
    func getAllBikes() -> Observable<[BikeViewModel]>
}

class BaseBikeMapService: BikeMapService {
    let jsonDecoder = JSONDecoder()
    
    func getAllBikes() -> Observable<[BikeViewModel]> {
        return Observable.concat([getBikesFromCoreData(), getBikesFromServer()])
    }
    
    private func getBikesFromServer() -> Observable<[BikeViewModel]> {
        let observable = request(.get, ApiService.serverURL + "/api/bike", parameters: nil)
            .data()
            .flatMap { data -> Observable<[BikeViewModel]> in
                guard let bikes = try? self.jsonDecoder.decode([BikeViewModel].self, from: data) else {
                    return Observable.error(BSError.parseError)
                }
                
                return Observable.just(bikes)
        }
        
        
        
        return observable.do(onNext: { viewModels in
            CoreDataManager.shared.saveBike(viewModels: viewModels)
        }).catchErrorJustReturn(CoreDataManager.shared.fetchBikes().map({ BikeViewModel(id: $0.serverID, location: Point(latitude: $0.latitude, longitude: $0.longitude)) }))
    }
    
    private func getBikesFromCoreData() -> Observable<[BikeViewModel]> {
        let observable = Observable<[BikeViewModel]>.create() { subscriber in
            
            let bikes = CoreDataManager.shared.fetchBikes()
            subscriber.onNext(bikes.map({ BikeViewModel(id: $0.serverID, location: Point(latitude: $0.latitude, longitude: $0.longitude)) }))
            subscriber.onCompleted()
            
            return Disposables.create()
        }
        
        return observable
    }
}
