//
//  ViewController.swift
//  Friends
//
//  Created by vamsi krishna reddy kamjula on 9/3/17.
//  Copyright © 2017 applicationDevelopment. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.presentingHomeScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            emailTextField.text = nil
            passwordTextField.text = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if let loginError = error {
                    let loginFailAlert = UIAlertController.init(title: "Login Failed !!!", message: "Username/Password does not exist.", preferredStyle: .alert)
                    let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                    loginFailAlert.addAction(cancelAction)
                    self.present(loginFailAlert, animated: true, completion: nil)
                    print(loginError.localizedDescription)
                    return
                }
                self.presentingHomeScreen()
            })
        }
    }
    
    @IBAction func createNewUserButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let newUserFail = error {
                    let newUserFailAlert = UIAlertController.init(title: "Something went wrong.", message: "Please Try Again", preferredStyle: .alert)
                    let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                    newUserFailAlert.addAction(cancelAction)
                    self.present(newUserFailAlert, animated: true, completion: nil)
                    print(newUserFail.localizedDescription)
                    return
                }
                self.presentingHomeScreen()
            })
        }
    }
    
    func presentingHomeScreen() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "LoggedInTBC") as! LoggedInTBC
        self.present(tabBarController, animated: true, completion: nil)
    }
}
