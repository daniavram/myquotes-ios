//
//  LoginViewController.swift
//  my-quotes
//
//  Created by Daniel Avram on 13/04/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initViewInterface()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailTextField.text = Keychain.get(.email)
        self.passwordTextField.text = nil
        
        if let keychainToken = Keychain.get(.token) {
            
            API.updateHeaders(token: keychainToken)
            
            API.checkToken(completion: { response in
            
                if let _ = response {
                    DispatchQueue.main.async() { [unowned self] in
                        self.performSegue(withIdentifier: "loginSuccess", sender: nil)
                    }
                } else {
                    self.loginFailed()
                }
                
            })
            
        }
    }
    
    private func initViewInterface() {
        
        emailTextField.font = Font.type(for: .login)
        passwordTextField.font = Font.type(for: .login)
        loginButton.titleLabel?.font = Font.type(for: .login)
        
        emailTextField.tintColor = Theme.primary.color
        passwordTextField.tintColor = Theme.primary.color
        loginButton.tintColor = Theme.primary.color
        
    }
    
    private func loginFailed() {
        
        let alertController = UIAlertController(title: "Login failed", message: "Please try again", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let navController = segue.destination as? UINavigationController,
            let controller = navController.viewControllers.first as? QuotesViewController {
            controller.stateController = StateController()
        }
        
    }
    
    @IBAction func loginButtonTap(_ sender: Any) {
        
        let authentication = Authentication(email: emailTextField.text!, password: passwordTextField.text!)
        
        API.getToken(authenticationRequest: authentication, completion: { success in
            
            guard success != nil else {
                self.loginFailed()
                return
            }
            
            Keychain.set(.email, value: self.emailTextField.text!)
            Keychain.set(.token, value: (success?.token)!)
            
            self.performSegue(withIdentifier: "loginSuccess", sender: nil)
        })
        
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            self.loginButtonTap(loginButton)
        }
        return true
    }
    
}
