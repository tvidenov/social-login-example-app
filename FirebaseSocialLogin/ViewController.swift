//
//  ViewController.swift
//  FirebaseSocialLogin
//
//  Created by Tihomir Videnov on 11/6/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFacebookButtons()
        setupGoogleButtons()
        setupTwitterButtons()
        
    }
    
    fileprivate func setupTwitterButtons() {
        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print("Twitter login has failed with error:\(err)")
                return
            }
            
            //print("Successfully logged in via Twitter")
            
            guard let token  = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if let err = error {
                    return
                }
                
                print("Successfully created a Twitter account in Firebase: \(user?.uid ?? "")")
                
            })
            
        }
    
        view.addSubview(twitterButton)
        twitterButton.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
        
        
    }
    
    fileprivate func setupGoogleButtons() {
        
        //add googleSignIn button
        
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        
        view.addSubview(googleButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let customButton: UIButton = {
           let button = UIButton(type: .system)
            button.frame = CGRect(x: 16, y: 116 + 66 + 66, width: view.frame.width - 32, height: 50)
            button.backgroundColor = .orange
            button.setTitle("Custom Google Sign In", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            return button
        }()
        
        view.addSubview(customButton)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSignIn), for: .touchUpInside)
    }
    
     func handleCustomGoogleSignIn() {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    fileprivate func setupFacebookButtons() {
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["email", "public_profile"]
        
        view.addSubview(loginButton)
        
        //frames are obsolete
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        
        
        //custom FB login button
        let customFBButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Custom FB Button", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.backgroundColor = .blue
            button.setTitleColor(.white, for: .normal)
            button.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
            return button
        }()
        
        view.addSubview(customFBButton)
        
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    func handleCustomFBLogin() {
        print(123)
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
         
            if err != nil {
                print("FB login failed: \(err)")
                return
            }
                self.showEmailAddress()
            
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        showEmailAddress()
    }
    
    
    func showEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something is wrong with FB user: \(error)")
            }
            
            print("successfully logged in with our user: \(user)")
            
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, id, name"]).start { (connection, result, err) in
            
            if err != nil {
                print("failed to login: \(err)")
                return
            }
            
            print(result ?? "")
        }
    }
    
    
}

