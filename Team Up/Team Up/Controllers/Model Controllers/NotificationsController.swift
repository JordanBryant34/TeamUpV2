//
//  NotificationsController.swift
//  Team Up
//
//  Created by Jordan Bryant on 2/14/21.
//

import UIKit
import UserNotifications

class NotificationsController {
    
    static var isRegisteredForNotifications: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    static func userWantsNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print("Notifications are already enabled")
            case .notDetermined:
                requestNotificationsPermissions()
            case .denied, .ephemeral:
                redirectToNotificationSettings()
            @unknown default:
                redirectToNotificationSettings()
            }
        }
    }
    
    private static func requestNotificationsPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if error == nil && success == true {
                let application = UIApplication.shared
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private static func redirectToNotificationSettings() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
    }
    
}
