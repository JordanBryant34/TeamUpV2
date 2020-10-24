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
        imageView.alpha = 0.06
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let addBioLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Add a bio"
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.text = "Tell other players about yourself.\nOr don't."
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.textColor = .accent()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = .secondaryLabelColor()
        textView.backgroundColor = UIColor.teamUpDarkBlue().withAlphaComponent(0.7)
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.5
        textView.layer.borderColor = UIColor.separatorColor().cgColor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.text = "Write your bio..."
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let continueButton: RoundedButton = {
        let button = RoundedButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.backgroundColor = .accent()
        return button
    }()
    
    let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.text = ""
        label.textColor = .accent()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let characterLimit = 180
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndActions()
        setupViews()
    }
    
    private func setDelegatesAndActions() {
        bioTextView.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    private func setupViews() {
        title = "Bio"
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(addBioLabel)
        view.addSubview(detailLabel)
        view.addSubview(bioTextView)
        view.addSubview(characterCountLabel)
        view.addSubview(continueButton)
        
        backgroundImageView.pinEdgesToView(view: view)
        
        addBioLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addBioLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75).isActive = true
        
        detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: addBioLabel.bottomAnchor, constant: 10).isActive = true
        
        bioTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bioTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20).isActive = true
        bioTextView.setHeightAndWidthConstants(height: view.frame.height * 0.2, width: view.frame.width * 0.8)
        
        characterCountLabel.topAnchor.constraint(equalTo: bioTextView.bottomAnchor, constant: 5).isActive = true
        characterCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.setHeightAndWidthConstants(height: 70, width: view.frame.width * 0.8)
    }
    
    @objc private func handleContinue() {
        
        if bioTextView.text.count > characterLimit {
            Helpers.showNotificationBanner(title: "Bio is too long", subtitle: "Your bio has to be under \(characterLimit) characters.", image: nil, style: .danger, textAlignment: .left)
            return
        }
        
        if let bio = bioTextView.text, !bio.isEmpty, bio != "Write your bio..." {
            UserController.updateBio(bio: bio)
        }
        
        navigationController?.pushViewController(AddGamesViewController(), animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        print("\n\nAddBioViewController Deinit\n\n")
    }
}

extension AddBioViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabelColor() {
            textView.text = nil
            textView.textColor = .white
            textView.layer.borderColor = UIColor.accent().cgColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = UIColor.separatorColor().cgColor
        
        if textView.text.isEmpty {
            textView.text = "Write your bio..."
            textView.textColor = .secondaryLabelColor()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            bioTextView.resignFirstResponder()
            return false
        } else if text == "" && range.length > 0 {
            return true
        } else if bioTextView.text.count >= characterLimit {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if bioTextView.text.count > 0 {
            characterCountLabel.text = "\(bioTextView.text.count)/\(characterLimit) characters"
        } else {
            characterCountLabel.text = ""
        }
    }
    
}
