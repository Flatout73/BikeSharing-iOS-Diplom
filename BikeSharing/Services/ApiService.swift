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
import SwiftyUserDefaults
import RxSwift
import RxCocoa

class ApiService {
    static let serverURLWithoutApi = "http://localhost:8443" //"https://my-bike-sharing.herokuapp.com"
    static let serverURL = serverURLWithoutApi + "/api"
    
    let sessionManager = BehaviorRelay<SessionManager>(value: Alamofire.SessionManager.default)
    
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    init() {
        setUserID()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func setUserID() {
        if let userID = Defaults[.token] {
            var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
            defaultHeaders["Authorization"] = "Bearer \(userID)" //String(userID)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = defaultHeaders
            sessionManager.accept(Alamofire.SessionManager(configuration: configuration))
        }
    }
    
    func loginRequest(idToken: String, isGoogle: Bool = true, completion: @escaping (Swift.Result<String, BSError>) -> Void) {
        var urlRequest = URLRequest(url: URL(string: ApiService.serverURLWithoutApi + "/tokensignin" + (isGoogle ? "/true" : "/false"))!)
       // urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = idToken.data(using: .utf8)
        
        
        sessionManager.value.request(urlRequest).validate(validate).responseData { response in
            guard let data = response.data, let jwttoken = String(data: data, encoding: .utf8) else {
                completion(.failure(BSError.userError))
                return
            }
        
//            guard let user = try? self.jsonDecoder.decode(UserViewModel.self, from: data) else {
//                completion(.failure(.parseError))
//                return
//            }
            Defaults[.token] = jwttoken
            Defaults.synchronize()
            self.setUserID()
            completion(.success(jwttoken))
        }
    }
    
    func payRequest(token: STPToken, ride: RideViewModel, completion: @escaping (Swift.Result<TransactionViewModel, Error>)->()) {
        
        let transaction = TransactionViewModel(id: nil, token: token.tokenId, cost: ride.cost ?? 50.0, description: "Поездка", currency: "RUB")
        
        var request = URLRequest(url: URL(string: ApiService.serverURL + "/pay/" + String(ride.id!))!)
        request.httpMethod = "POST"
        request.httpBody = try! jsonEncoder.encode(transaction)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        sessionManager.value.request(request).validate(validate).responseData { response in
            guard let data = response.data else {
                completion(.failure(response.error ?? BSError.parseError))
                return
            }
            
            guard let transaction = try? self.jsonDecoder.decode(TransactionViewModel.self, from: data) else {
                completion(.failure(BSError.parseError))
                return
            }
            
            completion(.success(transaction))
        }
    }
    
    private func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let message = json["message"] as? String else {
                return .success
        }
        
        return .failure(BSError.paymentError(message))
    }
    
    func getBike(by id: Int64, completion: @escaping (Swift.Result<BikeViewModel, Error>)->()) {
        sessionManager.value.request(ApiService.serverURL + "/bikes", method: .get, parameters: ["id": id]).validate().response { response in
            guard let rideData = response.data else {
                completion(.failure(response.error ?? BSError.unknownError))
                return
            }
            
            do {
                let bike = try self.jsonDecoder.decode(BikeViewModel.self, from: rideData)
                completion(.success(bike))
            } catch {
                completion(.failure(BSError.parseError))
            }
        }
    }
    
    func createRide(_ ride: RideViewModel, completion: @escaping (Swift.Result<RideViewModel, Error>)->()) {
        var request = URLRequest(url: URL(string: ApiService.serverURL + "/rides/start")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! jsonEncoder.encode(ride)

        sessionManager.value.request(request).validate(validate).response { response in
            guard let rideData = response.data else {
                completion(.failure(response.error ?? BSError.unknownError))
                return
            }
            
            do {
                let ride = try self.jsonDecoder.decode(RideViewModel.self, from: rideData)
                completion(.success(ride))
            } catch {
                completion(.failure(BSError.parseError))
            }
        }
    }
    
    func endRide(_ ride: RideViewModel, with image: UIImage, completion: @escaping (Swift.Result<RideViewModel, Error>)->()) {
//        var request = URLRequest(url: URL(string: ApiService.serverURL + "/api/rides/end")!)
//        request.httpMethod = HTTPMethod.put.rawValue
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try! jsonEncoder.encode(ride)
        
        let headers = [
            "Content-type": "multipart/form-data",
            "Content-Disposition" : "form-data"
        ]
        
        sessionManager.value.upload(multipartFormData: { formData in
            formData.append(try! self.jsonEncoder.encode(ride), withName: "ride")
            formData.append(image.pngData()!, withName: "file", fileName: "file.png", mimeType: "image/png")
            
        }, usingThreshold: UInt64.init(),
           to: ApiService.serverURL + "/rides/end",
           method: .put,
           headers: headers,
           encodingCompletion: { response in
            print(response)
            switch response {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("the resopnse code is : \(response.response?.statusCode)")
                    print("the response is : \(response)")
                    
                    guard let data = response.data else { return }
                    do {
                        let ride = try self.jsonDecoder.decode(RideViewModel.self, from: data)
                        completion(.success(ride))
                    } catch {
                        completion(.failure(BSError.parseError))
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)

            }
//            if let error = response.error {
//                completion(.failure(error))
//                return
//            }
//            guard let rideData = response.data else {
//                completion(.failure(response.error ?? BSError.unknownError))
//                return
//            }
//
//            do {
//                let ride = try self.jsonDecoder.decode(RideViewModel.self, from: rideData)
//                completion(.success(ride))
//            } catch {
//                completion(.failure(BSError.parseError))
//            }
        })
//        sessionManager.value.request(request).validate(validate).response { response in
//            if let error = response.error {
//                completion(.failure(error))
//                return
//            }
//            guard let rideData = response.data else {
//                completion(.failure(response.error ?? BSError.unknownError))
//                return
//            }
//
//            do {
//                let ride = try self.jsonDecoder.decode(RideViewModel.self, from: rideData)
//                completion(.success(ride))
//            } catch {
//                completion(.failure(BSError.parseError))
//            }
//        }
        
    }
    
    func sendFeedback(_ feedback: FeedBackViewModel, completion: @escaping (Swift.Result<FeedBackViewModel, Error>)->Void) {
        var request = URLRequest(url: URL(string: ApiService.serverURL + "/rides/start")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! jsonEncoder.encode(feedback)
        
        sessionManager.value.request(request).validate(validate).response { response in
            guard let data = response.data else {
                completion(.failure(response.error ?? BSError.unknownError))
                return
            }
            
            do {
                let feedback = try self.jsonDecoder.decode(FeedBackViewModel.self, from: data)
                completion(.success(feedback))
            } catch {
                completion(.failure(BSError.parseError))
            }
        }
    }
}
