//
//  NewsSourceTableViewCell.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import UIKit

class NewsSourceTableViewCell: UITableViewCell {
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.backgroundColor = .accent.withAlphaComponent(0.6)
        } else {
            contentView.backgroundColor = .clear
        }
    }

    @IBAction private func onSwitchChange(_ sender: UISwitch) {
        onResourceSwitchChange?(sender.isOn)
        titleLabel.textColor = sender.isOn ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
        urlLabel.textColor = sender.isOn ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
    }

    func setup(newsSource: NewsResource) {
        titleLabel.text = newsSource.name
        urlLabel.text = newsSource.url
        useResourceSwitcher.isOn = newsSource.show
        titleLabel.textColor = newsSource.show ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
        urlLabel.textColor = newsSource.show ? .textPrimary : .textPrimary.withAlphaComponent(0.6)
    }
}
