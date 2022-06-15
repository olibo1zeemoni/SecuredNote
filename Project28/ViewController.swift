//
//  ViewController.swift
//  Project28
//
//  Created by Olibo moni on 04/03/2022.
//
import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    var rightButton: UIBarButtonItem!
    var leftButton: UIBarButtonItem!
    var password: String?
    var count = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
         rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(reLock))
       
        //self.navigationItem.setHidesBackButton(true, animated:true)
       
        leftButton = UIBarButtonItem(title: "password", style: .plain, target: self, action: #selector(enterPassword))
        navigationItem.leftBarButtonItem = leftButton
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @IBAction func authenticateTapped(_ sender: UIButton) {
        
        let context = LAContext()
        var error: NSError?
       
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identify yourself"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        //error
                        let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, Please try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        }
        else {
            //no biometry or passcode
    }
 
    }
    
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

            if notification.name == UIResponder.keyboardWillHideNotification {
                secret.contentInset = .zero
            } else {
                secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            }

            secret.scrollIndicatorInsets = secret.contentInset

            let selectedRange = secret.selectedRange
            secret.scrollRangeToVisible(selectedRange)
        
    }
    
    @objc func enterPassword(){
        count += 1
        let ac = UIAlertController(title: "Enter password", message: nil, preferredStyle: .alert)
        
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter password"
            self.password = textField.text
           // KeychainWrapper.standard.set(textField.text ?? "none" , forKey: "password1")
            
        }
        ac.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Confirm password"
            //KeychainWrapper.standard.set(textField.text ?? "", forKey: "password2")
        }
        ac.addAction(UIAlertAction(title: "Unlock", style: .default, handler: { [weak self] action in
            
            guard ac.textFields?.first != nil else { return }
            guard ac.textFields?[1] != nil else { return }
            guard ac.textFields?.first?.text == ac.textFields?[1].text else { return }
            
            
            switch self?.count {
            case 1:
                KeychainWrapper.standard.set( ac.textFields!.first!.text! , forKey: "password")
                self?.unlockSecretMessage()
                print("first time")
            default:
                if ac.textFields?[1].text == KeychainWrapper.standard.string(forKey: "password") {
                    self?.unlockSecretMessage()
                }
                print("any other time")
            }
                
            
        }))
        
        present(ac,animated: true)
        
    }
    
    func unlockSecretMessage(){
        secret.isHidden = false
        title = "Secret stuff"
        navigationItem.rightBarButtonItem = rightButton
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        //print(KeychainWrapper.standard.string(forKey: "password1"))
    }
    
   @objc func saveSecretMessage(){
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
    
    @objc func reLock(){
      
        //print("hello world")
        saveSecretMessage()
        self.navigationItem.setRightBarButton(nil, animated: true)
    }
}






/*
 if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
     let reason = "Identify yourself"
     
     context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
         DispatchQueue.main.async {
             if success {
                 self?.unlockSecretMessage()
             } else {
                 let ac = UIAlertController(title: "Authentication Failed", message: "You could not be verified, Please try again", preferredStyle: .alert)
                 ac.addAction(UIAlertAction(title: "Ok", style: .default))
                 self?.present(ac, animated: true)
             }
         }
     }
 } else {
     // no biometry
     
     if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
         
     }
     let ac = UIAlertController(title: "Biometry Unavailable", message: "Enter your password", preferredStyle: .alert)
     ac.addTextField(){ someText in
         someText.isSecureTextEntry = true
         KeychainWrapper.standard.set(someText.text!, forKey: "password")
         
     }*/
