//
//  PromptUserViewController.swift
//  Team Up
//
//  Created by Jordan Bryant on 2/13/21.
//

import UIKit

protocol PromptUserViewControllerDelegate: AnyObject {
    func userAcceptedPrompt()
    func promptDismissed()
    func timerUpdated(currentTime: TimeInterval, promptVC: PromptUserViewController)
    func timerEnded()
}

extension PromptUserViewControllerDelegate {
    //default implementations
    func promptDismissed() {}
    func timerUpdated(currentTime: TimeInterval, promptVC: PromptUserViewController) {}
    func timerEnded() {}
}

enum UserActionPrompt {
    case ad
    case notifications
    case logout
    case removeTeammate
}

class PromptUserViewController: UIViewController {
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .teamUpBlue()
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowRadius = 4.0
        view.sizeToFit()
        return view
    }()
    
    private let darkenedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.sizeToFit()
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 25
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabelColor()
        label.font = .systemFont(ofSize: 17.5)
        label.sizeToFit()
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 25
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancelIcon")?.resize(newSize: CGSize(width: 25, height: 25)), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 2.5, left: 2.5, bottom: 2.5, right: 2.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let acceptButton: RoundedButton = {
        let button = RoundedButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .accent()
        return button
    }()
    
    private let cancelButton: RoundedButton = {
        let button = RoundedButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.accent().cgColor
        button.setTitleColor(.accent(), for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "teamUpLogoTemplate")?.resize(newSize: CGSize(width: 120, height: 120)).withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.tintColor = .accent()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    var subTitleText: String? {
        didSet {
            subTitleLabel.text = subTitleText
        }
    }
    
    var acceptButtonTitle: String? {
        didSet {
            acceptButton.setTitle(acceptButtonTitle, for: .normal)
        }
    }
    
    var cancelButtonTitle: String? {
        didSet {
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
        }
    }
    
    var isWarning = false {
        didSet {
            acceptButton.backgroundColor = isWarning ? .danger() : .accent()
        }
    }
    
    var acceptButtonEnabled = true {
        didSet {
            acceptButton.isEnabled = acceptButtonEnabled
        }
    }
    
    private var backgroundViewTopAnchorConstraint: NSLayoutConstraint?
    
    var delegate: PromptUserViewControllerDelegate?
    
    var timerLength: Double = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        darkenedView.addGestureRecognizer(tapGesture)
        
        setupViews()
        setTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateView()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(darkenedView)
        view.addSubview(backgroundView)
        
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(subTitleLabel)
        backgroundView.addSubview(logoImageView)
        backgroundView.addSubview(dismissButton)
        backgroundView.addSubview(acceptButton)
        backgroundView.addSubview(cancelButton)
        
        darkenedView.pinEdgesToView(view: view)
        
        backgroundView.anchor(nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        backgroundViewTopAnchorConstraint = backgroundView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: backgroundView.frame.height - 10)
        backgroundViewTopAnchorConstraint?.isActive = true
        
        logoImageView.setHeightAndWidthConstants(height: 120, width: 120)
        logoImageView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor, constant: 10).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        dismissButton.setHeightAndWidthConstants(height: 30, width: 30)
        dismissButton.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 15).isActive = true
        dismissButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 15).isActive = true
        
        acceptButton.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 40).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 65).isActive = true
        acceptButton.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8).isActive = true
        acceptButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 15).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: backgroundView.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 65).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8).isActive = true
        cancelButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
    }
    
    private func animateView() {
        self.backgroundViewTopAnchorConstraint?.constant = -(backgroundView.frame.height - 10)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 2.5, options: .curveLinear) {
            self.darkenedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func handleDismiss() {
        self.backgroundViewTopAnchorConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.2) {
            self.darkenedView.backgroundColor = .clear
            self.view.layoutIfNeeded()
        } completion: { [weak self] (_) in
            self?.delegate?.promptDismissed()
            self?.dismiss(animated: false, completion: {
                if self?.timerLength == 0 {
                    self?.delegate?.timerEnded()
                }
            })
        }
    }
    
    private func setTimer() {
        if timerLength <= 0 { return }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            if strongSelf.timerLength > 0 {
                strongSelf.delegate?.timerUpdated(currentTime: strongSelf.timerLength, promptVC: strongSelf)
                strongSelf.timerLength -= 1
            } else {
                timer.invalidate()
                strongSelf.handleDismiss()
            }
        }
    }
    
    @objc private func handleAccept() {
        delegate?.userAcceptedPrompt()
        handleDismiss()
    }
    
    deinit {
        print("\n\nPromptUserViewController Deinit\n\n")
    }
    
}
