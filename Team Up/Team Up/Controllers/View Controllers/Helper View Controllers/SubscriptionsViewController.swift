//
//  SubscriptionsViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 3/1/21.
//

import UIKit
import NVActivityIndicatorView

class SubscriptionsViewController: UIViewController {
    
    private let subscribeButton: RoundedButton = {
        let button = RoundedButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setBackgroundImage(UIImage(color: .teamUpDarkBlue()), for: .disabled)
        button.setBackgroundImage(UIImage(color: .accent()), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.secondaryLabelColor(), for: .disabled)
        button.setTitle("Start free trial", for: .normal)
        return button
    }()
    
    private let declineButton: RoundedButton = {
        let button = RoundedButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.accent().cgColor
        button.setTitleColor(.accent(), for: .normal)
        button.backgroundColor = .clear
        button.setTitle("No thanks", for: .normal)
        return button
    }()
    
    private let offerTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22.5, weight: .semibold)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .accent()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .accent()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.text = "Tired of the ads?"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoSubLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17.5)
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.text = "Subscribing removes all ads from the app."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientSeparator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gradientSeparator")
        return imageView
    }()
    
    private let gradientFade: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "gradientImage")
        return imageView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "addGamesBackground")
        imageView.alpha = 0.3
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let finePrintLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.text = "This subscription renews automatically unless cancelled in 'Settings' at least 24 hours before the next billing date."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.15, height: view.frame.width * 0.15)
        let indicator = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple, color: .accent(), padding: nil)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancelIcon")?.resize(newSize: CGSize(width: 25, height: 25)), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var subscriptionOfferTitle: String? {
        didSet {
            offerTitleLabel.text = subscriptionOfferTitle
        }
    }
    
    var priceText: String? {
        didSet {
            priceLabel.text = priceText
        }
    }
    
    private let subscriptionController = SubscriptionController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        declineButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        subscribeButton.addTarget(self, action: #selector(handleSubscribeTapped), for: .touchUpInside)
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .teamUpBlue()
        
        view.addSubview(backgroundImageView)
        view.addSubview(subscribeButton)
        view.addSubview(declineButton)
        view.addSubview(priceLabel)
        view.addSubview(offerTitleLabel)
        view.addSubview(gradientSeparator)
        view.addSubview(infoSubLabel)
        view.addSubview(infoLabel)
        view.addSubview(finePrintLabel)
        view.addSubview(activityIndicator)
        view.addSubview(dismissButton)
        
        backgroundImageView.addSubview(gradientFade)
        
        backgroundImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        gradientFade.anchor(backgroundImageView.topAnchor, left: backgroundImageView.leftAnchor, bottom: backgroundImageView.bottomAnchor, right: backgroundImageView.rightAnchor, topConstant: -100, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        subscribeButton.anchor(view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: view.frame.height * 0.2, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: view.frame.height * 0.075)
        declineButton.anchor(subscribeButton.bottomAnchor, left: subscribeButton.leftAnchor, bottom: nil, right: subscribeButton.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.height * 0.050)
        gradientSeparator.anchor(nil, left: view.leftAnchor, bottom: offerTitleLabel.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 25, rightConstant: 20, widthConstant: 0, heightConstant: 2)
        infoSubLabel.anchor(nil, left: view.leftAnchor, bottom: gradientSeparator.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 60, bottomConstant: 0, rightConstant: 60, widthConstant: 0, heightConstant: view.frame.height * 0.125)
        
        priceLabel.bottomAnchor.constraint(equalTo: subscribeButton.topAnchor, constant: -20).isActive = true
        priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        offerTitleLabel.bottomAnchor.constraint(equalTo: priceLabel.topAnchor, constant: -10).isActive = true
        offerTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        infoLabel.bottomAnchor.constraint(equalTo: infoSubLabel.topAnchor, constant: 10).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        finePrintLabel.topAnchor.constraint(equalTo: declineButton.bottomAnchor, constant: 15).isActive = true
        finePrintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finePrintLabel.widthAnchor.constraint(equalTo: declineButton.widthAnchor).isActive = true
        finePrintLabel.heightAnchor.constraint(equalTo: declineButton.heightAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        activityIndicator.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        activityIndicator.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1).isActive = true
        
        dismissButton.setHeightAndWidthConstants(height: 30, width: 30)
        dismissButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
    }
    
    @objc private func handleSubscribeTapped() {
        activityIndicator.startAnimating()
        subscribeButton.isEnabled = false
        subscriptionController.subscribeUser { [weak self] (success) in
            self?.activityIndicator.stopAnimating()
            self?.subscribeButton.isEnabled = true
            if success {
                Helpers.showNotificationBanner(title: "You are now subscribed.", subtitle: "", image: nil, style: .success, textAlignment: .center)
                self?.handleDismiss()
            }
        }
    }
    
    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
