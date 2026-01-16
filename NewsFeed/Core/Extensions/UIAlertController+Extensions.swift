//
//  UIAlertController+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import MessageUI
import UIKit

extension UIAlertController {
    static let titleTextColor = "titleTextColor"

    // MARK: - Alerts

    static func confirmationAlert(
        title: String,
        message: String? = nil,
        actionTitleConfirm: String = "Yes",
        actionTitleCancel: String = "No",
        reversedOrder: Bool = false,
        cancelTextForeground: UIColor = .gray3,
        confirmTextForeground: UIColor = .textPrimary,
        onCancel: (() -> Void)? = nil,
        actionConfirm: @escaping () -> Void
    )
        -> UIAlertController
    {
        let actionCancel = UIAlertAction(title: actionTitleCancel, style: .destructive, handler: { _ in onCancel?() })
        actionCancel.setValue(cancelTextForeground, forKey: titleTextColor)

        let actionConfirm = UIAlertAction(title: actionTitleConfirm, style: .default, handler: { _ in
            actionConfirm()
        })
        actionConfirm.setValue(confirmTextForeground, forKey: titleTextColor)
        let actions = reversedOrder ? [actionConfirm, actionCancel] : [actionCancel, actionConfirm]
        return makeAlertController(title: title, message: message, alertActions: actions)
    }

    static func informationAlert(title: String, message: String?, customActionTitle: String? = nil, actionInfo: @escaping () -> Void) -> UIAlertController {
        let actionOk = UIAlertAction(title: customActionTitle ?? "Ok", style: .default, handler: { _ in
            actionInfo()
        })
        actionOk.setValue(UIColor.textPrimary, forKey: titleTextColor)
        return makeAlertController(title: title, message: message, alertActions: [actionOk])
    }

    private static func makeAlertController(title: String, message: String?, alertActions: [UIAlertAction]) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
        ]
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)

        let messageAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .regular),
        ]
        if let message {
            let messageString = NSAttributedString(string: message, attributes: messageAttributes)
            alertController.setValue(messageString, forKey: "attributedMessage")
        }
        alertController.setValue(titleString, forKey: "attributedTitle")

        for alertAction in alertActions {
            alertController.addAction(alertAction)
        }
        alertController.view.tintColor = .white
        return alertController
    }

    private static func singleChoiceAlertController(
        title: String,
        message: String? = nil,
        actionTitleConfirm: String = "Yes",
        actionConfirm: @escaping () -> Void
    )
        -> UIAlertController
    {
        let actionConfirm = UIAlertAction(title: actionTitleConfirm, style: .default, handler: { _ in
            actionConfirm()
        })
        actionConfirm.setValue(UIColor.accent, forKey: titleTextColor)
        return makeAlertController(title: title, message: message, alertActions: [actionConfirm])
    }

    static func textFieldAlert(
        title: String,
        message: String? = nil,
        actionTitleConfirm: String = "Yes",
        actionTitleCancel: String = "No",
        placeholder: String = "",
        keyboardType: UIKeyboardType = .default,
        reversedOrder: Bool = false,
        cancelTextForeground: UIColor = .gray3,
        onCancel: (() -> Void)? = nil,
        actionConfirm: @escaping (String) -> Void
    )
        -> UIAlertController
    {
        let alertController = makeAlertController(title: title, message: message, alertActions: [])
        alertController.addTextField { textField in
            textField.placeholder = placeholder
            textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            textField.keyboardType = keyboardType
        }

        let actionCancel = UIAlertAction(title: actionTitleCancel, style: .destructive, handler: { _ in onCancel?() })
        actionCancel.setValue(cancelTextForeground, forKey: titleTextColor)

        let actionConfirm = UIAlertAction(title: actionTitleConfirm, style: .default, handler: { [weak alertController] _ in
            let textField = alertController?.textFields![0]
            actionConfirm(textField?.text ?? "")
        })
        actionConfirm.setValue(UIColor.accent, forKey: titleTextColor)
        let actions = reversedOrder ? [actionConfirm, actionCancel] : [actionCancel, actionConfirm]
        actions.forEach { alertController.addAction($0) }

        return alertController
    }
}
