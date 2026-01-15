//
//  SectionHeaderView.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

final class SectionHeaderView: UITableViewHeaderFooterView {
    private(set) lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .textPrimary

        return titleLabel
    }()

    private(set) lazy var separatorView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 1, alpha: 0.12)
        view.isHidden = true
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 4.0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
        ])

        contentView.addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0.0),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0.0),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
        ])
    }
}
