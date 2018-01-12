//
//  ViewController.swift
//  Evento
//
//  Created by Aleksey Bykhun on 10.01.2018.
//  Copyright © 2018 Aleksey Bykhun. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var listEventsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoginButton()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkLogin()
    
        
        
        let token = AccessToken.init(authenticationToken: "EAACEdEose0cBALHlPgGGxH1LQvrXAxU8RBXznc6bTcZBH9wO7Pmn4Lu5usbMeIUIOQ5VarhBlyeJa8F2cN4bZBIZAcf2JfXfK2gR3sOobUPw9UYlvIAsmh9JOUEgLiz9FPpDtSpOGeV7GaWOTOlev00H5fMAwp86phkU7W1cZBh6h8tCm587W6iqc4Kliz4ZCRvSeoXgiqQZDZD")
        
//        AccessToken.current = token
        AccessToken.refreshCurrentToken { (token, error) in
            if let accessToken = token {
                let userID = accessToken.userId
                
                print("Logged in! Id:" + (userID ?? ""))
                self.loginButton.isHidden = true
            } else {
                print("Not logged in.")
                self.loginButton.isHidden = false
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkLogin() {
        if let accessToken = AccessToken.current {
            let userID = accessToken.userId
            
            print("Logged in! Id:" + (userID ?? ""))
            self.loginButton.isHidden = true
        } else {
            print("Not logged in.")
            self.loginButton.isHidden = false
        }
    }
    func setupLoginButton() {
        loginButton.setTitle("Login to Facebook", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ .publicProfile, .userFriends, .userEvents ],
                           viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
            }
        }
    }

}

