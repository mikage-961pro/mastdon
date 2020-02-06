//
//  AppDelegate.swift
//  Ivory
//
//  Created by Asko Nomm on 17/07/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var initialViewController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set time zone
        let today = Date()
        var calendar = Calendar.current
        
        calendar.timeZone = .current
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: today)
        let secondsFromGMT: Int = components.minute! / 60
        let tz = NSTimeZone.init(forSecondsFromGMT: secondsFromGMT)
        
        NSTimeZone.default = tz as TimeZone

        // Initial view controller
        initialViewController  = ViewController()
        
        let frame = UIScreen.main.bounds
        
        window = UIWindow(frame: frame)
        window!.rootViewController = initialViewController
        window!.makeKeyAndVisible()
        
        registerForPushNotifications()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Notifications
        var bgTask = UIBackgroundTaskIdentifier(rawValue: 1)
        
        bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(bgTask)
        })
        
        let timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.queryNotifications), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        
        return true
        
    }
    
    @objc func queryNotifications() {
        
        App().getNewestNotificationIdInStore() { (id) in
            
            if id != "" {
                
                App().getNotificationsSinceId(id: id) { (notifications) in
                    
                    if !notifications.isEmpty {
                        
                        let notificationId: String = notifications[0]["id"] as! String
                        let notificationType: String = notifications[0]["type"] as! String
                        let notificationAccount: [String: Any] = notifications[0]["account"] as! [String: Any]
                        let notificationAccountName: String = notificationAccount["display_name"] as! String
                        let notificationAccountAcct: String = notificationAccount["acct"] as! String
                        
                        App().setNewestNotificationIdInStore(id: notificationId)
                        
                        let center = UNUserNotificationCenter.current()
                        
                        center.getNotificationSettings { (settings) in
                            
                          if settings.authorizationStatus == .authorized {
                            
                            let content = UNMutableNotificationContent()
                            
                            if notificationType == "mention" {
                                
                                content.title = notificationAccountName
                                //content.subtitle = "@" + notificationAccountAcct
                                content.body = "Mentioned you."
                                
                            }
                            
                            if notificationType == "favourite" {
                                
                                content.title = notificationAccountName
                                //content.subtitle = "@" + notificationAccountAcct
                                content.body = "Favourited your toot."
                                
                            }
                            
                            if notificationType == "reblog" {
                                
                                content.title = notificationAccountName
                                //content.subtitle = "@" + notificationAccountAcct
                                content.body = "Boosted your toot."
                                
                            }
                            
                            if notificationType == "follow" {
                                
                                content.title = notificationAccountName
                                //content.subtitle = "@" + notificationAccountAcct
                                content.body = "Followed you."
                                
                            }
                            
                            content.sound = UNNotificationSound.default
                            
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                            let identifier = UUID().uuidString
                            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                            
                            center.add(request, withCompletionHandler: { (error) in
                                
                              if let error = error {
                                
                                print("Something went wrong")
                                print(error)
                                
                              }
                                
                            })
                            
                          }

                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func registerForPushNotifications() {
        
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            
          guard granted else { return }
        
          self?.getNotificationSettings()
        
      }
        
    }
    
    func getNotificationSettings() {
        
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        
        guard settings.authorizationStatus == .authorized else { return }
        
        DispatchQueue.main.async {
            
          UIApplication.shared.registerForRemoteNotifications()
            
        }
        
      }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()

        App().setPushToken(token: token)
        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register: \(error)")
        
    }

}

