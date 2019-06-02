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

struct PaymentModel {
    let token: STPToken
    let ride: RideViewModel
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let notification = UINotificationFeedbackGenerator()
    
    let SupportedPaymentNetworks: [PKPaymentNetwork] = [.visa, .masterCard]
    let merchantID = "merchant.ru.hse.Bike-Sharing"
    
    let paymentBike = PublishSubject<PaymentModel>()
    
    var apiService: ApiService!
    var coreDataManager: CoreDataManager!
    var mapkitManager: MapKitManager!
    var bluetoothManager: BluetoothManager!
    
    var startLocation: Point!
    
    var token: STPToken?
    var bike: BikeViewModel!
    
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
        
         bluetoothManager.scan()
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
    
    @IBAction func help(_ sender: Any) {
        let alert = UIAlertController(title: "Помощь", message: "Чтобы разблокировать велосипед, найдите на нем QR-код и просканируйте", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        guard
            let id = Int64(code)
//            let jsonData = code.data(using: .utf8),
//            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//            let id = json["id"] as? Int64
            else {
                createPayment() //заменить
                return
            }
        
        apiService.getBike(by: id) { result in
            switch result {
            case .success(let bike):
                self.bike = bike
                self.mapkitManager.address(for: self.bike.location) { address in
                    self.bike.address = address
                    self.createPayment()
                }
            case .failure(let error):
                NotificationBanner.showErrorBanner(error.localizedDescription)
            }
        }
        
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
                    self.paymentBike.onError(error)
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                }
                return
            }
            
            self.token = token
            
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        guard let paymentToken = self.token else {
            self.dismiss(animated: true)
            return
        }
        apiService.createRide(RideViewModel(id: nil, startLocation: startLocation, endLocation: nil, startAddress: bike.address, endAddress: nil, startTime: Date(), endTime: nil, cost: nil, bike: bike, locations: nil, imageURL: nil)) { result in
            switch result {
            case .success(let ride):
                self.coreDataManager.saveOneRide(by: ride)
                controller.dismiss(animated: true, completion: {
                    self.dismiss(animated: true) {
                        self.paymentBike.onNext(PaymentModel(token: paymentToken, ride: ride))
                    
                        if self.bluetoothManager.isReady {
                            self.bluetoothManager.sendMessageToDevice("OPENLOCK")
                        } else {
                            NotificationBanner.showErrorBanner("Нет подключения к замку")
                        }
                    }
                })
            case .failure(let error):
                NotificationBanner.showErrorBanner(error.localizedDescription)
            }
           
        }
    }
}
