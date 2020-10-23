//
//  Helpers.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/21/20.
//

import UIKit
import NotificationBannerSwift

class Helpers {
    
    static func storeJpgToFile(image: UIImage, pathComponent: String, size: CGSize) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageToStore = image.resize(newSize: size)
        
        if let data = imageToStore.jpegData(compressionQuality: 1.0) {
            let fileName = documentsDirectory.appendingPathComponent(pathComponent)
            do {
                try data.write(to: fileName)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func storePngToFile(image: UIImage, pathComponent: String, size: CGSize) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageToStore = image.resize(newSize: size)
        
        if let data = imageToStore.pngData() {
            let fileName = documentsDirectory.appendingPathComponent(pathComponent)
            try? data.write(to: fileName)
        }
    }
    
    static func getImageFromFile(pathComponent: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imageUrl = documentsDirectory.appendingPathComponent(pathComponent)
        if FileManager.default.fileExists(atPath: imageUrl.path) {
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image
        } else {
            return nil
        }
    }
    
    static func showNotificationBanner(title: String, subtitle: String, image: UIImage?, style: BannerStyle) {
        var leftView: UIImageView? = nil
        
        if let image = image {
            leftView = UIImageView(image: image)
        }
        
        let notificationBanner = FloatingNotificationBanner(title: title, subtitle: subtitle, titleFont: .boldSystemFont(ofSize: 20), titleColor: .white, titleTextAlign: .left, subtitleFont: .systemFont(ofSize: 17), subtitleColor: .white, subtitleTextAlign: .left, leftView: leftView, rightView: nil, style: style, colors: nil, iconPosition: .center)
        
        notificationBanner.show(queuePosition: .back, bannerPosition: .top, queue: .default, on: nil, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), cornerRadius: 7.5, shadowColor: .black, shadowOpacity: 1, shadowBlurRadius: 5, shadowCornerRadius: 5, shadowOffset: .zero, shadowEdgeInsets: nil)
    }
    
}
