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

class ApiService {
    static let serverURL = "http://localhost:8443" //"https://my-bike-sharing.herokuapp.com"
    
    var sessionManager = Variable<SessionManager>(Alamofire.SessionManager.default)
    
    let jsonEncoder = JSONEncoder()
    let jsonDecoder = JSONDecoder()
    
    init() {
        setUserID()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func setUserID() {
        if let userID = Defaults[.userId] {
            var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
            defaultHeaders["BS-User"] = String(userID)
            
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = defaultHeaders
            sessionManager.value = Alamofire.SessionManager(configuration: configuration)
        }
    }
    
    func loginRequest(idToken: String?, completion: @escaping (Swift.Result<UserViewModel, BSError>) -> Void) {
        var urlRequest = URLRequest(url: URL(string: ApiService.serverURL + "/tokensignin")!)
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = idToken?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                let user = try! JSONDecoder().decode(UserViewModel.self, from: data)
                UserDefaults.standard.set(user.id, forKey: "userId")
                UserDefaults.standard.synchronize()
                self.setUserID()
                completion(.success(user))
            } else {
                completion(.failure(BSError.userError))
            }
            }.resume()
    }
    
    func payRequest(token: STPToken, amount: Double, completion: @escaping (Error?)->()) {
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
        
        sessionManager.value.request(ApiService.serverURL + "/pay", method: .post, parameters: body, encoding: JSONEncoding.default, headers: headers).validate(validate).response(completionHandler: { response in
            print(String(data: response.data!, encoding: .utf8))
            completion(response.error)
        })
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
        sessionManager.value.request(ApiService.serverURL + "/api/bikes", method: .get, parameters: ["id": id]).validate().response { response in
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
        var request = URLRequest(url: URL(string: ApiService.serverURL + "/api/rides/start")!)
        request.httpMethod = HTTPMethod.post.rawValue
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
           to: ApiService.serverURL + "/api/rides/end",
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
}
