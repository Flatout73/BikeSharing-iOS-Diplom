//
//  ViewController.swift
//  BikeSharing
//
//  Created by Леонид Лядвейкин on 14/04/2019.
//  Copyright © 2019 Леонид Лядвейкин. All rights reserved.
//

import GoogleSignIn
import BikeSharingCore
import FBSDKLoginKit

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet var googleLoginButton: GIDSignInButton!
    @IBOutlet var fbLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleLoginButton.style = .wide
        GIDSignIn.sharedInstance().uiDelegate = self
        
        fbLoginButton.readPermissions = ["public_profile", "email"]
        if FBSDKAccessToken.currentAccessTokenIsActive() {
            
        }
    }


}

