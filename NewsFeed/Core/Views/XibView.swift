//
//  XibView.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import UIKit

class XibView: UIView {
    @IBOutlet var contentView: UIView!

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    // MARK: - Overrides

    func xibSetup() {
        contentView = loadViewFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        initialSetup()
    }

    func initialSetup() {}

    func nibName() -> String {
        ""
    }

    // MARK: - Private

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName(), bundle: bundle)
        // swiftlint:disable:next force_cast - we prefer it to crash
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView

        return view
    }
}
