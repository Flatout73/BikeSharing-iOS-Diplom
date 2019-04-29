//
//  ApiService.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 24/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import Foundation
import GoogleSignIn
import FBSDKCoreKit
import RxSwift
import RxAlamofire

class ApiService {
    static let serverURL = "https://my-bike-sharing.herokuapp.com/"
    
    
    static func loginRequest(idToken: String?, completion: @escaping (Result<UserViewModel, BSError>) -> Void) {
        var urlRequest = URLRequest(url: URL(string: serverURL + "/tokensignin")!)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = idToken?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                let user = try! JSONDecoder().decode(UserViewModel.self, from: data)
                UserDefaults.standard.set(user.id, forKey: "userId")
                completion(.success(user))
            } else {
                completion(.failure(BSError.userError))
            }
            }.resume()
    }
}
