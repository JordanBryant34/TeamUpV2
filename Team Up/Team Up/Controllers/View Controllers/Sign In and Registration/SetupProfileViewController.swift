//
//  SetupProfileViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class SetupProfileViewController: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "setupProfileBackground")
        imageView.alpha = 0.09
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.accent().cgColor
        imageView.image = UIImage(named: "defaultProfilePic")
        imageView.backgroundColor = .teamUpDarkBlue()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let editProfilePicLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = .systemFont(ofSize: 14)
        label.text = "Edit Profile Picture"
        label.textColor = .accent()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = .systemFont(ofSize: 15)
        label.text = "Create a username"
        label.textColor = .accent()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let usernameTextField: TeamUpTextField = {
        let textField = TeamUpTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
        textField.backgroundColor = .teamUpDarkBlue()
        textField.autocorrectionType = .no
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        textField.returnKeyType = .next
        textField.tag = 0
        return textField
    }()
    
    let micLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = .systemFont(ofSize: 15)
        label.text = "Let others know if you have a mic"
        label.textColor = .accent()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let micSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        let tintColorImage = UIImage(color: .accent())
        sc.insertSegment(withTitle: "Mic", at: 0, animated: false)
        sc.insertSegment(withTitle: "No Mic", at: 1, animated: false)
        sc.backgroundColor = .teamUpDarkBlue()
        sc.selectedSegmentTintColor = .accent()
        sc.setBackgroundImage(UIImage(color: .teamUpDarkBlue()), for: .normal, barMetrics: .default)
        sc.setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
        sc.setBackgroundImage(UIImage(color: UIColor.accent().withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
        sc.setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabelColor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)], for: .normal)
        sc.setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        sc.layer.masksToBounds = true
        sc.layer.cornerRadius = 5
        sc.layer.borderWidth = 1.5
        sc.layer.borderColor = UIColor.separatorColor().cgColor
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    let regionTextField: TeamUpTextField = {
        let textField = TeamUpTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Region", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
        textField.backgroundColor = .teamUpDarkBlue()
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        return textField
    }()
    
    let regionLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.font = .systemFont(ofSize: 15)
        label.text = "Select your region"
        label.textColor = .accent()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let continueButton: RoundedButton = {
        let button = RoundedButton()
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.secondaryLabelColor(), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.setBackgroundImage(UIImage(color: .accent()), for: .normal)
        button.setBackgroundImage(UIImage(color: .teamUpDarkBlue()), for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    let cellId = "cellId"
    
    var profilePicUrl: String = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        removeNavigationBarBackButton()
        makeNavigationBarClear()
        setDelegatesAndActions()
        setupViews()
    }
    
    private func setDelegatesAndActions() {
        regionTextField.delegate = self
        usernameTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        profilePicImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentProfilePicController)))
        
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    private func setupViews() {
        title = "Profile Setup"
        
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(profilePicImageView)
        view.addSubview(editProfilePicLabel)
        view.addSubview(usernameTextField)
        view.addSubview(usernameLabel)
        view.addSubview(micSegmentedControl)
        view.addSubview(micLabel)
        view.addSubview(regionTextField)
        view.addSubview(regionLabel)
        view.addSubview(continueButton)
        
        backgroundImageView.pinEdgesToView(view: view)
        
        profilePicImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profilePicImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.03).isActive = true
        profilePicImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.125).isActive = true
        profilePicImageView.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.125).isActive = true
        profilePicImageView.layer.cornerRadius = view.frame.height * 0.125 / 2
        
        editProfilePicLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        editProfilePicLabel.topAnchor.constraint(equalTo: profilePicImageView.bottomAnchor, constant: 5).isActive = true
        
        usernameTextField.topAnchor.constraint(equalTo: editProfilePicLabel.bottomAnchor, constant: 70).isActive = true
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        usernameLabel.bottomAnchor.constraint(equalTo: usernameTextField.topAnchor, constant: -5).isActive = true
        usernameLabel.leftAnchor.constraint(equalTo: usernameTextField.leftAnchor, constant: 2.5).isActive = true
        
        micSegmentedControl.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 50).isActive = true
        micSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        micSegmentedControl.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        micLabel.bottomAnchor.constraint(equalTo: micSegmentedControl.topAnchor, constant: -5).isActive = true
        micLabel.leftAnchor.constraint(equalTo: micSegmentedControl.leftAnchor, constant: 2.5).isActive = true
        
        regionTextField.topAnchor.constraint(equalTo: micSegmentedControl.bottomAnchor, constant: 50).isActive = true
        regionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        regionTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        regionLabel.bottomAnchor.constraint(equalTo: regionTextField.topAnchor, constant: -5).isActive = true
        regionLabel.leftAnchor.constraint(equalTo: regionTextField.leftAnchor, constant: 2.5).isActive = true
        
        continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.setHeightAndWidthConstants(height: 70, width: view.frame.width * 0.8)
    }
    
    private func checkIfReadyToContinue() {
        if let username = usernameTextField.text, let regionString = regionTextField.text {
            if !username.isEmpty && !regionString.isEmpty {
                continueButton.isEnabled = true
            }
        }
    }
    
    @objc private func handleContinue() {
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        guard let region = regionTextField.text, !region.isEmpty else { return }
        
        continueButton.isEnabled = false
        
        var mic: MicStatus {
            if micSegmentedControl.selectedSegmentIndex == 1 {
                return .noMic
            } else {
                return .mic
            }
        }
        
        UserController.setupProfile(username: username, mic: mic, region: region, profileImageUrl: profilePicUrl) { [weak self] (success) in
            if success {
                self?.navigationController?.pushViewController(AddBioViewController(), animated: true)
            }
            
            self?.checkIfReadyToContinue()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func presentProfilePicController() {
        let selectProfilePicVC = SelectProfilePicViewController()
        selectProfilePicVC.modalPresentationStyle = .overFullScreen
        selectProfilePicVC.delegate = self
        present(selectProfilePicVC, animated: true, completion: nil)
    }
    
    deinit {
        print("\n\nSetupProfileViewController Deinit\n\n")
    }
}

extension SetupProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.accent().cgColor
        continueButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        dismissKeyboard()
        
        continueButton.isEnabled = false
        checkIfReadyToContinue()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == regionTextField {
            dismissKeyboard()
            let alertController = UIAlertController(title: "Select a region", message: nil, preferredStyle: .actionSheet)
            
            for region in Region.allCases {
                let action = UIAlertAction(title: region.rawValue, style: .default) { [weak self] (_) in
                    self?.regionTextField.text = region.rawValue
                    self?.checkIfReadyToContinue()
                }
                
                alertController.addAction(action)
            }
        
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            
            return false
        } else {
            return true
        }
    }
    
}

extension SetupProfileViewController: SelectProfilePicViewControllerDelegate {
    func profilePicChosen(imageUrl: String) {
        self.profilePicUrl = imageUrl
        UserController.fetchProfilePicture(picUrl: imageUrl) { [weak self] (image) in
            self?.profilePicImageView.image = image
        }
    }
}
