//
//  ViewController.swift
//  AlamofireExample
//
//  Created by Bhavesh Chavda on 22/01/20.
//  Copyright © 2020 BhaveshChavda. All rights reserved.
//


import UIKit
import Toast_Swift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        doLogin()
    }
    
    
    func doLogin(){
        APIManager.shared.doLoginWith(email: "yourlogin email-id", password: "password") { (responsObject, isSuccess, responseHttp) in
            if isSuccess{
                Utils().showSuccessToast(viewController: self, message: "Login API call Successfully")
            }
        }
    }
    
}

