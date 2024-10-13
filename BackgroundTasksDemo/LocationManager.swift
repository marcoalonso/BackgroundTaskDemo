//
//  LocationManager.swift
//  BackgroundTasksDemo
//
//  Created by Marco Alonso on 12/10/24.
//

import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        startUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            print("Ubicación actualizada: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func scheduleNotification() {
        guard let location = currentLocation else {
            print("Error: Ubicación no disponible")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Actualización"
        content.body = "Tu ubicación es: \(currentLocation?.coordinate.latitude ?? 0), \(currentLocation?.coordinate.longitude ?? 0)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let request = UNNotificationRequest(identifier: "locationNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error al programar la notificación: \(error.localizedDescription)")
            }
        }
    }
}
