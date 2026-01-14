//
//  UITableViewCell+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

public extension UITableViewCell {
    static var defaultNib: UINib {
        getNib(nibName: defaultNibName)
    }

    static func getNib(nibName: String) -> UINib {
        UINib(nibName: nibName, bundle: Bundle(for: self))
    }

    static func getCellFromDefaultNib<T: UITableViewCell>() -> T {
        getCell(fromNib: defaultNibName)
    }

    static func getCell<T: UITableViewCell>(fromNib nibName: String) -> T {
        guard let cell = getNib(nibName: nibName).instantiate(withOwner: nil, options: nil).first as? T else {
            fatalError("\(self) has not been initialized properly from nib \(nibName)")
        }
        return cell
    }

    static func registerNib(for tableView: UITableView) {
        registerNib(for: tableView, nibName: defaultNibName, reuseIdentifier: identifier)
    }

    static func registerNib(for tableView: UITableView, nibName: String, reuseIdentifier: String) {
        tableView.register(UINib(nibName: nibName, bundle: Bundle(for: self)), forCellReuseIdentifier: identifier)
    }

    static func registerClass(for tableView: UITableView) {
        registerClass(for: tableView, reuseIdentifier: identifier)
    }

    static func registerClass(for tableView: UITableView, reuseIdentifier: String) {
        tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
    }

    static func dequeue(from tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) else {
            fatalError("Unable to dequeue cell with reuse identifier '\(identifier)'")
        }
        return cell
    }

    static func dequeue<T: UITableViewCell>(from tableView: UITableView, for indexPath: IndexPath) -> T {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue cell of type \(T.self) with reuse identifier '\(identifier)'")
        }
        return cell
    }

    class func register(for tableView: UITableView) {
        tableView.register(getNib(), forCellReuseIdentifier: identifier)
    }

    @objc class func getNib() -> UINib {
        UINib(nibName: identifier, bundle: .none)
    }

    class func dequeue(_ tableView: UITableView) -> Self {
        func dequeue<T>(_ tableView: UITableView) -> T {
            if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? T {
                return cell
            }
            register(for: tableView)

            // swiftlint:disable:next force_cast - we prefer it to crash
            return tableView.dequeueReusableCell(withIdentifier: identifier) as! T
        }

        return dequeue(tableView)
    }
}
