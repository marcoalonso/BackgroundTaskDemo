//
//  AppDelegate.swift
//  BackgroundTasksDemo
//
//  Created by Marco Alonso on 12/10/24.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let locationManager = LocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerBackgroundTasks()
        registerLocalNotification()
        return true
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.marcoalonsorota.apprefresh", using: nil) { task in
            guard let task = task as? BGAppRefreshTask else {
                print("Debug: Error registering  \(task)")
                return
            }
            task.expirationHandler = {
                print("Debug: expirationHandler ")
                task.setTaskCompleted(success: false)
            }
            self.scheduleLocalNotification()
            self.handleBackgroundTask(task: task)
        }
    }
    
    func handleBackgroundTask(task: BGAppRefreshTask) {
        print("Debug:  handleBackgroundTask \(task.identifier)")
        print("Debug: task completed: \(task.description)")
        task.expirationHandler = {
            print("Debug: expirationHandler called")
        }
        scheduleLocalNotification()
        task.setTaskCompleted(success: true)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {
    
    func registerLocalNotification() {
        print("Debug: registerLocalNotification ")
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.fireNotification()
            }
        }
    }
    
    func fireNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Ubicación"
        
        notificationContent.body = "\(locationManager.currentLocation?.coordinate.latitude ?? 0.0), \(locationManager.currentLocation?.coordinate.longitude ?? 0.0)"
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        cancelAllPandingBGTask()
        scheduleAppRefresh()
        print("Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)s")
    }
    
}

extension AppDelegate {
    func cancelAllPandingBGTask() {
        print("Debug: cancelAllPandingBGTask ")
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    func scheduleAppRefresh() {
        let timeDelay = 10.0
        
        do {
        let request = BGAppRefreshTaskRequest(identifier: "com.marcoalonsorota.apprefresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
            // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.marcoalonsorota.apprefresh"]
            
            try BGTaskScheduler.shared.submit(request)
            print("Debug: scheduled \(request.identifier)")
        } catch {
            print("Debug: Could not schedule app refresh: \(error)")
        }
    }
}
