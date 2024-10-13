//
//  BackgroundTaskManager.swift
//  BackgroundTasksDemo
//
//  Created by Marco Alonso on 13/10/24.
//

import Foundation
import BackgroundTasks
import UserNotifications
import CoreLocation
import UIKit

class BackgroundTaskManager {
    
    private let locationManager = LocationManager()
    
    // Singleton pattern para manejar el BackgroundTaskManager
    static let shared = BackgroundTaskManager()
    
    private init() { }
    
    // Método para registrar las Background Tasks
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.marcoalonsorota.apprefresh", using: nil) { task in
            guard let task = task as? BGAppRefreshTask else {
                print("Debug: Error registering \(task)")
                return
            }
            task.expirationHandler = {
                print("Debug: expirationHandler")
                task.setTaskCompleted(success: false)
            }
            self.scheduleLocalNotification()
            self.handleBackgroundTask(task: task)
        }
    }

    // Método para manejar la tarea de fondo
    func handleBackgroundTask(task: BGAppRefreshTask) {
        print("Debug: handleBackgroundTask \(task.identifier)")
        task.expirationHandler = {
            print("Debug: expirationHandler called")
        }
        scheduleLocalNotification()
        task.setTaskCompleted(success: true)
    }
    
    // Método para registrar notificaciones locales
    func registerLocalNotification() {
        print("Debug: registerLocalNotification")
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    // Método para programar una notificación local
    func scheduleLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.fireNotification()
            }
        }
    }
    
    // Método para disparar una notificación
    func fireNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Ubicación"
        notificationContent.body = "\(locationManager.currentLocation?.coordinate.latitude ?? 0.0), \(locationManager.currentLocation?.coordinate.longitude ?? 0.0)"
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { error in
            if let error = error {
                print("Unable to Add Notification Request: \(error.localizedDescription)")
            }
        }
    }

    // Método para cancelar las tareas pendientes
    func cancelAllPendingBGTasks() {
        print("Debug: cancelAllPendingBGTasks")
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }

    // Método para programar el App Refresh
    func scheduleAppRefresh() {
        let timeDelay = 10.0
        let request = BGAppRefreshTaskRequest(identifier: "com.marcoalonsorota.apprefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: timeDelay)
        // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.marcoalonsorota.apprefresh"]
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Debug: scheduled \(request.identifier)")
        } catch {
            print("Debug: Could not schedule app refresh: \(error)")
        }
    }
}

