//
//  ScannerViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 28/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import UIKit
import AVFoundation
import PassKit
import Alamofire
import RxSwift

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let notification = UINotificationFeedbackGenerator()
    
    let SupportedPaymentNetworks: [PKPaymentNetwork] = [.visa, .masterCard]
    let merchantID = "merchant.ru.hse.Bike-Sharing"
    
    let paymentToken = PublishSubject<STPToken>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.startRunning()
    }
    
    func failed() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.createPayment()
            })
            self.present(ac, animated: true)
        }

        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            notification.notificationOccurred(.success)
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        print(code)
        createPayment()
    }
    
    func createPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "RU"
        request.currencyCode = "RUB"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Поездка", amount: 1, type: .pending)
        ]
        guard let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
        applePayController.delegate = self
        self.present(applePayController, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScannerViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        Stripe.setDefaultPublishableKey("pk_test_Kpmk0CInfxC2gC7IVaHse5gE00T1XkGUPN")
        STPAPIClient.shared().createToken(with: payment) { (token, error) -> Void in

            guard let token = token else {
                if let error = error {
                    print(error)
                    self.paymentToken.onError(error)
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                }
                return
            }
            
            self.paymentToken.onNext(token)

//            let headers: HTTPHeaders = [
//                "Content-Type" : "application/json",
//                "Accept": "application/json"
//            ]
//
//            let body: [String : Any] = ["token": token.tokenId,
//                        "amount": 1,
//                        "description": "Поездка",
//                ]


//            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
//                if (error != nil) {
//                    completion(PKPaymentAuthorizationStatus.Failure)
//                } else {
//                    completion(PKPaymentAuthorizationStatus.Success)
//                }
//            }
//
//            Alamofire.request(ApiService.serverURL + "/pay", method: .post, parameters: body, headers: headers).response(completionHandler: { data in
//                print(data)
//            })
        }

        
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: {
            self.dismiss(animated: true)
        })
    }
}
