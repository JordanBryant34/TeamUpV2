//
//  AdController.swift
//  Team Up
//
//  Created by Jordan Bryant on 2/24/21.
//

import UIKit
import MoPubSDK

class AdController {
    static let shared = AdController()
    
    private let interstitialAdId = "b0dee3730e4e47ab9e385b397ccee58a"
    
    var adController: MPInterstitialAdController?
    var requestsCount = 0
    
    func loadInterstitialAds() {
        if !SubscriptionController.shared.userSubscribed {
            DispatchQueue.main.async {
                self.adController?.loadAd()
            }
        }
    }
    
    func showAd(from viewController: UIViewController) {
        if let adController = adController, adController.ready, !SubscriptionController.shared.userSubscribed {
            adController.show(from: viewController)
        }
    }
    
    func setupMopub() {
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: interstitialAdId)

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
            self.adController = MPInterstitialAdController(forAdUnitId: self.interstitialAdId)
            self.loadInterstitialAds()
        }
    }
    
}
