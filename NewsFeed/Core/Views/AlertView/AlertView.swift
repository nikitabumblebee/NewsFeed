//
//  AlertView.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

class AlertView: XibView {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var alertView: UIView!
    @IBOutlet private var actionButton: UIButton!

    private(set) var title: String?
    private(set) var message: String?
    private(set) var buttonTitle: String?
    private(set) var timerDuration: TimeInterval?
    private(set) var buttonAction: (() -> Void)?

    private var timer: Timer?
    private var blur: UIView?

    // MARK: - Class functions

    class func show(with title: String? = nil, message: String, blurredBackground: Bool = false) {
        showAlert(
            title: title ?? "",
            message: message,
            blurredBackground: blurredBackground
        )
    }

    @discardableResult
    class func show(
        with title: String? = nil,
        message: String,
        blurredBackground: Bool = false,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> AlertView {
        showAlert(
            title: title ?? "",
            message: message,
            buttonTitle: buttonTitle,
            action: action,
            blurredBackground: blurredBackground,
            duration: nil
        )
    }

    @discardableResult
    class func showError(with message: String, blurredBackground: Bool = false) -> AlertView {
        showAlert(title: "Error", message: message, blurredBackground: blurredBackground)
    }

    class func showProgress(with title: String? = nil, buttonTitle: String, action: @escaping () -> Void) -> AlertView {
        showAlert(
            title: title ?? "",
            message: "",
            buttonTitle: buttonTitle,
            action: action,
            blurredBackground: true,
            duration: nil,
            withHapticFeedback: false
        )
    }

    @discardableResult
    private class func showAlert(
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil,
        blurredBackground: Bool = false,
        duration: TimeInterval? = 2,
        withHapticFeedback: Bool = true
    )
        -> AlertView
    {
        let alert = AlertView(title: title, message: message, buttonTitle: buttonTitle, action: action, duration: duration)
        alert.show(blurredBackground)
        if withHapticFeedback { HapticFeedbackGenerator.playResultFeedback(.error) }
        return alert
    }

    // MARK: -

    init(
        title: String?,
        message: String?,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil,
        duration: TimeInterval?
    ) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        buttonAction = action
        timerDuration = duration

        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func nibName() -> String {
        "AlertView"
    }

    // MARK: - Actions

    func show(_ blurredBackground: Bool = false) {
        guard let window = UIApplication.shared.windows.filter(\.isKeyWindow).first else {
            return
        }

        blur?.removeFromSuperview()

        if blurredBackground {
            if blur == nil {
                let blur = UIVisualEffectView(frame: window.frame)
                blur.effect = UIBlurEffect(style: .systemThinMaterialLight)
                self.blur = blur
            }
            if let blur {
                window.addSubview(blur)
            }
        }

        window.addSubview(self)

        alpha = 0
        blur?.alpha = 0

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
            self.blur?.alpha = 1
        })
    }

    func updateTitle(_ newTitle: String) {
        title = newTitle
        titleLabel.text = newTitle
    }

    func transition(to alert: AlertView, withHaptic: Bool = false) {
        UIView.animate(
            withDuration: 0.2,
            animations: { self.alpha = 0 },
            completion: { [weak self] _ in
                self?.title = alert.title
                self?.message = alert.message
                self?.buttonTitle = alert.buttonTitle
                self?.buttonAction = alert.buttonAction
                self?.timerDuration = alert.timerDuration

                self?.setupView()
                if withHaptic { HapticFeedbackGenerator.playResultFeedback(.error) }
                UIView.animate(withDuration: 0.2) { self?.alpha = 1 }
            }
        )
    }

    @IBAction private func actionButtonTapped() {
        buttonAction?()
    }

    @objc func close() {
        timer?.invalidate()
        timer = nil

        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.blur?.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.blur?.removeFromSuperview()
        })
    }

    private func setupView() {
        if title == nil {
            titleLabel.isHiddenInStackView = true
        }
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        alertView.layer.cornerRadius = 14
        alertView.layer.masksToBounds = true

        titleLabel.alpha = 1

        if let buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            actionButton.isHiddenInStackView = false
        } else {
            actionButton.isHiddenInStackView = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            addGestureRecognizer(tapGesture)
        }

        if let duration = timerDuration {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(close), userInfo: nil, repeats: false)
        }
    }
}
