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
import FacebookCore
import FacebookLogin
import MBProgressHUD

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet var googleLoginButton: GIDSignInButton!
    @IBOutlet var fbLoginButton: FBLoginButton!
    
    
    
    var apiService: ApiService!
    
    var coreDataManager: CoreDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleLoginButton.style = .wide
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        fbLoginButton.permissions = [Permission.publicProfile.name, Permission.email.name]
        fbLoginButton.delegate = self
//        if AccessToken.isCurrentAccessTokenActive {
//           // token.userID
//        }
    }
    
    func presentTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
        vc.transitioningDelegate = self
     
        self.present(vc, animated: true, completion: nil)
    }

}

extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let email = user.profile.email
            let imageURL = user.profile.imageURL(withDimension: 400)
            
            MBProgressHUD.showAdded(to: self.view, animated: true)
            apiService.loginRequest(idToken: idToken!) { result in
                MBProgressHUD.hide(for: self.view, animated: true)
                switch result {
                case .success(_):
                    let user = UserViewModel(id: 1, email: email, googleID: userId, facebookID: nil, pictureURL: imageURL?.path, locale: nil, name: fullName)
                    self.coreDataManager?.saveModel(viewModel: user)
                    self.presentTabBar()
                case .failure(let error):
                    NotificationBanner.showErrorBanner(error.localizedDescription)
                }
                
            }
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        guard let token = result.token else {
            NotificationBanner.showErrorBanner("Ошибка входа")
            return
        }
        
 
        MBProgressHUD.showAdded(to: self.view, animated: true)
        apiService.loginRequest(idToken: token.tokenString, isGoogle: false) { result in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch result {
            case .success(let user):
                print(user)
                self.presentTabBar()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {

    }
    
    
}

extension LoginViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FlipPresentAnimationController()
    }
}
