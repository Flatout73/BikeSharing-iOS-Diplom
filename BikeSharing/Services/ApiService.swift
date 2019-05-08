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
import Alamofire

class ApiService {
    static let serverURL = "http://localhost:8443/" //"https://my-bike-sharing.herokuapp.com/"
    
    static func loginRequest(idToken: String?, completion: @escaping (Swift.Result<UserViewModel, BSError>) -> Void) {
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
    
    static func payRequest(token: STPToken, amount: Double, completion: @escaping (Error?)->()) {
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept": "application/json"
        ]
        
        let body: [String : Any] = ["token": token.tokenId,
                                    "cost": amount,
                                    "description": "Поездка",
                                    "currency": "RUB"
        ]
        
//
//        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
//            if (error != nil) {
//                completion(PKPaymentAuthorizationStatus.Failure)
//            } else {
//                completion(PKPaymentAuthorizationStatus.Success)
//            }
//        }
        
        Alamofire.request(serverURL + "/pay", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).validate({ (request, response, data) -> Request.ValidationResult in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let message = json["message"] as? String else {
                return .success
            }
            
            return .failure(BSError.paymentError(message))
        }).response(completionHandler: { response in
            print(String(data: response.data!, encoding: .utf8))
            completion(response.error)
        })
    }
}
