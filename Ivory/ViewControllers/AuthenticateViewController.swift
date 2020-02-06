//
//  AuthenticateViewController.swift
//  Ivory
//
//  Created by Asko Nomm on 17/07/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import UIKit

class AuthenticateViewController: UIViewController, UITextFieldDelegate {
    
    var image: UIImageView!
    var label: UILabel!
    var textField: UITextField!
    var button: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.load()
        
    }
    
    public func load() {
        
        // Set title
        // navigationItem.title = "Sign In"
        navigationController?.isNavigationBarHidden = true
        
        // Set background color
        self.view.backgroundColor = .white
        
        // Create image
        image = UIImageView(image: UIImage(named: "Logo"))
        image.frame = CGRect(x: 0, y: 50, width: 125 , height: 125)
        image.layer.cornerRadius = image.frame.height / 2
        image.clipsToBounds = true
        image.center.x = self.view.center.x
        
        view.addSubview(image)
        
        // Create label
        label = UILabel(frame: CGRect(x: 0, y: 200, width: 300, height: 20))
        label.text = "Enter your Mastodon instance address"
        label.font = UIFont.systemFont(ofSize: 12.5)
        label.textAlignment = .center
        label.textColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.0)
        label.center.x = self.view.center.x
        
        view.addSubview(label)
        
        // Input background
        let gray = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        let textFieldBG = UIView(frame: CGRect(x: 0, y: 250, width: self.view.frame.width, height: 40))
        
        textFieldBG.backgroundColor = gray
        textFieldBG.center.x = self.view.center.x
        
        view.addSubview(textFieldBG)
        
        // Create input
        textField = UITextField(frame: CGRect(x: 0, y: 250, width: self.view.frame.width - 30, height: 40))
        textField.attributedPlaceholder = NSAttributedString(string: "mastodon.social",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 12.5)
        textField.delegate = self
        textField.borderStyle = UITextField.BorderStyle.none
        textField.clearsOnBeginEditing = true
        textField.center.x = self.view.center.x
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = UIKeyboardType.URL
        
        view.addSubview(textField)
        
        // Create button
        button = UIButton(frame: CGRect(x: 0, y: 305, width: self.view.frame.width - 30, height: 40))
        button.backgroundColor = UIColor(red: 43.0/255.0, green: 144.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.center.x = self.view.center.x
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
        
    }
    
    @objc private func buttonAction(sender: UIButton!) {
        
        var instanceURL: String = textField.text ?? ""
        
        if(instanceURL.contains("http://")) {
            
            instanceURL = instanceURL.replacingOccurrences(of: "http://", with: "")
            
        }
        
        if(instanceURL.contains("https://")) {
            
            instanceURL = instanceURL.replacingOccurrences(of: "https://", with: "")
            
        }
        
        // does it contain special characters besides dots?
        if(instanceURL.contains("@")) {
            
            let alert = UIAlertController(title: "Incorrect address", message: "Please make sure that this is a correct instance URL.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
        } else {
        
            App().getCredentials(instanceURL: instanceURL) { (response) in
                
                if(response) {
                    
                    OperationQueue.main.addOperation {
                        
                        let vc = EULAViewController()
                        let navigationController = UINavigationController()
                        
                        navigationController.viewControllers = [vc]
                        navigationController.modalPresentationStyle = .fullScreen
                        
                        self.present(navigationController, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
        }
    
    }

}
