//
//  App.swift
//  Ivory
//
//  Created by Asko Nomm on 17/07/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import Foundation

class App {

    public func getCredentials(instanceURL: String, completion: @escaping (_ response: Bool) -> (Void) ) -> Void {
        
        let payload = ["client_name": "imas",
                       "redirect_uris": "http://localhost:8000",
                       "scopes": "write read follow"]

        var request = URLRequest(url: URL(string: "https://" + instanceURL + "/api/v1/apps")!)
            request.httpMethod = "POST"
        
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                return
                
            }
            
            do {
                
                let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                
                self.setCredentials(clientId: result!["client_id"] as! String,
                                    clientSecret: result!["client_secret"] as! String,
                                    instanceURL: instanceURL)
                
                completion(true)
                
            } catch {
                
                print("Error -> \(error)")
                
                completion(false)
                
            }
            
        }
        
        task.resume()
        
    }
    
    public func getCredentialsFromStore(completion: @escaping (_ credentials: [String: String]) -> (Void) ) -> Void {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("credentials.json")
        
        do {
            
            let data = try Data(contentsOf: fileUrl, options: [])
            
            guard let credentials = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return }
            
            completion(credentials)
            
        } catch {
            
            completion(["": ""])
            
        }
        
    }
    
    public func setCredentials(clientId: String, clientSecret: String, instanceURL: String) {

        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentDirectoryUrl.appendingPathComponent("credentials.json")
        
        let credentials = ["client_id": clientId,
                           "client_secret": clientSecret,
                           "instance_url": instanceURL]
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: credentials, options: [])
            try data.write(to: fileUrl, options: [])
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    public func getCodeFromStore(completion: @escaping (_ credentials: String) -> (Void) ) -> Void {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("code.json")
        
        do {
            
            let data = try Data(contentsOf: fileUrl, options: [])
            
            guard let code = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return }
            
            completion(code["code"]!)
            
        } catch {
            
            completion("")
            
        }
        
    }
    
    public func setCode(code: String) {
        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentDirectoryUrl.appendingPathComponent("code.json")
        
        let token = ["code": code]
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: token, options: [])
            try data.write(to: fileUrl, options: [])
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    public func getToken(credentials: [String: String], code: String, completion: @escaping (_ credentials: String) -> (Void) ) -> Void {
        
        let payload = [
            "client_id": credentials["client_id"],
            "client_secret": credentials["client_secret"],
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": "http://localhost:8000"]
        
        var request = URLRequest(url: URL(string: "https://" + credentials["instance_url"]! + "/oauth/token")!)
        request.httpMethod = "POST"
        
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            
        } catch let error {
            
            print(error.localizedDescription)
            
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                return
                
            }
            
            do {
                
                let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                
                self.setToken(token: result!["access_token"]! as! String)

                completion(result!["access_token"]! as! String)
                
            } catch {
                
                print("Error -> \(error)")
                
            }
            
        }
        
        task.resume()
        
    }
    
    public func getTokenFromStore(completion: @escaping (_ credentials: String) -> (Void) ) -> Void {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("token.json")
        
        do {
            
            let data = try Data(contentsOf: fileUrl, options: [])
            
            guard let token = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return }
            
            completion(token["token"]!)
            
        } catch {
            
            completion("")
            
        }
        
    }
    
    public func setToken(token: String) {
        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentDirectoryUrl.appendingPathComponent("token.json")
        
        let token = ["token": token]
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: token, options: [])
            try data.write(to: fileUrl, options: [])
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    public func setPushToken(token: String) {
        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentDirectoryUrl.appendingPathComponent("push-token.json")
        
        let token = ["token": token]
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: token, options: [])
            try data.write(to: fileUrl, options: [])
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    public func getPushTokenFromStore(completion: @escaping (_ credentials: String) -> (Void) ) -> Void {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("push-token.json")
        
        do {
            
            let data = try Data(contentsOf: fileUrl, options: [])
            
            guard let token = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return }
            
            completion(token["token"]!)
            
        } catch {
            
            completion("")
            
        }
        
    }
    
    public func setNewestNotificationIdInStore(id: String) {
        
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentDirectoryUrl.appendingPathComponent("newest-notification-id.json")
        
        let write = ["id": id]
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: write, options: [])
            try data.write(to: fileUrl, options: [])
            
        } catch {
            
            print(error)
            
        }
        
    }
    
    public func getNewestNotificationIdInStore(completion: @escaping (_ credentials: String) -> (Void) ) -> Void {
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("newest-notification-id.json")
        
        do {
            
            let data = try Data(contentsOf: fileUrl, options: [])
            
            guard let read = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return }
            
            completion(read["id"]!)
            
        } catch {
            
            completion("")
            
        }
        
    }
    
    public func getNotificationsSinceId(id: String, completion: @escaping (_ notifications: [[String: Any]]) -> (Void)) -> Void {
    
        self.getCredentialsFromStore() { (credentials) in
                     
            self.getTokenFromStore() { (token) in

                var request = URLRequest(url: URL(string: "https://" + credentials["instance_url"]! + "/api/v1/notifications?since_id=" + id)!)
                         
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")

                let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                 
                    if error != nil {
                     
                        return
                     
                    }
                             
                    do {
        
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]]

                        completion(result!)

                    } catch {

                        //completion(AnyObject)

                    }

                }
                         
                task.resume()
                         
            }
                     
        }
        
    }
    
}
