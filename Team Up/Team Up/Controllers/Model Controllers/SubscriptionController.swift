//
//  SubscriptionController.swift
//  Team Up
//
//  Created by Jordan Bryant on 5/15/21.
//

import Foundation
import Purchases

class SubscriptionController {
    
    static let shared = SubscriptionController()
    
    private let publicKey = "pHGSiTQBlXJCZcIDFLScrxEpvMENsqqO"
    var currentPackage: Purchases.Package? = nil
    
    func setupSubscriptions() {
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: publicKey)
        fetchPackages()
    }
    
    func fetchPackages() {
        Purchases.shared.offerings { [weak self] (offerings, error) in
            if let error = error {
                print("\n\nError retrieving offerings: \(error)\n\nError Localized Description: \(error.localizedDescription)\n\n")
            } else if let packages = offerings?.current?.availablePackages, let currentPackage = packages.first, let strongSelf = self {
                strongSelf.currentPackage = currentPackage
                
                print("\n\n")
                print("CURRENT PACKAGE")
                print(currentPackage.localizedPriceString)
                print(currentPackage.localizedIntroductoryPriceString)
                print(currentPackage.packageType == Purchases.PackageType.monthly)
                print("\n\n")
                
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
    
}
