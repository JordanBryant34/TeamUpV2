//
//  AddBioViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/20/20.
//

import UIKit

class AddBioViewController: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "addBioBackground")
        imageView.alpha = 0.1
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        title = "Bio"
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        
        backgroundImageView.pinEdgesToView(view: view)
    }
    
    deinit {
        print("\n\nAddBioViewController Deinit\n\n")
    }
}
