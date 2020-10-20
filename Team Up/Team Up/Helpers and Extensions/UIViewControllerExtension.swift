//
//  UIViewControllerExtension.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

extension UIViewController {
    
    func makeNavigationBarClear() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
    }
}
