//
//  FeedTableViewCell.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import SkeletonView
import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet private var newsImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var sourceTitleLable: UILabel!
    @IBOutlet private var readView: UIView!

    private(set) var viewModel: NewsViewModel?

    override nonisolated func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            selectionStyle = .none
            newsImage.setCornerRadius(12)
            titleLabel.linesCornerRadius = 6
            titleLabel.lastLineFillPercent = 100
            sourceTitleLable.linesCornerRadius = 6
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        newsImage.image = nil
        contentView.hideSkeleton()
        readView.isHiddenInStackView = true
    }

    func setup(viewModel: NewsViewModel, state: ContentLoadState) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.news.title
        sourceTitleLable.text = "Source: \(viewModel.news.source ?? ""). Date: \(viewModel.news.date.getLongDateTime())"
        if state == .loading {
            contentView.showAnimatedGradientSkeleton()
        } else if contentView.sk.isSkeletonActive {
            contentView.hideSkeleton()
        }
        readView.isHiddenInStackView = !viewModel.news.isViewed
        newsImage.tintColor = .accent
        newsImage.contentMode = .scaleAspectFit
        if state != .loading {
            newsImage.image = UIImage(systemName: "photo")
        }
        guard let image = viewModel.news.image, let url = URL(string: image) else { return }
        Task {
            guard let cachedImage = try? await ImageCache.shared.image(for: url) else {
                newsImage.image = UIImage(systemName: "photo")
                return
            }
            newsImage.contentMode = .scaleAspectFill
            newsImage.image = cachedImage
        }
    }
}
