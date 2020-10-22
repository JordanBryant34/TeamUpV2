//
//  Helpers.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/21/20.
//

import UIKit

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
    
}
