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
    
    @IBOutlet weak var listEventsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoginButton()
        setupListEventsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkLogin() {
        if let accessToken = AccessToken.current {
            return loginSuccessful(token: accessToken)
        }
        
        AccessToken.refreshCurrentToken {
            token, error in
            if error == nil, let token = token {
                self.loginSuccessful(token: token)
            }
        }
        
    }
    func loginSuccessful(token: AccessToken) {
        let userID = token.userId
        
        print("Logged in! Id:" + (userID ?? ""))
        loginButton.isHidden = true
        listEventsView.isHidden = false
        listEventsButton.isHidden = false
    }
    
    func setupLoginButton() {
        loginButton.setTitle("Login to Facebook", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
    }
    
    func setupListEventsView() {
        listEventsView.isHidden = true
        listEventsButton.isHidden = true
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
            case .success(_, _, let token):
                print("Logged in! Token: \(token)")
            }
        }
    }

}

