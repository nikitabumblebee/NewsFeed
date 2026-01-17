//
//  NewsResourceTableViewCell.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import UIKit

class NewsResourceTableViewCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var urlLabel: UILabel!
    @IBOutlet private var useResourceSwitcher: UISwitch!

    var onResourceSwitchChange: ((Bool) -> Void)?

    override nonisolated func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            selectionStyle = .none
            contentView.layer.cornerRadius = 12
        }
    }

    @IBAction private func onSwitchChange(_ sender: UISwitch) {
        onResourceSwitchChange?(sender.isOn)
        titleLabel.textColor = sender.isOn ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
        urlLabel.textColor = sender.isOn ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
    }

    func setup(newsResource: NewsResource) {
        titleLabel.text = newsResource.name
        urlLabel.text = newsResource.url
        useResourceSwitcher.isOn = newsResource.show
        titleLabel.textColor = newsResource.show ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
        urlLabel.textColor = newsResource.show ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
    }
}
