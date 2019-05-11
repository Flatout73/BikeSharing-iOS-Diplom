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

protocol BikeMapService {
    var apiService: ApiService { get }
    func getAllBikes() -> Observable<[BikeViewModel]>
}

class BaseBikeMapService: BikeMapService {
    let jsonDecoder = JSONDecoder()
    
    let coreDataManager: CoreDataManager
    let apiService: ApiService
    
    init(coreDataManager: CoreDataManager, apiService: ApiService) {
        self.coreDataManager = coreDataManager
        self.apiService = apiService
    }
    
    func getAllBikes() -> Observable<[BikeViewModel]> {
        return Observable.concat([getBikesFromCoreData(), getBikesFromServer()])
    }
    
    private func getBikesFromServer() -> Observable<[BikeViewModel]> {
        let observable = self.apiService.sessionManager.value.rx.request(.get, ApiService.serverURL + "/api/bikes", parameters: nil)
            .data()
            .flatMap { data -> Observable<[BikeViewModel]> in
                guard let bikes = try? self.jsonDecoder.decode([BikeViewModel].self, from: data) else {
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
