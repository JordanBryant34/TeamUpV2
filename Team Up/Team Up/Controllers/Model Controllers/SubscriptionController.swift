//
//  SubscriptionController.swift
//  Team Up
//
//  Created by Jordan Bryant on 5/15/21.
//

import Foundation
import Purchases
import FirebaseAuth
import NotificationBannerSwift

class SubscriptionController {
    
    static let shared = SubscriptionController()
    
    private let publicKey = "pHGSiTQBlXJCZcIDFLScrxEpvMENsqqO"
    var currentPackage: Purchases.Package? = nil
    
    var userSubscribed = false {
        didSet {
            if userSubscribed {
                AdController.shared.requestsCount = 0
            }
        }
    }
    
    func setupSubscriptions() {
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: publicKey)
        fetchPackages()
        updateUserForSubscription()
    }
    
    func fetchPackages() {
        Purchases.shared.offerings { [weak self] (offerings, error) in
            if let error = error {
                print("\n\nError retrieving offerings: \(error)\n\nError Localized Description: \(error.localizedDescription)\n\n")
            } else if let packages = offerings?.current?.availablePackages, let currentPackage = packages.first, let strongSelf = self {
                strongSelf.currentPackage = currentPackage
            }
        }
    }
    
    func presentSubscriptionController(viewController: UIViewController) {
        guard let package = currentPackage else { return }
        
        let subscriptionController = SubscriptionsViewController()
        subscriptionController.modalPresentationStyle = .overFullScreen
        subscriptionController.subscriptionOfferTitle = "Get 3-day free trial, then only"
        
        switch package.packageType {
        case Purchases.PackageType.monthly:
            subscriptionController.priceText = "\(package.localizedPriceString)/month"
        case Purchases.PackageType.annual:
            subscriptionController.priceText = "\(package.localizedPriceString)/year"
        default:
            return
        }
        
        viewController.present(subscriptionController, animated: true, completion: nil)
    }
    
    func subscribeUser(completion: @escaping (_ success: Bool) -> Void)  {
        guard let package = currentPackage else { return }
        
        Purchases.shared.purchasePackage(package) { [weak self] (_, purchaserInfo, error, userCancelled) in
            if let error = error {
                print("Error purchasing package: \(error.localizedDescription)")
                
                if !userCancelled {
                    Helpers.showNotificationBanner(title: "Something went wrong...", subtitle: "Try subscribing again later.", image: nil, style: .danger, textAlignment: .left)
                }
                
                completion(false)
            } else if let strongSelf = self {
                strongSelf.checkSubscriptionStatus()
                completion(!userCancelled)
            }
        }
    }
    
    private func updateUserForSubscription() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let uid = user?.uid, let strongSelf = self {
                Purchases.shared.identify(uid) { (info, error) in
                    if let error = error {
                        print("Sign in error in SubscriptionController: \(error.localizedDescription)")
                    } else {
                        strongSelf.checkSubscriptionStatus()
                    }
                }
            }
        }
    }
    
    private func checkSubscriptionStatus() {
        Purchases.shared.purchaserInfo { [weak self] (purchaserInfo, error) in
            if let error = error {
                print("Error getting purchaser info: \(error.localizedDescription)")
            } else if let strongSelf = self {
                strongSelf.userSubscribed = purchaserInfo?.entitlements["removeAds"]?.isActive ?? false
            }
        }
    }
    
}
