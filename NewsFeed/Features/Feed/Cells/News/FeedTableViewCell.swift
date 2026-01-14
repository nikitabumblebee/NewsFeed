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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
}
