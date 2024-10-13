//
//  ViewController.swift
//  BackgroundTasksDemo
//
//  Created by Marco Alonso on 12/10/24.
//

import UIKit
import BackgroundTasks

class ViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    let taskId = "com.marcoalonso.BTD"

    var locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showLocation()
        // requestPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showLocation()
        // submitBackgroundTask()
    }
    
    private func showLocation() {
        if let location = locationManager.currentLocation {
            locationLabel.text = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        }
    }

    private func submitBackgroundTask() {
        BGTaskScheduler.shared.getPendingTaskRequests { request in
            print("Debug: \(request.count) BGTask pending.")
            if !request.isEmpty {
                // BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskId)
                // print("Debug: \(taskId) task deleted!")
            }
            
            do {
                 let request = BGAppRefreshTaskRequest(identifier: self.taskId)
                // let request = BGProcessingTaskRequest(identifier: self.taskId)
                ///** what is the difference between BGProcessingTaskRequest and BGProcessingTaskRequest ** ///
                // request.requiresExternalPower = false
                // request.requiresNetworkConnectivity = true
                request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
                
                // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.rotadevsolutions.BTDemo.Notification"]
                
                // Schedule the background task
                try BGTaskScheduler.shared.submit(request)
                print("Debug: task scheduled: \(request.identifier)")
            } catch {
                print("Debug: Unable to schedule background task: \(error.localizedDescription)")
            }
        }
    }
    
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Debug: Permiso concedido para notificaciones locales")
            } else {
                print("Debug: Permiso denegado para notificaciones locales")
            }
        }
    }

}

