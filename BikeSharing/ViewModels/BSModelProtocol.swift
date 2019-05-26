//
//  ModelProtocol.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 26/05/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import CoreData

protocol BSModelProtocol {
    associatedtype CoreDataType: NSManagedObject
    
    var id: Int64 { get }
    
    func saveModel(for entity: CoreDataType)
}
