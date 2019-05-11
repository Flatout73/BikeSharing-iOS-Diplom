//
//  RidesViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RidesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var viewModel: RideListViewModel! //injected
    private let disposeBag = DisposeBag()
    
    var refreshControler = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.items.asObservable().bind(to: tableView.rx.items(cellIdentifier: "rideCell")) { row, ride, cell in
            guard let cell = cell as? RideTableViewCell else { return }
            cell.selectionStyle = .none
            //cell.startLabel.text = ride.startLocation
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RideViewModel.self).bind(onNext: viewModel.showArticleInfo).disposed(by: disposeBag)
        
        self.tableView.refreshControl = refreshControler
        
        refreshControler.rx.controlEvent(.valueChanged)
            .map { _ in !self.refreshControler.isRefreshing }
            .filter { $0 == false }
            .subscribe({ [unowned self] _ in
                self.viewModel.triggerText.value = ""
            })
            .disposed(by: self.disposeBag)
        
        refreshControler.rx.controlEvent(.valueChanged)       // user pulled down to refresh
            .map { _ in self.refreshControler.isRefreshing }      // true -> true
            .filter { $0 == true }                // true == true
            .subscribe({ [unowned self] _ in
                self.refreshControler.endRefreshing()             // end refreshing
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsHelper.event(name: "show_rides")
    }
}
