//
//  UIView+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

public extension UIView {
    static var defaultNibName: String {
        String(describing: self)
    }

    static func loadFromDefaultNib<T: UIView>() -> T {
        loadFromNib(defaultNibName)
    }

    static func loadFromNib<T: UIView>(_ nibName: String) -> T {
        loadFromNib(nibName, bundle: Bundle(for: self))
    }

    static func loadFromNib<T: UIView>(_ nibName: String, bundle: Bundle) -> T {
        loadFromNib(nibName, bundle: bundle, owner: nil)
    }

    static func loadFromNib<T: UIView>(_ nibName: String, bundle: Bundle, owner: Any?) -> T {
        guard let view = bundle.loadNibNamed(nibName, owner: owner, options: nil)?.first as? T else {
            fatalError("\(self) has not been initialized properly from nib \(nibName)")
        }
        return view
    }

    func loadViewFromNib(_ nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

extension UIView {
    class var identifier: String {
        String(describing: self)
    }

    class func loadFromNib(_ nibName: String? = .none) -> Self {
        func loadAs<T: UIView>(_ nibName: String? = .none) -> T {
            let nib = UINib(nibName: nibName ?? String(describing: T.self), bundle: Bundle.main)
            let objectsArray = nib.instantiate(withOwner: self, options: .none)
            for topObject in objectsArray {
                if let view = topObject as? T {
                    return view
                }
            }
            return T()
        }

        return loadAs(nibName)
    }

    func layoutInto(_ parentView: UIView, leftInset: CGFloat = 0, rightInset: CGFloat = 0, topInset: CGFloat = 0, bottomInset: CGFloat = 0) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        leftAnchor.constraint(equalTo: parentView.leftAnchor, constant: leftInset).isActive = true
        rightAnchor.constraint(equalTo: parentView.rightAnchor, constant: -rightInset).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -bottomInset).isActive = true
        topAnchor.constraint(equalTo: parentView.topAnchor, constant: topInset).isActive = true
    }

    var isHiddenInStackView: Bool {
        get {
            isHidden
        }
        set {
            if isHidden != newValue {
                isHidden = newValue
            }
        }
    }

    func setRoundedCorners() {
        setCornerRadius(bounds.size.height / 2)
    }

    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func setCornerRadius(_ radius: CGFloat, border: CGFloat, color: UIColor) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderWidth = border
        layer.borderColor = color.cgColor
    }
}
