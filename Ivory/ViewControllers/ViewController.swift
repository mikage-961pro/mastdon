//
//  ViewController.swift
//  Ivory
//
//  Created by Asko Nomm on 17/07/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        App().getTokenFromStore() { (token) in
            
            if(token != "") {
                
                OperationQueue.main.addOperation {

                    let vc = ContainerController()
                    let navigationController = UINavigationController()
                    
                    navigationController.modalPresentationStyle = .fullScreen
                    navigationController.viewControllers = [vc]
                    
                    print("TOKEN:")
                    print(token)
                    self.present(navigationController, animated: false, completion: nil)

                }
                
            } else {
            
                OperationQueue.main.addOperation {
                    
                    let vc = AuthenticateViewController()
                    let navigationController = UINavigationController()
                    
                    navigationController.modalPresentationStyle = .fullScreen
                    navigationController.viewControllers = [vc]
                    
                    self.present(navigationController, animated: false, completion: nil)
                    
                }
                
            }
            
        }

    }


}

