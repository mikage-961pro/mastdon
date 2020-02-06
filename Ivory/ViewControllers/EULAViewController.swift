//
//  EULAViewController.swift
//  Ivory
//
//  Created by Asko Nomm on 22/08/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import Foundation
import UIKit

class EULAViewController: UIViewController {

    override func viewDidLoad() {
           
        super.viewDidLoad()

        // Set background
        self.view.backgroundColor = UIColor.white

        // Back button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))

        // Set title
        self.navigationItem.title = "Terms of Service"

        // terms
        App().getCredentialsFromStore() { (credentials) in
            
            let instanceURL: String = credentials["instance_url"]!
            let termsURL: String = "https://" + instanceURL + "/about/more"
            let privacyPolicyURL: String = "https://" + instanceURL + "/terms"
            
            let termsView = UITextView(frame: CGRect(x: 15, y: 190, width: self.view.frame.width - 30, height: 60))
            
            termsView.center.x = self.view.center.x
            
            let termsStyle = NSMutableParagraphStyle()

            termsStyle.lineSpacing = 5
            termsStyle.paragraphSpacing = 0
            termsStyle.alignment = .center

            let termsText = "<p style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: 12.5px;text-align:center;line-height:1.8;color:#444;)\">By continuing you agree to the <a href='" + termsURL + "'>Terms of Service</a> and <a href='" + privacyPolicyURL + "'>Privacy Policy</a> of this instance.</p>"
            
            termsView.attributedText = NSAttributedString(html: termsText)
            termsView.isUserInteractionEnabled = true
            
            self.view.addSubview(termsView)
            
            // Create button
            let button = UIButton(frame: CGRect(x: 20, y: 265, width: self.view.frame.width - 30, height: 40))
            
            button.backgroundColor = UIColor(red: 43.0/255.0, green: 144.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            button.layer.cornerRadius = 4
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.center.x = self.view.center.x
            button.setTitle("Continue", for: .normal)
            button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
            
            self.view.addSubview(button)
            
        }
        
    }
    
    @objc func backAction() {
        
        dismiss(animated: false, completion: nil)
        
    }
    
    @objc func buttonAction() {
        
        OperationQueue.main.addOperation {
            
            let vc = AuthenticatingViewController()
            let navigationController = UINavigationController()
            
            navigationController.viewControllers = [vc]
            navigationController.modalPresentationStyle = .fullScreen
            
            self.present(navigationController, animated: false, completion: nil)
            
        }
        
    }
    
}

extension NSAttributedString {
     convenience init?(html: String) {
        guard let data = html.data(using: String.Encoding.unicode, allowLossyConversion: false) else {
            return nil
        }
        guard let attributedString = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        self.init(attributedString: attributedString)
    }
}
