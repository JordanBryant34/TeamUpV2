//
//  SignInViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 10/19/20.
//

import UIKit

class SignInViewController: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "signInBackground")
        imageView.alpha = 0.08
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "teamUpLogo")?.resize(newSize: CGSize(width: view.frame.height * 0.125, height: view.frame.height * 0.125))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 27.5)
        label.text = "Welcome to Team Up"
        label.textColor = .white
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        label.text = "Log in or sign up to continue."
        label.textColor = .accent()
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
        textField.clearButtonMode = .whileEditing
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
        textField.clearButtonMode = .whileEditing
        textField.tag = 1
        return textField
    }()
    
    let signUpButton: RoundedButton = {
        let button = RoundedButton()
        button.setTitle("Create New Account", for: .normal)
        button.setTitleColor(.accent(), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.accent().cgColor
        return button
    }()
    
    let loginButton: RoundedButton = {
        let button = RoundedButton()
        button.setBackgroundImage(UIImage(color: .teamUpDarkBlue()), for: .disabled)
        button.setBackgroundImage(UIImage(color: .accent()), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.secondaryLabelColor(), for: .disabled)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndActions()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeNavigationBarClear()
        removeNavigationBarBackButton()
    }
    
    private func setDelegatesAndActions() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        signUpButton.addTarget(self, action: #selector(createNewAccountButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(logInUser), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        view.addSubview(welcomeLabel)
        view.addSubview(detailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        view.addSubview(loginButton)
        
        backgroundImageView.pinEdgesToView(view: view)
        
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.frame.height * 0.015).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.125).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: view.frame.height * 0.125).isActive = true
        
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20).isActive = true
        
        detailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10).isActive = true
        
        emailTextField.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -7.5).isActive = true
        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        passwordTextField.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 7.5).isActive = true
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.setHeightAndWidthConstants(height: 50, width: view.frame.width * 0.8)
        
        signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signUpButton.setHeightAndWidthConstants(height: 70, width: view.frame.width * 0.8)
        
        loginButton.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -20).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.setHeightAndWidthConstants(height: 70, width: view.frame.width * 0.8)
    }
    
    @objc private func logInUser() {
        guard let email = emailTextField.text, !email.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        loginButton.isEnabled = false
        
        UserController.loginUser(email: email, password: password) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.navigationController?.pushViewController(TabBarController(), animated: true)
            case .failure(let error):
                print(error)
            }
            
            self?.loginButton.isEnabled = true
        }
    }
    
    @objc private func createNewAccountButtonTapped() {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    deinit {
        print("\n\nSignInViewController Deinit\n\n")
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.accent().cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.separatorColor().cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
           nextField.becomeFirstResponder()
        } else {
           textField.resignFirstResponder()
        }
        
        return false
    }
    
}
