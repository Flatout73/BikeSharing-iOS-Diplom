//
//  RideListViewModel.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import RxSwift
import RxCocoa

protocol RideListViewModel {
    
    var items: Observable<[RideViewModel]> { get }
    //var loadItems: Action<Void, [ArticleCellViewModel], AnyError> { get }
    func showRideInfo(_ articleViewModel: RideViewModel)
    var triggerText: Variable<String> { get set }
}

class BaseRideListViewModel: RideListViewModel {
    var items: Observable<[RideViewModel]>
    
    
    private let service: RideListService
    private let router: RideListRouter
    
   // private(set) lazy var loadItems: Action<Void, [ArticleCellViewModel], AnyError> = self.setupLoadItemsAction()
  //  private(set) lazy var items: Property<[ArticleCellViewModel]> = self.setupItems()
    
    var triggerText = Variable<String>("")
    
    
    init(service: RideListService, router: RideListRouter) {
        self.service = service
        self.router = router
        
        items = triggerText.asObservable()
            //wait 0.3 s after the last value to fire a new value
            .debounce(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            //only fire if the value is different than the last one
            //.distinctUntilChanged()
            //convert Observable<String> to Observable<Weather>
            .flatMapLatest { searchString -> Observable<[RideViewModel]> in
                return service.getAllRides()
            }
            //make sure all subscribers use the same exact subscription
            .share(replay: 1)
        
    }
    
    func showRideInfo(_ rideViewModel: RideViewModel) {
        router.showRideInfo(with: rideViewModel)
    }
    
    // MARK: setup
    
//    private func setupLoadItemsAction() -> Action<Void, [ArticleCellViewModel], AnyError> {
//        return Action { [weak self] in
//            guard let strongSelf = self else {
//                return SignalProducer.empty
//            }
//            return strongSelf.service.getAllArticles().map { articles in
//                articles.map { article in
//                    ArticleCellViewModel(article: article)
//                }
//            }
//        }
//    }
//    
//    private func setupItems() -> Property<[ArticleCellViewModel]> {
//        return Property(initial: [], then: loadItems.values)
//    }
}
