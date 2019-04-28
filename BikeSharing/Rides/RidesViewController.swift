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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.items.asObservable().bind(to: tableView.rx.items(cellIdentifier: "rideCell")) { row, ride, cell in
            guard let cell = cell as? RideTableViewCell else { return }
            
            cell.startLabel.text = String(ride.id)
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(RideViewModel.self).subscribe({ event in
            print("Select", event)
        }).disposed(by: disposeBag)
    }
}
