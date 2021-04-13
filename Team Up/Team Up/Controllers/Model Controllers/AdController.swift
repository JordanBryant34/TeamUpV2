//
//  AdController.swift
//  Team Up
//
//  Created by Jordan Bryant on 2/24/21.
//

import Foundation
import GoogleMobileAds

class AdController {
    
    static let shared = AdController()
    
    private let rewardedInterstitalTestId = "ca-app-pub-3940256099942544/6978759866"
    
    var rewardedInterstitialAd: GADRewardedInterstitialAd?
    
    var requestsCount = 0
    
    func loadAds() {
        loadRewardedInterstitialAd()
    }
    
    func loadRewardedInterstitialAd() {
        GADRewardedInterstitialAd.load(withAdUnitID: rewardedInterstitalTestId, request: GADRequest()) { (rewardedAd, error) in
            if let error = error {
                print("Error loading rewarded interstitial ad: \(error.localizedDescription)")
            } else if let rewardedAd = rewardedAd {
                print("Successfully loaded rewarded interstitial ad")
                self.rewardedInterstitialAd = rewardedAd
            }
        }
    }
    
    func showRequestsRewardAd() {
        let scene = UIApplication.shared.connectedScenes.first
        guard let sceneDelegate = (scene?.delegate as? SceneDelegate) else { return }
        guard let tabBarController = sceneDelegate.tabBarController else { return }
        guard let rewardAd = rewardedInterstitialAd else { return }
        
        rewardAd.present(fromRootViewController: tabBarController) {
            self.requestsCount = 0
            self.loadRewardedInterstitialAd()
        }
    }
}
