//
//  FeedTableViewCell.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet private var newsImage: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var sourceTitleLable: UILabel!

    private(set) var viewModel: NewsViewModel?
    
    override nonisolated func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImage.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.news.title
        sourceTitleLable.text = "Source: \(viewModel.news.source ?? ""). Date: \(viewModel.news.date.getLongDateTime())"
        guard let image = viewModel.news.image, let url = URL(string: image) else { return }
        Task {
            await newsImage.loadImage(from: url)
        }
    }
}
