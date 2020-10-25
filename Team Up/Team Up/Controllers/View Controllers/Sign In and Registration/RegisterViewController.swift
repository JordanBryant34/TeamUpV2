//
//  RegisterViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class RegisterViewController: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "registerBackground")
        imageView.alpha = 0.08
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let createAccountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 25)
        label.text = "Create a new account"
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField: TeamUpTextField = {
        let textField = TeamUpTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
        textField.backgroundColor = .teamUpDarkBlue()
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        textField.returnKeyType = .next
        textField.tag = 0
        return textField
    }()
    
    let passwordTextField: TeamUpTextField = {
        let textField = TeamUpTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
        textField.backgroundColor = .teamUpDarkBlue()
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.tag = 1
        return textField
    }()
    
    let confirmPasswordTextField: TeamUpTextField = {
        let textField = TeamUpTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabelColor()])
        textField.backgroundColor = .teamUpDarkBlue()
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.tag = 2
        return textField
    }()
    
    let createAccountButton: RoundedButton = {
        let button = RoundedButton()
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.secondaryLabelColor(), for: .disabled)
        button.setBackgroundImage(UIImage(color: .teamUpDarkBlue()), for: .disabled)
        button.setBackgroundImage(UIImage(color: .accent()), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndActions()
        setupViews()
    }
    
    private func setDelegatesAndActions() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        createAccountButton.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(passwordTextField)
        view.addSubview(emailTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(createAccountLabel)
        view.addSubview(createAccountButton)
        
        backgroundImageView.pinEdgesToView(view: view)
        
        passwordTextField.centerInView(view: view)
        passwordTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -15).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 15).isActive = true
        confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmPasswordTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        createAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createAccountLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -50).isActive = true
        
        createAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        createAccountButton.setHeightAndWidthConstants(height: 70, width: view.frame.width * 0.8)
    }
    
    private func checkIfReadyToContinue() {
        createAccountButton.isEnabled = false
        if let email = emailTextField.text, let password = passwordTextField.text, let passwordConfirmation = confirmPasswordTextField.text {
            if !email.isEmpty && !password.isEmpty && !passwordConfirmation.isEmpty {
                createAccountButton.isEnabled = true
            }
        }
    }
    
    @objc private func createAccountButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        guard let passwordConfirmation = confirmPasswordTextField.text, !passwordConfirmation.isEmpty else { return }
        
        UserController.createNewUser(email: email, password: password, passwordConfirmation: passwordConfirmation) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.navigationController?.pushViewController(SetupProfileViewController(), animated: true)
            case .failure(let error):
                print(error.localizedDescription)
                print(error)
            }
            
            self?.checkIfReadyToContinue()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        print("\n\nRegisterViewController Deinit\n\n")
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.accent().cgColor
        checkIfReadyToContinue()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.separatorColor().cgColor
        checkIfReadyToContinue()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
           nextField.becomeFirstResponder()
        } else {
           textField.resignFirstResponder()
        }
        
        checkIfReadyToContinue()
        
        return false
    }
    
}
